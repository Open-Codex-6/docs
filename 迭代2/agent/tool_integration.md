# 工具接入指南

## 本地 Python 工具

对于运行在同一个进程，直接用 Python 开发的业务闭环或者第三方 API 调用，使用本地工具是最简单直观的方式。

### 步骤

1. **编写工具类**：在 `src/services/tools/providers/local.py` 中补充一个新的 `BaseTool` 子类。
2. **注册到 Provider**：确保将它挂载到 `LocalProvider` 的初始化集合中。

### 示例代码

以编写一个简单的天气查询工具为例：

```python
import logging
from typing import Any
from ..base import BaseTool

logger = logging.getLogger(__name__)

class WeatherTool(BaseTool):
    """一个本地的模拟天气工具"""

    name = "get_weather_local"
    description = "获取指定城市的当前实时天气情况及温度"

    # 兼容 OpenAI Tools 定义的 Schema
    schema = {
        "type": "function",
        "function": {
            "name": "get_weather_local",
            "description": "获取指定城市的当前实时天气情况及温度",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "需要查询的城市或地点名称，例如：北京、广州",
                    }
                },
                "required": ["location"],
            },
        },
    }

    async def execute(self, **kwargs) -> Any:
        """执行天气查询"""
        location = kwargs.get("location", "未知地点")
        logger.debug("WeatherTool.execute called with location=%s", location)
        
        # ... 业务逻辑与第三方调用 ...
        return {
            "location": location,
            "weather": "晴朗",
            "temperature_c": 28,
        }
```

然后在 `LocalProvider` 的 `__init__` 里把它加进去：

```python
from typing import List
from ..base import ToolProvider

class LocalProvider(ToolProvider):
    name = "local"

    def __init__(self):
        # 初始化时加载指定的工具
        self._tools: List[BaseTool] = [WeatherTool()]
        
    async def get_tools(self) -> List[BaseTool]:
        return self._tools
```

## 外部 MCP 服务器 (MCP Tool)

对于运行在独立进程、通过 MCP 协议暴露的第三方服务（如本地 Node.js 服务、云 API 包装器等），使用 MCP 工具可扩展系统能力。

### 步骤

1. **配置环境变量**：在 `.env` 中添加 MCP 服务器的启动命令与 API 密钥。
2. **创建 MCP Provider 工厂**：在 `src/services/tools/providers/` 下创建一个 `{service_name}_mcp.py` 文件，包含工厂函数 `create_{service_name}_mcp_provider()`。
3. **注册到系统**：在 `src/services/tools/__init__.py` 中调用工厂函数，将 Provider 加入注册表。

### 示例：高德地图

#### 1. 配置环境变量

> **具体情况具体分析**
> 所有的参数请写入 `configuration.md` 以说明每个参数的用处

#### 2. 创建 MCP Provider 工厂

在 `src/services/tools/providers/amap_mcp.py` 中实现：

```python
COMMAND = "npx"
ARGS = "-y @amap/amap-maps-mcp-server"


def create_amap_mcp_provider() -> Optional[MCPProvider]:
    """
    工厂函数：根据环境变量创建高德地图 MCP Provider。
    保持 MCPProvider 类的通用性，将具体业务（高德）逻辑抽离到此处。
    """
    amap_key = (os.getenv("AMAP_MAPS_API_KEY") or "").strip()
    if not amap_key:
        logger.debug("AMAP_MAPS_API_KEY not found, skipping AMap MCP provider")
        return None

    command = COMMAND.strip()
    args_raw = ARGS.strip()

    try:
        args = shlex.split(args_raw)
    except Exception as e:
        logger.error("Failed to parse MCP_AMAP_ARGS: %s", e)
        return None

    env = {"AMAP_MAPS_API_KEY": amap_key}

    return MCPProvider(
        provider_name="amap-maps",
        command=command,
        args=args,
        env=env,
        tool_name_prefix="amap",
    )
```

#### 3. 注册到系统

在 `src/services/tools/__init__.py` 中：

```python
import logging
from .registry import ToolRegistry
from .selectors import AllToolsSelector
from .providers.local import LocalProvider
from .providers.amap_mcp import create_amap_mcp_provider

logger = logging.getLogger(__name__)

registry = ToolRegistry(selector=AllToolsSelector())
registry.add_provider(LocalProvider())

# 实例化并尝试注册高德 Provider
amap_provider = create_amap_mcp_provider()
if amap_provider:
    try:
        registry.add_provider(amap_provider)
        logger.info("AMap MCP provider registered")
    except Exception as e:
        logger.error("Failed to register AMap MCP provider: %s", e)
```

### 运行机制说明

- **防冲突命名**: 利用 `tool_name_prefix` 参数，MCP 工具会自动添加前缀（如 `amap_`），避免与本地工具或其他 MCP 服务的工具重名。
- **安全性**: 具备 30s 硬超时保护及子进程异常回滚机制。
- **兼容性**: 自动清理 JSON Schema 中的 `$schema`、`title` 等 OpenAI 不支持的元数据字段。

一切接入在后端完全解耦，编排层和模型将一视同仁地使用这些扩展能力。
