# Agent Eval API 接口文档

## 评测模块

### 提交评测任务

**功能说明**：提交 Agent 的多轮对话执行轨迹（包含工具调用与耗时记录等），并根据指定的评价指标列表进行异步高并发计算，返回各项指标的评测结果。

**接口地址**: `POST /api/v1/evaluate`

**请求头**

* Content-Type: `application/json`

**请求参数**

*ps : 实际上根据不同指标的计算逻辑，不是每个属性都必须填写，后续会更新每个指标必须要有的属性，传入可以考虑将值设置为空,例如可以参考下面的样例，只需要metadata里面的latency_ms不为空即可满足要求*

```
{
  "target_metrics": [
    "avg_latency"
  ],
  "rounds": [
    {
      "user_query": "",
      "agent_response": "",
      "tools": [
        {
          "name": "",
          "inputs": {},
          "observation": "",
          "thought": ""
        }
      ],
      "metadata": {
        "latency_ms": 666.0,
        "tokens_used": 6
      }
    }
  ]
}
```

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| target_metrics | Array[String] | 是 | 要触发的评价指标列表 (例如: `["avg_latency"]`)。 |
| rounds | Array[Object] | 是 | 会话内的多轮对话交互与执行记录 |

*`rounds` 数组内对象的属性说明（Round）：*

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| user_query | String | 是 | 用户的查询指令内容 |
| agent_response | String | 是 | Agent的文本回复内容 |
| tools | Array[Object] | 是 | 本轮执行的工具调用列表，具体结构参考下方 `tools` 属性说明 |
| metadata | Object | 是 | 这轮对话的附带元数据 (可包含 `latency_ms`[Float], `tokens_used`[Integer] 等属性) |

*`tools` 数组内对象的属性说明（ToolCall）：*

| 参数名 | 类型 | 是否必填 | 说明 |
| :--- | :--- | :--- | :--- |
| name | String | 是 | 实际调用的工具或函数名称，例如 `search_hotel` |
| inputs | Object | 是 | 传给工具请求的具体参数 JSON 字典 (例如 `{"location": "北京", "price": 500}`)，为空时传 `{}` |
| observation | String | 是 | 平台调用该工具后返回的观察结果或错误信息文本 |
| thought | String | 是 | Agent 在下发工具调用前的思考（Thought）或内部 Chain of Thought 信息 |

**请求示例**

```json
{
  "target_metrics": [
    "avg_latency"
  ],
  "rounds": [
    {
      "user_query": "帮我查一下今天去北京的机票",
      "agent_response": "为您找到今天飞往北京的航班：CA123，价格1200元。",
      "tools": [
        {
          "name": "search_flight",
          "inputs": {
            "date": "today",
            "destination": "Beijing"
          },
          "observation": "{\"flight\": \"CA123\", \"price\": 1200}",
          "thought": "我需要调用查票工具来获取今天的航班"
        }
      ],
      "metadata": {
        "latency_ms": 1500,
        "tokens_used": 200
      }
    }
  ]
}
```

**响应示例 (成功 200 OK)**

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

**响应示例 **

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
