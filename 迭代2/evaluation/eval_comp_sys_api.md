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
| `target_metrics` | `Array[String]` | 是 | 要触发的评价指标列表 (例如: `["avg_latency"]`)。 |
| `rounds` | `Array[Round]` | 是 | 会话内的多轮对话交互与执行记录，Agent 后端在一次问答结束后，记录该次问答对应的 `Round` 数据，评测平台可从 Agent 数据库中导出对话的 `rounds` |

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
      "score": null,
      "reason": "评估计算超时 (Timeout)",
      "status": "timeout"
    }
  ]
}
```
