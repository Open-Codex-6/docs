# API 接口文档

## 基础地址

`baseUrl`: `/api/v1`

## 核心会话接口

### 发起对话

- 功能说明：将 Agent 作为一个无状态的推理服务调用。主业务后端需要将完整的历史上下文通过 `messages` 数组全量传入。系统实时返回当前状态（如调用工具中、思考中等）并最终给出 Response。
- 接口地址: `POST /chat/completions`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`（目前 `token` 无限制，填写任意字符串即可）

#### 请求Body

| 字段名 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `messages` | Array | 是 | 完整的对话上下文历史，严格参考 OpenAI 规范（支持 `system`, `user`, `assistant`, `tool` 等 role）。 |
| `stream` | Boolean | 否 | 是否开启流式输出，必须设为 true 以获取状态反馈 |
| `agent_id` | String | 否 | 指定使用的智能体应用 ID（用于加载后端写死的系统 Prompt 和默认工具集） |
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
  "metadata": {
    "user_id": "u_1001",
    "location": "北京",
    "timezone": "Asia/Shanghai"
  }
}
```

#### 响应说明

- 为了实时返回当前状态，系统会通过 SSE 推送不同 `event`
- 常见的事件类型
  - `thought`: Agent 的内部思考过程的增量输出模式（delta 模式，避免思考链路过长导致长时空白）
  - `tool_call`: 触发了工具调用，携带全局唯一的 `call_id`，支持并发工具调用的精确匹配
  - `tool_result`: 工具调用的执行结果返回，携带对应的 `call_id`
  - `message_delta`: 组装最终呈现给用户的文本增量
  - `error`: 系统或工具报错、超时异常时触发的结构化错误信息
  - `done`: 整个链路执行完毕，会返回由于计费和性能监控所需的 Token 使用统计量
- 参考文档
  - <https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events>
  - <https://en.wikipedia.org/wiki/Server-sent_events>
- SSE 响应示例

```text
event: thought
data: {"content": "用户需要查询今日天气，"}

event: thought
data: {"content": "我需要先调用天气预报工具。"}

event: tool_call
data: {"call_id": "call_H9aL2n8N", "tool_name": "get_weather", "params": {"date": "today", "location": "北京"}}

event: tool_result
data: {"call_id": "call_H9aL2n8N", "result": "气温25-30度，晴天"}

event: message_delta
data: {"content": "今天北京天气很不错，是晴天，"}

event: message_delta
data: {"content": "气温在25-30度之间。"}

event: done
data: {"status": "success", "usage": {"prompt_tokens": 150, "completion_tokens": 85, "total_tokens": 235}}

event: error
data: {"code": 500, "message": "Weather API timeout"}
```
