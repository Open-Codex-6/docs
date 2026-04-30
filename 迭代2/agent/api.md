# API 接口文档

## 基础地址

`baseUrl`: `https://agent-base.cos.tg/api/v1`

## 核心会话接口

### 发起对话

- 功能说明：将 Agent 作为一个无状态的推理服务调用。主业务后端需要将完整的历史上下文通过 `messages` 数组全量传入；若需要与旅行计划联动，请传入 `schedule_id` 以绑定旅行计划。
- 接口地址: `POST /chat/completions`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`（目前 `token` 无限制，填写任意字符串即可）

#### 请求Body

| 字段名 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `messages` | Array | 是 | 完整的对话上下文历史，严格参考 OpenAI 规范（支持 `system`, `user`, `assistant`, `tool` 等 role）。 |
| `stream` | Boolean | 否 | 是否开启流式输出，目前仅支持 `true` |
| `agent_id` | String | 否 | 指定使用的智能体应用 ID（用于加载后端写死的系统 Prompt 和默认工具集） |
| `schedule_id` | Integer | 否 | 旅行计划标识，用于读取与写入旅行计划；若不提供则仅作临时对话，不更改旅行计划 |
| `metadata` | Object | 否 | 业务透传上下文（如地理位置、语言偏好、时区、请求来源等），方便注入到内部大模型请求和工具逻辑中 |

#### 请求示例

```json
{
  "messages": [
    {"role": "system", "content": "你是一个助理"},
    {"role": "user", "content": "我是张三"},
    {"role": "assistant", "content": "你好张三，有什么可以帮你的？"},
    {"role": "user", "content": "帮我查一下外面的天气"}
  ],
  "stream": true,
  "schedule_id": 1001,
  "metadata": {
    "user_id": "u_1001",
    "location": "北京",
    "timezone": "Asia/Shanghai"
  }
}
```

#### 响应说明

- 为了实时返回当前状态，适应 Multi-Agent 图结构并发，系统会通过 SSE 推送不同 `event`，所有事件体中均新增 `node` 字段标明发出该事件的 Agent 节点；若是全局事件则由 `Orchestrator` 作为节点名。
- 常见的事件类型
  - `node_start`: 某个 Agent 节点（如 Supervisor, TrafficAgent）开始执行任务
  - `task_delegated`: Supervisor 成功进行任务拆解并下发给各个 Worker 时触发
  - `thought`: 对应 `node` 的内部思考过程的增量输出（delta 支持并行复用展示）
  - `tool_call`: 某个 `node` 触发了工具调用，且携带全局唯一的 `call_id`
  - `tool_result`: 工具调用的结果返回
  - `plan_update`: Supervisor 决定更新旅行计划行程时的事件，告知前端刷新展示（`content` 为全量 Markdown）
  - `message_delta`: Supervisor 组装并呈现给用户的最终文本增量响应
  - `node_finish`: 某个 Agent 节点执行完毕，可包含 `status`（`success` | `timeout` | `failed`）
  - `error`: 系统或工具报错、超时异常时触发的结构化错误信息（包含 `node`，用于前端定位）
  - `done`: 整个图流转执行完毕，返回全局 Token 损耗
- 超时处理说明：若某个 Worker 超时，服务会先返回 `node_finish` 并标记 `status=timeout`，必要时追加 `error` 事件用于排错。
- 参考文档
  - <https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events>
  - <https://en.wikipedia.org/wiki/Server-sent_events>
- SSE 响应示例（展示并发流转）

```text
event: node_start
data: {"node": "Supervisor", "msg": "主管节点开始接收任务"}

event: thought
data: {"node": "Supervisor", "content": "用户需要北京3天行程。我需要下发给交通和酒店Agent。"}

event: task_delegated
data: {"node": "Supervisor", "tasks": [{"agent": "TrafficAgent", "task": "查北京往返航班"}, {"agent": "HotelAgent", "task": "查天安门附近的酒店"}]}

event: node_start
data: {"node": "TrafficAgent", "msg": "开始执行"}

event: node_start
data: {"node": "HotelAgent", "msg": "开始执行"}

event: tool_call
data: {"node": "TrafficAgent", "call_id": "call_1", "tool_name": "get_flights", "params": {"dest": "PEK"}}

event: tool_call
data: {"node": "HotelAgent", "call_id": "call_2", "tool_name": "search_hotels", "params": {"poi": "天安门"}}

event: tool_result
data: {"node": "TrafficAgent", "call_id": "call_1", "result": "航班列表..."}

event: node_finish
data: {"node": "TrafficAgent", "msg": "交通提案已提交"}

event: node_finish
data: {"node": "HotelAgent", "msg": "酒店提案已提交"}

event: plan_update
data: {"node": "Supervisor", "schedule_id": 1001, "content": "### Day 1\n- 抵达北京首都机场..."}

event: message_delta
data: {"node": "Supervisor", "content": "我已经为您规划好了大致的北京行程，安排了..."}

event: done
data: {"node": "Orchestrator", "status": "success", "usage": {"prompt_tokens": 1500, "completion_tokens": 400, "total_tokens": 1900}}
```
