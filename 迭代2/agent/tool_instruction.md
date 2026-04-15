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

系统已完整支持通过 MCP (Model Context Protocol) 协议接入外部工具服务器。目前采用 `stdio` 通信模式，并实现了业务解耦。

### 技术路线

1. **核心驱动层**: `src/services/tools/providers/mcp.py` 实现通用的 `MCPProvider`，负责进程管理、超时控制与 Schema 清洗。
2. **业务适配层**: 如 `src/services/tools/providers/amap_mcp.py`，负责特定 MCP Server（如高德地图）的参数配置。

### 接入示例：高德地图

**1. 配置环境变量**：
在 `.env` 中添加：

```env
# 必填：高德地图 API Key
AMAP_MAPS_API_KEY=你的高德Key

# 可选：自定义启动命令及参数（默认如下）
MCP_AMAP_COMMAND=npx
MCP_AMAP_ARGS=-y @amap/amap-maps-mcp-server
```

**2. 核心对接逻辑**：
系统在 `src/services/tools/__init__.py` 中自动调用工厂函数进行注册：

```python
from .providers.amap_mcp import create_amap_mcp_provider

# 实例化高德专用 Provider
amap_provider = create_amap_mcp_provider()
if amap_provider:
    registry.add_provider(amap_provider)
```

### 运行机制说明

- **防冲突命名**: MCP 工具会自动添加前缀（如 `amap_`），避免与本地工具重名。
- **安全性**: 具备 30s 硬超时保护及子进程异常回滚机制。
- **兼容性**: 自动清理 JSON Schema 中的 `$schema`、`title` 等 OpenAI 不支持的元数据字段。

一切接入在后端完全解耦，编排层和模型将一视同仁地使用这些扩展能力。

