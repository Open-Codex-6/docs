# 接入新 SubAgent 指南

## 概述

在 Master-SubAgent 架构中，每个 SubAgent 是一个领域专家（如交通、酒店），由 Supervisor 通过 `delegate_*` 工具在 LLM 循环中自主调用。接入一个新 SubAgent 需要修改 5 个文件。

## 步骤

以新增一个 **WeatherAgent**（天气专家）为例。

### 1. 创建 Worker 类

在 `src/agents/workers/` 下新建 `weather.py`：

```python
from src.agents.workers.base_worker import WorkerAgent


class WeatherAgent(WorkerAgent):
    pass
```

Worker 的工具权限由 `tool_allocation.yaml` 统一管理，无需在类中硬编码。

### 2. 注册导出

**`src/agents/workers/__init__.py`** 追加：

```python
from src.agents.workers.weather import WeatherAgent

__all__ = [
    ...,
    "WeatherAgent",
]
```

**`src/agents/__init__.py`** 追加：

```python
from src.agents.workers.weather import WeatherAgent

__all__ = [
    ...,
    "WeatherAgent",
]
```

### 3. 配置 Prompt

在 `src/agents/prompts.yaml` 中新增 Agent 的 system 和 task 模板：

```yaml
weather:
  system: |
    你是天气专家。你只负责天气相关的查询和建议，不涉及其他领域。

    请根据任务要求，提供天气信息，包括：
    - 目的地未来几天的天气概况
    - 温度、降水概率等关键指标
    - 对出行的影响建议

  task: |
    当前任务：{task}

    用户整体需求：
    {user_request}

    已有计划快照（可能包含其他 Agent 已规划的内容，供参考）：
    {plan_snapshot}

    请仅输出天气相关的规划内容，用 Markdown 格式呈现。
```

模板变量：`{task}`（Supervisor 分配的具体任务）、`{user_request}`（用户原始请求）、`{plan_snapshot}`（当前黑板内容）。

### 4. 配置工具权限

在 `src/agents/tool_allocation.yaml` 中：

**声明 Supervisor 可调用此 SubAgent**：

```yaml
supervisor:
  subagents:
    - traffic
    - hotel
    - attraction
    - food
    - weather          # ← 新增
```

**声明此 Agent 可用的外部工具**：

```yaml
weather:
  tools:
    - get_weather     # 如有精确名称的工具
  prefixes:
    - amap_           # 或按前缀匹配
  subagents: []       # 通常 Worker 没有下属
```

### 5. 注册 Worker 类映射

在 `src/core/orchestrator.py` 的 `WORKER_CLASSES` 字典中加入：

```python
WORKER_CLASSES: Dict[str, type] = {
    "traffic": TrafficAgent,
    "hotel": HotelAgent,
    "attraction": AttractionAgent,
    "food": FoodAgent,
    "weather": WeatherAgent,   # ← 新增
}
```

Orchestrator 启动时读取 `tool_allocation.yaml` 中 `supervisor.subagents` 列表，对每个 key 在 `WORKER_CLASSES` 中查找对应的 Worker 类，动态生成 `SubAgentTool`（`delegate_weather`）并注入 Supervisor 的工具列表。
