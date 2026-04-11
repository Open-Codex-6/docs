# 工具接入指南

## 本地 Python 工具

对于运行在同一个进程，直接用 Python 开发的业务闭环或者第三方 API 调用，使用本地工具是最简单直观的方式。

### 步骤

1. **编写工具类**：在 `src/services/tools/providers/local.py` 中补充一个新的 `BaseTool` 子类。
2. **注册到 Provider**：确保将它挂载到 `LocalProvider._tools` 数组中。

### 示例

```python
from ..base import BaseTool

class CalculatorTool(BaseTool):
    # 1. 设置名称和内部描述
    name = "calculator"
    description = "执行基础的加法运算"
    
    # 2. 提供符合 OpenAI 函数调用规范的 JSON Schema
    schema = {
        "type": "function",
        "function": {
            "name": "calculator",
            "description": "执行基础的加法运算",
            "parameters": {
                "type": "object",
                "properties": {
                    "a": { "type": "number", "description": "左操作数" },
                    "b": { "type": "number", "description": "右操作数" }
                },
                "required": ["a", "b"]
            }
        }
    }

    # 3. 实现真正的核心逻辑 (支持异步)
    async def execute(self, **kwargs):
        a = kwargs.get("a", 0)
        b = kwargs.get("b", 0)
        return {"result": a + b}
```

然后在 `LocalProvider` 的 `__init__` 里把它加进去：

```python
def __init__(self):
    self._tools: List[BaseTool] = [WeatherTool(), CalculatorTool()]
```

## 【待实现】外部 MCP 服务器 (MCP Tool)

(此特性正处于开发路线图中的 Phase 2)。MCP (Model Context Protocol) 是一种开放标准，允许我们使用同一套协议连接并调用分散在微服务、各种子系统乃至外部提供商的能力。

### 技术路线

我们将会在 `src/services/tools/providers/mcp.py` 实现一个 `MCPProvider`。

### 样例代码（草稿级设计）

**1. Provider 的实现**：

```python
from ..base import BaseTool, ToolProvider
# 此处需假定我们引入了 mcp 官方或社区的 python mcp-client
import mcp_client 

class MCPToolAdapter(BaseTool):
    """把 MCP Endpoint 下发的 JSON Schema 包装成系统需要的 Tool"""
    def __init__(self, mcp_name, schema, connection):
        self.name = f"mcp_{mcp_name}" # 防冲突命名空间
        self.description = schema.get("description", "")
        self.schema = schema
        self._conn = connection

    async def execute(self, **kwargs):
        # 转发请求给 MCP 服务
        return await self._conn.call_tool(self.name.replace("mcp_", ""), kwargs)

class MCPProvider(ToolProvider):
    name = "mcp"
    def __init__(self, sse_endpoint_url: str):
        self.url = sse_endpoint_url
        self._conn = None

    async def get_tools(self) -> list[BaseTool]:
        # 1. 建立或复用连接
        if not self._conn:
            self._conn = await mcp_client.connect_sse(self.url)
        # 2. 拉取远端能力列表并封装
        remote_schemas = await self._conn.list_tools()
        return [MCPToolAdapter(s['name'], s, self._conn) for s in remote_schemas]
```

**2. 在服务启动时连接**
前往 `src/services/tools/__init__.py` 或 `main.py` 的初始化阶段：

```python
registry.add_provider(MCPProvider(sse_endpoint_url="http://localhost:8080/mcp/sse"))
```

一切接入将会在后端完全解耦，编排层和模型一视同仁地将其作为可选工具。
