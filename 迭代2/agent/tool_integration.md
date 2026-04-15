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

## 外部 MCP 服务器 (MCP Tool)

对于运行在独立进程、通过 MCP 协议暴露的第三方服务（如本地 Node.js 服务、云 API 包装器等），使用 MCP 工具可扩展系统能力。

### 步骤

1. **配置环境变量**：在 `.env` 中添加 MCP 服务器的启动命令与 API 密钥。
2. **创建 MCP Provider 工厂**：在 `src/services/tools/providers/` 下创建一个 `{service_name}_mcp.py` 文件，包含工厂函数 `create_{service_name}_mcp_provider()`。
3. **注册到系统**：在 `src/services/tools/__init__.py` 中调用工厂函数，将 Provider 加入注册表。

### 示例：高德地图

**1. 配置环境变量**：

> **具体情况具体分析**
> 所有的参数请写入 configuration.md 以说明每个参数的用处

**2. 创建 MCP Provider 工厂**：
在 `src/services/tools/providers/amap_mcp.py` 中实现：

```python
from .mcp_base import MCPProvider

def create_amap_mcp_provider():
    """创建高德地图 MCP Provider"""
    command = os.getenv("MCP_AMAP_COMMAND", "npx")
    args = os.getenv("MCP_AMAP_ARGS", "-y @amap/amap-maps-mcp-server").split()
    
    amap_provider = MCPProvider(
        name="amap",
        command=command,
        args=args,
        env={
            "AMAP_MAPS_API_KEY": os.getenv("AMAP_MAPS_API_KEY", "")
        }
    )
    return amap_provider if amap_provider.available() else None
```

**3. 注册到系统**：
在 `src/services/tools/__init__.py` 中：

```python
from .providers.amap_mcp import create_amap_mcp_provider

# 实例化并注册高德 Provider
amap_provider = create_amap_mcp_provider()
if amap_provider:
    registry.add_provider(amap_provider)
```

### 运行机制说明

- **防冲突命名**: MCP 工具会自动添加前缀（如 `amap_`），避免与本地工具重名。
- **安全性**: 具备 30s 硬超时保护及子进程异常回滚机制。
- **兼容性**: 自动清理 JSON Schema 中的 `$schema`、`title` 等 OpenAI 不支持的元数据字段。

一切接入在后端完全解耦，编排层和模型将一视同仁地使用这些扩展能力。
