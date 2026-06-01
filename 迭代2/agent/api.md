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
| `tool_ids` | Array\<String\> | 否 | 允许本次对话使用的工具名称白名单（如 `["amap_search_poi", "variflight_query_flight"]`）。提供时仅有列表中的工具会暴露给 LLM；不提供或传 `null` 则默认开放全部工具。与后端 YAML 配置的 per-agent 工具过滤取交集，名单中不存在的工具名会被静默忽略。 |
| `files` | Array\<FileAttachment\> | 否 | 随本次对话附带的文件（图片或 PDF），以 Base64 编码传入，内容会注入到最后一条 `user` 消息中。支持的格式：`image/jpeg`、`image/png`、`image/webp`、`image/gif`、`application/pdf`；传入不支持的 `media_type` 将返回 HTTP 400。 |
| `callback_path` | String | 否 | 本轮对话 Trace 的回调路径（相对于 `BACKEND_API_BASE_URL`）。需与 `callback_id` 同时提供，对话完成后服务端会向该地址 POST 结构化 Trace 数据。 |
| `callback_id` | Integer | 否 | 对应本轮问答的 `question_id`，随 Trace 数据一同回传给 `callback_path`。 |

#### tool_ids 可选值

工具名称分为三类，使用时填写下表中的 `工具名` 字段值：

**本地工具**（固定可用，不依赖外部服务）

| 工具名 | 说明 | 是否可禁用 |
| --- | --- | --- |
| `get_travel_plan` | 读取当前旅行计划（返回结构化 JSON） | 否 |
| `save_attraction` | 保存景点类计划项 | 否 |
| `save_hotel` | 保存酒店类计划项 | 否 |
| `save_food` | 保存餐饮类计划项 | 否 |
| `save_transport_long` | 保存长途交通类计划项（航班/火车/客车/轮渡） | 否 |
| `save_transport_short` | 保存市内交通类计划项 | 否 |

**子 Agent 委托工具**（Supervisor 层可用，触发后由对应 Worker Agent 执行）

| 工具名 | 说明 | 是否可禁用 |
| --- | --- | --- |
| `delegate_traffic` | 委托交通规划专家（查长途航班、火车等） | 否 |
| `delegate_local_transport` | 委托市内出行专家（查市内路线、导航等） | 否 |
| `delegate_hotel` | 委托酒店住宿专家 | 否 |
| `delegate_attraction` | 委托景点游玩专家 | 否 |
| `delegate_food` | 委托美食餐饮专家 | 否 |

**MCP 外部工具**（名称由 MCP Server 动态提供，以固定前缀区分来源）

| 前缀 | 来源 | 说明 | 是否可禁用 |
| --- | --- | --- | --- |
| `amap_` | 高德地图 MCP | POI 搜索、路线规划、地理编码等地图服务 | 否 |
| `variflight_` | Variflight MCP | 航班信息查询 | 是 |
| `12306_` | 12306 MCP | 高铁/火车票信息查询 | 是 |

> 注：MCP 工具的完整名称（如 `amap_search_poi`）由对应 MCP Server 在运行时注册，可通过观察 SSE 事件流中的 `tool_call` 事件的 `tool_name` 字段获取实际名称。

#### FileAttachment 对象

| 字段名 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `data` | String | 是 | 文件内容的 Base64 编码字符串。 |
| `media_type` | String | 是 | 文件 MIME 类型，支持 `image/jpeg`、`image/png`、`image/webp`、`image/gif`、`application/pdf`。 |
| `filename` | String | 否 | 文件名，用于日志记录；PDF 上传时作为 OpenAI Files API 的文件名（默认 `document.pdf`）。 |


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
  },
  "tool_ids": ["amap_search_poi", "variflight_query_flight"],
  "files": [
    {
      "data": "<base64编码内容>",
      "media_type": "image/jpeg",
      "filename": "photo.jpg"
    }
  ]

}
```

#### 响应说明

系统通过 SSE 推送事件。所有事件体包含 `node` 字段标明发出该事件的 Agent 节点，全局事件由 `Orchestrator` 作为节点名。

> `node` 和 `tool_name` 字段已经过 `display_names.yaml` 映射为用户友好的中文名称（如 `"traffic"` → `"交通规划专家"`、`"amap_poi_search"` → `"地图服务"`）。未配置映射的名称保持原名。

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
data: {"node": "行程规划主管", "id": "s_1", "msg": "start"}

event: thought
data: {"node": "行程规划主管", "content": "用户需要北京3天行程，先查看已有计划再决定分配哪些专家。"}

event: tool_call
data: {"node": "行程规划主管", "call_id": "call_1", "tool_name": "读取行程计划", "params": {"schedule_id": 1001}}

event: tool_result
data: {"node": "行程规划主管", "call_id": "call_1", "result": "{\"schedule_id\": 1001, \"content\": \"\"}"}

event: thought
data: {"node": "行程规划主管", "content": "尚无计划，需要交通和酒店专家协助。"}

event: tool_call
data: {"node": "行程规划主管", "call_id": "call_2", "tool_name": "委托交通专家", "params": {"task": "规划北京往返交通"}}

event: tool_call
data: {"node": "行程规划主管", "call_id": "call_3", "tool_name": "委托酒店专家", "params": {"task": "推荐北京酒店"}}

event: node_start
data: {"node": "交通规划专家", "id": "t_1", "parent": "s_1", "msg": "start"}

event: tool_call
data: {"node": "交通规划专家", "call_id": "call_4", "tool_name": "航班查询", "params": {"dest": "PEK"}}

event: tool_result
data: {"node": "交通规划专家", "call_id": "call_4", "result": "..."}

event: node_finish
data: {"node": "交通规划专家", "id": "t_1", "status": "success"}

event: tool_result
data: {"node": "行程规划主管", "call_id": "call_2", "result": "交通方案：..."}

event: node_finish
data: {"node": "酒店住宿专家", "id": "h_1", "parent": "s_1", "status": "success"}

event: tool_result
data: {"node": "行程规划主管", "call_id": "call_3", "result": "酒店方案：..."}

event: thought
data: {"node": "行程规划主管", "content": "交通和酒店方案已就绪，整合写入黑板。"}

event: tool_call
data: {"node": "行程规划主管", "call_id": "call_5", "tool_name": "保存长途交通", "params": {"schedule_id": 1001, "content": "# 北京3日游\n..."}}

event: tool_result
data: {"node": "行程规划主管", "call_id": "call_5", "result": "{\"schedule_id\": 1001, \"status\": \"ok\"}"}

event: message_delta
data: {"node": "行程规划主管", "content": "已为您规划好北京3天行程，包括往返交通和酒店住宿..."}

event: node_finish
data: {"node": "行程规划主管", "id": "s_1", "status": "success"}

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

## 工具查询接口

### 查询可禁用工具

- 功能说明：返回当前系统中所有支持被禁用的工具列表。可禁用工具均为 MCP 外部工具，前端可据此渲染开关控件，供用户按需关闭对应服务。
- 接口地址: `GET /tools/disableable`
- 请求头
  - `Authorization: Bearer <token>`

#### 响应Body

| 字段名 | 类型 | 描述 |
| --- | --- | --- |
| `tools` | Array\<DisableableTool\> | 可禁用工具列表 |

**DisableableTool 对象**

| 字段名 | 类型 | 描述 |
| --- | --- | --- |
| `prefix` | String | 工具名称前缀（如 `variflight_`、`12306_`） |
| `source` | String | MCP 服务来源名称 |
| `description` | String | 该工具组的功能说明 |

#### 响应示例

```json
{
  "tools": [
    {
      "prefix": "variflight_",
      "source": "Variflight MCP",
      "description": "航班信息查询"
    },
    {
      "prefix": "12306_",
      "source": "12306 MCP",
      "description": "高铁/火车票信息查询"
    }
  ]
}
```
