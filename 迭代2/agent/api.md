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
| `callback_path` | String | 否 | 回调接口路径，用于在请求结束后， Agent 向请求者回调该轮对话的轨迹，只需提供相对路径，域名在配置文件中确定，若不提供则不调用接口并回传会话数据 |
| `callback_id` | Integer | 否 | 回调 id，用于在请求结束后， Agent 向请求者回调该轮对话的轨迹，若不提供则不调用接口并回传会话数据 |
| `metadata` | Object | 否 | 业务透传上下文（如地理位置、语言偏好、时区、请求来源等），方便注入到内部大模型请求和工具逻辑中 |

#### 请求示例

```json
{
  "messages": [
    {"role": "system", "content": "你是一个助理"},
    {"role": "user", "content": "帮我规划北京3天行程"}
  ],
  "stream": true,
  "schedule_id": 1001,
  "callback_path": "/xxx/yyy/111",
  "callback_id": 123,
  "metadata": {
    "user_id": "u_1001",
    "location": "北京",
    "timezone": "Asia/Shanghai"
  }
}
```

#### 响应说明

系统通过 SSE 推送事件。所有事件体包含 `node` 字段标明发出该事件的 Agent 节点，全局事件由 `Orchestrator` 作为节点名。

LLM 的调用存在嵌套关系，Supervisor 调用 SubAgent（如交通专家）时，SubAgent 的事件会通过 `parent` 字段指向调用它的 Supervisor Agent，从而形成事件树结构，便于追踪整个推理过程和工具调用链路。

以下是常见事件类型说明：

| 事件 | node | 说明 |
| ------ | ------ | ------ |
| `node_start` | Agent 名 | Agent 开始执行。`id` 唯一标识，可选 `parent` 指向父 Agent |
| `node_finish` | Agent 名 | Agent 执行完毕。含 `status`：`success` / `timeout` / `failed` |
| `thought` | Agent 名 | Agent 内部思考过程的增量输出（delta） |
| `tool_call` | Agent 名 | 工具调用。SubAgent 调用通过 `delegate_*` 工具名表达 |
| `tool_result` | Agent 名 | 工具调用结果返回 |
| `message_delta` | Supervisor | 呈现给用户的最终文本增量 |
| `error` | 任意 | 系统或工具报错、超时异常的结构化错误信息。`error` 事件后必定跟随一个 `done` 事件（`status: "error"`）作为流的终结 |
| `done` | Orchestrator | 整个流程执行完毕，**始终是流的最后一个事件**。成功时含 `status: "success"` 和 `usage`（prompt/completion/total tokens）；失败时含 `status: "error"` 和 `message`（错误描述）。客户端应以 `done` 作为流结束信号 |

#### SSE 响应示例

```text
event: node_start
data: {"node": "Supervisor", "id": "s_1", "msg": "start"}

event: thought
data: {"node": "Supervisor", "content": "用户需要北京3天行程，先查看已有计划再决定分配哪些专家。"}

event: tool_call
data: {"node": "Supervisor", "call_id": "call_1", "tool_name": "get_travel_plan", "params": {"schedule_id": 1001}}

event: tool_result
data: {"node": "Supervisor", "call_id": "call_1", "result": "{\"schedule_id\": 1001, \"content\": \"\"}"}

event: thought
data: {"node": "Supervisor", "content": "尚无计划，需要交通和酒店专家协助。"}

event: tool_call
data: {"node": "Supervisor", "call_id": "call_2", "tool_name": "delegate_traffic", "params": {"task": "规划北京往返交通"}}

event: tool_call
data: {"node": "Supervisor", "call_id": "call_3", "tool_name": "delegate_hotel", "params": {"task": "推荐北京酒店"}}

event: node_start
data: {"node": "traffic", "id": "t_1", "parent": "s_1", "msg": "start"}

event: tool_call
data: {"node": "traffic", "call_id": "call_4", "tool_name": "variflight_search", "params": {"dest": "PEK"}}

event: tool_result
data: {"node": "traffic", "call_id": "call_4", "result": "..."}

event: node_finish
data: {"node": "traffic", "id": "t_1", "status": "success"}

event: tool_result
data: {"node": "Supervisor", "call_id": "call_2", "result": "交通方案：..."}

event: node_finish
data: {"node": "hotel", "id": "h_1", "parent": "s_1", "status": "success"}

event: tool_result
data: {"node": "Supervisor", "call_id": "call_3", "result": "酒店方案：..."}

event: thought
data: {"node": "Supervisor", "content": "交通和酒店方案已就绪，整合写入黑板。"}

event: tool_call
data: {"node": "Supervisor", "call_id": "call_5", "tool_name": "write_travel_plan", "params": {"schedule_id": 1001, "content": "# 北京3日游\n..."}}

event: tool_result
data: {"node": "Supervisor", "call_id": "call_5", "result": "{\"schedule_id\": 1001, \"status\": \"ok\"}"}

event: message_delta
data: {"node": "Supervisor", "content": "已为您规划好北京3天行程，包括往返交通和酒店住宿..."}

event: node_finish
data: {"node": "Supervisor", "id": "s_1", "status": "success"}

event: done
data: {"node": "Orchestrator", "status": "success", "usage": {"prompt_tokens": 3200, "completion_tokens": 800, "total_tokens": 4000}}
```

### 简易聊天

- 功能说明：轻量级对话接口，用户传入一段纯文本输入，Agent 处理后以纯文本字符串返回结果。不支持流式输出，适合一次性问答、命令行工具、脚本集成等简单场景。
- 接口地址: `POST /chat/simple`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`（目前 `token` 无限制，填写任意字符串即可）

#### 请求Body

| 字段名 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `content` | String | 是 | 用户输入的聊天内容，以纯文本字符串形式传入。 |

#### 请求示例

```json
{
  "content": "帮我规划北京3天行程"
}
```

#### 响应Body

| 字段名 | 类型 | 描述 |
| --- | --- | --- |
| `content` | String | Agent 返回的回复内容。 |

#### 响应示例

**成功：**

```json
{
  "content": "已为您规划好北京3天行程，包括往返交通和酒店住宿..."
}
```

**错误：**

```json
{
  "detail": "Internal error: Backend API error: 401"
}
```


#### 错误响应示例

当 setup 阶段（如计划读取失败）或 LLM 循环中发生异常时，流以 `error` + `done` 结束，不会中断 SSE 连接：

```text
event: error
data: {"node": "Orchestrator", "code": 500, "message": "Backend API error: 401"}

event: done
data: {"node": "Orchestrator", "status": "error", "message": "Backend API error: 401"}
```
