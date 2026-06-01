# Agent Eval API 接口文档

## 评测模块

### 提交评测任务

- **功能说明**：提交 Agent 的多轮对话执行轨迹（包含工具调用与耗时记录等），并根据指定的评价指标列表进行异步高并发计算，返回各项指标的评测结果。
- **接口地址**: `POST /api/v1/evaluate`
- **请求头**
  - Content-Type: `application/json`

**请求参数**

*ps : 实际上根据不同指标的计算逻辑，不是每个属性都必须填写，后续会更新每个指标必须要有的属性，传入可以考虑将值设置为空,例如可以参考下面的样例，只需要metadata里面的latency_ms不为空即可满足要求*

#### 顶层字段

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `target_metrics` | `Array[String]` | 是 | 要触发的评价指标列表 (例如: `["avg_latency"]`)。内置指标见下方说明，自定义指标需同时提供 `custom_metrics` 配置 |
| `rounds` | `Array[Round]` | 是 | 会话内的多轮对话交互与执行记录，Agent 后端在一次问答结束后，记录该次问答对应的 `Round` 数据，评测平台可从 Agent 数据库中导出对话的 `rounds` |
| `currentPlan` | `CurrentPlan` | 否 | 当前行程计划快照。包含计划版本、更新来源及条目列表。用于评测计划相关的指标 |
| `custom_metrics` | `Array[CustomMetricConfig]` | 否 | 用户自定义评分量规。当 `target_metrics` 中包含自定义指标名时，需在此提供对应的评分标准 |

#### 内置指标

平台内置以下统计与 LLM 评估指标，可直接在 `target_metrics` 中使用：

| 指标名 | 类型 | 说明 | 依赖数据 |
| :--- | :--- | :--- | :--- |
| `Average Latency` | 统计 | 计算所有轮次的平均延迟 | `rounds[].metadata.latency_ms` |
| `Location Reliability` | 统计+API | 三级流水线验证坐标有效性、POI 是否存在、坐标是否偏移 | `currentPlan.items` + 高德 Geocoding API |
| `Schedule Reasonability` | 统计 | 按日期分组检测时间冲突，取最严重冲突对的惩罚分 | `currentPlan.items[].start_time/end_time` |
| `Route Efficiency` | 统计 | 按日期分组计算路线顺直度（最近邻贪心 vs 实际路线） | `currentPlan.items[].details.data` |
| `Faithfulness` | Ragas LLM | Ragas 忠实度评估 | `rounds[]` |
| `Answer Relevancy` | Ragas LLM | Ragas 答案相关性评估 | `rounds[]` |
| `Coherence` | Ragas LLM | Ragas 连贯性评估 | `rounds[]` |
| `Harmfulness` | Ragas LLM | Ragas 有害性评估 | `rounds[]` |

#### 自定义指标（Custom Metrics）

自定义指标允许用户指定评分量规（rubric），由 LLM 根据对话内容和量规进行 0~1 浮点评分。

**`CustomMetricConfig` 结构：**

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `metric_name` | `String` | 是 | 自定义指标名称，需与 `target_metrics` 中的条目一致 |
| `rubric` | `Dict[Float, String]` | 是 | 评分量规，键为 0.0~1.0 的分数等级，值为该等级的判定标准描述 |

- 请求在 `target_metrics` 中声明自定义指标名，同时在 `custom_metrics` 中提供对应的量规配置

**量规示例：**

```json
{
  "metric_name": "任务完成度",
  "rubric": {
    "0.0": "完全没有理解用户需求，答非所问",
    "0.2": "只响应用户需求的一小部分，遗漏了多个核心诉求",
    "0.4": "响应了用户部分需求，但有关键信息缺失或未跟进用户的追问",
    "0.6": "基本完成了用户的主要需求，但在完整性或细节上仍有不足",
    "0.8": "完整满足了用户的所有需求，回复有条理、细节充分",
    "1.0": "不仅完美完成所有需求，还主动提供了额外有价值的信息"
  }
}
```

**完整请求示例：**

```json
{
  "target_metrics": ["Average Latency", "任务完成度", "容错处理能力"],
  "rounds": [
    {
      "query": "帮我规划北京3天行程",
      "final_response": "已为您规划好...",
      "agent": "supervisor",
      "is_delegated": false,
      "steps": [],
      "metadata": {"latency_ms": 3800, "is_error": false}
    }
  ],
  "custom_metrics": [
    {
      "metric_name": "任务完成度",
      "rubric": {
        "0.0": "完全没有理解用户需求",
        "0.5": "部分完成用户需求",
        "1.0": "完美完成所有需求"
      }
    },
    {
      "metric_name": "容错处理能力",
      "rubric": {
        "0.0": "遇到错误后完全崩溃",
        "0.5": "能感知错误但未处理",
        "1.0": "优雅降级并主动提供替代方案"
      }
    }
  ]
}
```

**响应示例：**

```json
{
  "results": [
    {
      "metric_name": "Average Latency",
      "score": 3800.0,
      "reason": "全局共有 1 个有效轮次记录耗时, Session平均延迟为 3800.00 ms",
      "status": "success"
    },
    {
      "metric_name": "任务完成度",
      "score": 0.75,
      "reason": "Agent 基本完成了行程规划...",
      "status": "success"
    },
    {
      "metric_name": "容错处理能力",
      "score": 0.8,
      "reason": "在颐和园查询超时后明确告知用户...",
      "status": "success"
    }
  ]
}
```

#### `CurrentPlan`（当前计划）

计划快照，记录一次会话中的行程状态。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `version` | `Integer` | 否 | 计划版本号 |
| `updatedBy` | `Enum(account,agent)` | 是 | 更新来源：`account`=用户手动修改，`agent`=Agent 自动更新 |
| `items` | `Array[PlanItem]` | 是 | 计划条目列表 |

#### `PlanItem`（计划条目）

计划中的一个条目，可以是景点、酒店、餐饮、长途交通或短途交通。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `type` | `String(20)` | 是 | 条目类型，最长 20 字符 |
| `name` | `String(20)` | 是 | 条目名称，最长 20 字符 |
| `start_time` | `String` | 是 | 开始时间，格式 `YYYY-MM-DDTHH:mm:ss+8:00` |
| `end_time` | `String` | 是 | 结束时间，格式 `YYYY-MM-DDTHH:mm:ss+8:00` |
| `notes` | `String(100)` | 否 | 说明，最长 100 字符 |
| `status` | `String(20)` | 是 | 当前状态，最长 20 字符 |
| `isConfirmed` | `Boolean` | 是 | 是否已被用户接收 |
| `cost` | `Integer` | 是 | 预估花费（元） |
| `CreatedInVersion` | `Integer` | 否 | 条目创建的版本号 |
| `RemovedInVersion` | `Integer` | 否 | 条目移除的版本号，`null` 表示尚未移除 |
| `details` | `PlanItemDetail` | 是 | 条目详情（type + data 结构） |

#### `PlanItemDetail`（条目详情）

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `type` | `Enum` | 是 | 详情类型：`attraction` / `hotel` / `food` / `transport_long` / `transport_short` |
| `data` | `Object` | 是 | 详情数据，结构由 `type` 决定（见下方五种 data 结构） |

#### `Location`（地理位置）

五种 data 共用字段，内嵌在 `data.location`、`data.departure_location`、`data.arrival_location` 中。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `poi_id` | `String` | 否 | POI 唯一标识 |
| `poi_name` | `String` | 否 | POI 名称 |
| `address` | `String` | 否 | 详细地址 |
| `lng` | `Double` | 否 | 经度 |
| `lat` | `Double` | 否 | 纬度 |

#### data 结构：`attraction`（景点）

```json
{
  "type": "attraction",
  "suggested_duration": 1,
  "opening_hours": "string",
  "booking_reference": "string",
  "location": { ... },
  "tags": ["string[]"]
}
```

| 参数名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `suggested_duration` | `Integer` | 建议游览时间（小时） |
| `opening_hours` | `String` | 开放时间描述 |
| `booking_reference` | `String` | 预订参考号 |
| `location` | `Location` | 景点位置 |
| `tags` | `Array[String]` | 标签列表 |

#### data 结构：`hotel`（酒店）

```json
{
  "type": "hotel",
  "contact_phone": "string",
  "room_type": "string",
  "booking_reference": "string",
  "location": { ... },
  "tags": ["string[]"]
}
```

| 参数名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `contact_phone` | `String` | 联系电话 |
| `room_type` | `String` | 房型 |
| `booking_reference` | `String` | 预订参考号 |
| `location` | `Location` | 酒店位置 |
| `tags` | `Array[String]` | 标签列表 |

#### data 结构：`food`（餐饮）

```json
{
  "type": "food",
  "recommend_dishes": ["string[]"],
  "opening_hours": "string",
  "location": { ... },
  "tags": ["string[]"]
}
```

| 参数名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `recommend_dishes` | `Array[String]` | 推荐菜品 |
| `opening_hours` | `String` | 营业时间 |
| `location` | `Location` | 餐厅位置 |
| `tags` | `Array[String]` | 标签列表 |

#### data 结构：`transport_long`（长途交通）

```json
{
  "type": "transport_long",
  "transport_mode": "string",
  "departure_station": "string",
  "arrival_station": "string",
  "vehicle_number": "string",
  "seat_info": "string",
  "booking_reference": "string",
  "departure_location": { ... },
  "arrival_location": { ... }
}
```

| 参数名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `transport_mode` | `String` | 交通方式（train / flight） |
| `departure_station` | `String` | 出发站 |
| `arrival_station` | `String` | 到达站 |
| `vehicle_number` | `String` | 车次/航班号 |
| `seat_info` | `String` | 座位信息 |
| `booking_reference` | `String` | 预订参考号 |
| `departure_location` | `Location` | 出发站点位置 |
| `arrival_location` | `Location` | 到达站点位置 |

#### data 结构：`transport_short`（短途交通）

```json
{
  "type": "transport_short",
  "routes": [{
    "estimated_duration": 1,
    "route_description": "string",
    "navigation_link": "string"
  }],
  "departure_location": { ... },
  "arrival_location": { ... }
}
```

| 参数名 | 类型 | 说明 |
| :--- | :--- | :--- |
| `routes` | `Array[Route]` | 路线列表 |
| `departure_location` | `Location` | 出发位置 |
| `arrival_location` | `Location` | 到达位置 |

| `Route` 子字段 | 类型 | 说明 |
| :--- | :--- | :--- |
| `estimated_duration` | `Integer` | 预估耗时（分钟） |
| `route_description` | `String` | 路线描述 |
| `navigation_link` | `String` | 导航链接 |

#### `Round`（一轮对话）

调用 Agent 的一次完整对话交互过程。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `query` | `String` | 是 | 用户本轮输入的查询指令 / 父 Agent 给子 Agent 的任务描述文本 |
| `final_response` | `String` | 是 | 最终返回给用户的文本回复 |
| `agent` | `String` | 是 | Agent 类型：`supervisor` / `traffic` / `hotel` / `attraction` / `food` |
| `is_delegated` | `Boolean` | 是 | 是否由父 Agent 委托产生。顶层（Supervisor）为 `false`，作为 `steps` 内嵌的 SubAgent 为 `true` |
| `steps` | `Array[Thought\|Tool\|Round]` | 是 | 执行步骤序列（thought / tool / SubAgent 执行轨迹），按时间顺序排列 |
| `metadata` | `AgentMetadata` | 是 | 本轮汇总元数据（整棵树的聚合值，若有子节点需加上子节点的数据） |

#### `AgentMetadata`

Agent 执行的元数据。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `latency_ms` | `Float` | 否 | 本节点总耗时（毫秒） |
| `prompt_tokens` | `Integer` | 否 | 本节点 LLM 调用的 prompt tokens |
| `completion_tokens` | `Integer` | 否 | 本节点 LLM 调用的 completion tokens |
| `llm_model` | `String` | 否 | 本节点使用的模型名称 |
| `is_error` | `Boolean` | 是 | 执行是否产生错误 |
| `error_message` | `String` | 否 | 若 `is_error=true`，记录错误信息 |
| `node_count` | `Integer` | 否 | 整棵树 Agent 节点总数 |
| `tool_count` | `Integer` | 否 | 整棵树所有 tool step 总次数 |
| `delegation_count` | `Integer` | 否 | 整棵树 delegate 调用总次数 |

#### `Thought`

模型思考内容。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `type` | `String` | 是 | 固定为 `"thought"` |
| `content` | `String` | 是 | 思考文本 |

#### `Tool`

工具调用内容。调用 SubAgent 的工具不算做工具调用。

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `type` | `String` | 是 | 固定为 `"tool"` |
| `tool_name` | `String` | 是 | 工具名称，如 `get_travel_plan` / `amap_poi_search` |
| `inputs` | `Object` | 是 | 传给工具的参数字典，为空时传 `{}` |
| `observation` | `String` | 是 | 工具返回的观察结果或错误文本 |
| `is_error` | `Boolean` | 否 | 本次调用是否返回错误，默认 `false` |

```json
{
  "target_metrics": ["avg_latency", "tool_accuracy", "delegation_quality"],
  "rounds": [
    {
      "query": "帮我规划北京3天行程，从上海出发，2人，预算5000元",
      "final_response": "已为您规划好北京3天行程：Day1 高铁G2 上海→北京，入住王府井希尔顿，预算约2500元覆盖交通和住宿。",
      "agent": "supervisor",
      "is_delegated": false,
      "steps": [
        {
          "type": "tool",
          "tool_name": "get_travel_plan",
          "inputs": {},
          "observation": "{\"version\":0,\"items\":[]}",
          "is_error": false
        },
        {
          "type": "thought",
          "content": "计划为空，需要交通和住宿。并行委托 traffic 和 hotel 专家处理。"
        },
        {
          "query": "查询上海到北京的高铁或航班，2人出行",
          "final_response": "推荐高铁G2次 上海虹桥→北京南 553元/人，4.5小时。2人总价1106元。",
          "agent": "traffic",
          "is_delegated": true,
          "steps": [
            {
              "type": "thought",
              "content": "需要查询上海到北京的航班和高铁，对比时间和价格。"
            },
            {
              "type": "tool",
              "tool_name": "variflight_search_flight",
              "inputs": {"departure": "上海", "arrival": "北京", "date": "2026-05-15"},
              "observation": "{\"flights\":[{\"flightNo\":\"CA123\",\"price\":1200,\"duration\":150}]}",
              "is_error": false
            },
            {
              "type": "tool",
              "tool_name": "12306_search_train",
              "inputs": {"departure": "上海", "arrival": "北京", "date": "2026-05-15"},
              "observation": "{\"trains\":[{\"trainNo\":\"G2\",\"price\":553,\"duration\":270}]}",
              "is_error": false
            },
            {
              "type": "thought",
              "content": "高铁G2性价比更高：553元/人 vs 航班1200元/人。2人出行推荐高铁。"
            }
          ],
          "metadata": {
            "latency_ms": 1000,
            "prompt_tokens": 400,
            "completion_tokens": 180,
            "llm_model": "gpt-4o-mini",
            "is_error": false,
            "node_count": 1,
            "tool_count": 2,
            "delegation_count": 0
          }
        },
        {
          "query": "北京住宿推荐，预算每晚500以内，近市中心",
          "final_response": "推荐王府井希尔顿 大床房450元/晚，近天安门，3晚总价1350元。",
          "agent": "hotel",
          "is_delegated": true,
          "steps": [
            {
              "type": "tool",
              "tool_name": "amap_poi_search",
              "inputs": {"keywords": "酒店", "city": "北京", "region": "东城区"},
              "observation": "{\"pois\":[{\"name\":\"王府井希尔顿\",\"price\":450,\"location\":{\"lng\":116.41,\"lat\":39.91}}]}",
              "is_error": false
            }
          ],
          "metadata": {
            "latency_ms": 700,
            "prompt_tokens": 300,
            "completion_tokens": 120,
            "llm_model": "gpt-4o-mini",
            "is_error": false,
            "node_count": 1,
            "tool_count": 1,
            "delegation_count": 0
          }
        },
        {
          "type": "thought",
          "content": "交通和住宿方案已就绪。保存并回复用户。"
        },
        {
          "type": "tool",
          "tool_name": "save_transport_long",
          "inputs": {
            "items": [{
              "name": "上海→北京 高铁G2",
              "start_time": "2026-05-15T08:00:00+08:00",
              "end_time": "2026-05-15T12:30:00+08:00",
              "cost": 1106,
              "transport_mode": "train",
              "departure_station": "上海虹桥",
              "arrival_station": "北京南",
              "vehicle_number": "G2",
              "departure_location": {"poi_id": "shhq", "poi_name": "上海虹桥站", "lng": 121.32, "lat": 31.19},
              "arrival_location": {"poi_id": "bjn", "poi_name": "北京南站", "lng": 116.38, "lat": 39.86}
            }]
          },
          "observation": "{\"status\":\"ok\",\"added\":1}",
          "is_error": false
        },
        {
          "type": "tool",
          "tool_name": "save_hotel",
          "inputs": {
            "items": [{
              "name": "王府井希尔顿",
              "start_time": "2026-05-15T14:00:00+08:00",
              "end_time": "2026-05-18T12:00:00+08:00",
              "cost": 1350,
              "room_type": "大床房",
              "location": {"poi_id": "wfj", "poi_name": "王府井希尔顿", "lng": 116.41, "lat": 39.91}
            }]
          },
          "observation": "{\"status\":\"ok\",\"added\":1}",
          "is_error": false
        }
      ],
      "metadata": {
        "latency_ms": 3800,
        "prompt_tokens": 1900,
        "completion_tokens": 650,
        "llm_model": "gpt-4o-mini",
        "is_error": false,
        "node_count": 3,
        "tool_count": 5,
        "delegation_count": 2
      }
    }
  ]
}
```

#### 响应示例

```json
{
  "results": [
    {
      "metric_name": "avg_latency",
      "score": 1500,
      "reason": "全局共有 1 个有效轮次记录耗时, Session平均延迟为 1500.00 ms",
      "status": "success"
    }
  ]
}
```

```json
{
  "results": [
    {
      "metric_name": "avg_latency",
      "score": null,
      "reason": "评估计算超时 (Timeout)",
      "status": "timeout"
    }
  ]
}
```
