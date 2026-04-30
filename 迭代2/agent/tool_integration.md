# 工具接入指南

## 本地 Python 工具

对于运行在同一个进程，直接用 Python 开发的业务闭环或者第三方 API 调用，使用本地工具是最简单直观的方式。

### 接入本地工具的步骤

1. **编写工具模块**：在 `src/services/tools/local/` 下新建一个 `xxx.py` 文件，实现 `BaseTool` 子类，并提供 `create_tool()` 工厂函数。
2. **注册到工厂列表**：在 `local/discovery.py` 中导入工厂函数，追加到 `FACTORIES` 列表。

### 示例代码

以编写一个简单的天气查询工具为例。

#### 创建 `src/services/tools/local/weather.py`

```python
import logging
from typing import Any

from src.services.tools.base import BaseTool

logger = logging.getLogger(__name__)


class WeatherTool(BaseTool):
    name = "get_weather"
    description = "获取指定城市的当前实时天气情况及温度"

    schema = {
        "type": "function",
        "function": {
            "name": "get_weather",
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
        location = kwargs.get("location", "未知地点")
        logger.debug("WeatherTool.execute called with location=%s", location)
        # ... 业务逻辑与第三方调用 ...
        return {
            "location": location,
            "weather": "晴朗",
            "temperature_c": 28,
        }


def create_tool() -> BaseTool:
    return WeatherTool()
```

#### 在 `local/discovery.py` 中注册

```python
from .travel_plan_read import create_tool as _create_read_tool
from .travel_plan_write import create_tool as _create_write_tool
from .weather import create_tool as _create_weather_tool

FACTORIES = [_create_read_tool, _create_write_tool, _create_weather_tool]
```

`_load_tools()` 会遍历 `FACTORIES` 列表，依次调用每个工厂函数完成工具加载。`provider.py` 无需修改。

## 外部 MCP 服务器

对于运行在独立进程、通过 MCP 协议暴露的第三方服务，使用 MCP 工具可扩展系统能力。

### 接入 MCP 服务器的步骤

1. **配置环境变量**：在 `.env` 中添加 MCP 服务器所需的 API 密钥。
2. **创建 MCP Provider 模块**：在 `src/services/tools/mcp/` 下新建 `xxx.py`，提供 `create_provider()` 工厂函数。
3. **注册到工厂列表**：在 `mcp/discovery.py` 中导入工厂函数，追加到 `FACTORIES` 列表。

### 示例：高德地图

#### 1. 配置环境变量

```bash
AMAP_MAPS_API_KEY=your_api_key_here
```

> 所有参数请写入 `configuration.md` 以说明每个参数的用处。

#### 2. 创建 MCP Provider 模块

在 `src/services/tools/mcp/amap.py` 中实现：

```python
import logging
import os
import shlex
from typing import Optional

from .provider import MCPProvider

logger = logging.getLogger(__name__)

COMMAND = "npx"
ARGS = "-y @amap/amap-maps-mcp-server"


def create_provider() -> Optional[MCPProvider]:
    amap_key = (os.getenv("AMAP_MAPS_API_KEY") or "").strip()
    if not amap_key:
        logger.debug("AMAP_MAPS_API_KEY not found, skipping AMap MCP provider")
        return None

    command = COMMAND.strip()
    args_raw = ARGS.strip()

    try:
        args = shlex.split(args_raw)
    except Exception as exc:
        logger.error("Failed to parse MCP args: %s", exc)
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

#### 3. 在 `mcp/discovery.py` 中注册

```python
from .amap import create_provider as _create_amap
from .railway import create_provider as _create_railway
from .variflight import create_provider as _create_variflight

FACTORIES = [_create_amap, _create_railway, _create_variflight]
```

`load_mcp_providers()` 遍历 `FACTORIES`，调用每个工厂函数。`provider.py` 无需修改。

## 运行机制说明

- **协议与注册分离**：`provider.py` 只包含协议实现，`discovery.py` 持有工厂列表和加载逻辑。新增工具/MCP 服务只需改动 `discovery.py`，核心代码保持稳定。
- **自动发现**：local 工具和 MCP provider 都通过工厂列表自动发现，新增只需追加到对应 `FACTORIES` 列表，无需改动调用方。
- **防冲突命名**：MCP 工具通过 `tool_name_prefix` 参数自动添加前缀（如 `amap_`），避免与本地工具或其他 MCP 服务的工具重名。
- **安全性**：MCP 工具调用具备 30s 硬超时保护及子进程异常回滚机制。
- **兼容性**：自动清理 JSON Schema 中的 `$schema`、`title` 等 OpenAI 不支持的元数据字段。

一切接入在后端完全解耦，编排层和模型将一视同仁地使用这些扩展能力。
