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
| `selections` | Array\<SelectionItem\> | 否 | 本次对话允许使用的工具/技能/智能体白名单。提供时仅有列表中的项目会生效；不提供或传 `null` 则默认开放全部。工具类型与后端 YAML 配置的 per-agent 过滤取交集，列表中不存在的 id 会被静默忽略。详见 SelectionItem 对象定义。 |
| `files` | Array\<FileAttachment\> | 否 | 随本次对话附带的文件（图片或 PDF），以 Base64 编码传入，内容会注入到最后一条 `user` 消息中。支持的格式：`image/jpeg`、`image/png`、`image/webp`、`image/gif`、`application/pdf`；传入不支持的 `media_type` 将返回 HTTP 400。 |
| `user_profile` | UserProfile | 否 | 当前用户画像，Agent 在规划过程中可参考用户偏好、习惯等信息，提升个性化程度；详见 UserProfile 对象定义。不提供则按无偏好信息处理。 |
| `profile_callback_path` | String | 否 | 用户画像回调接口的相对路径。对话结束后，若 Agent 依据本次交互对用户画像有更新，则向该路径发起回调，将更新后的 UserProfile 写回业务后端；只需提供相对路径，域名在配置文件中确定。不提供则不回调。 |


#### SelectionItem 对象

| 字段名 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `type` | String | 是 | 类型，枚举值：`"tool"`（外部工具）、`"skill"`（技能）、`"subagent"`（子智能体） |
| `id` | String | 是 | 对应类型的标识符，与 `GET /tools/options` 返回的 `id` 字段一致 |

**SelectionItem 示例**

```json
[
  { "type": "tool", "id": "variflight_" },
  { "type": "skill", "id": "new_trip_planning" },
  { "type": "subagent", "id": "traffic" }
]
```


#### FileAttachment 对象

| 字段名 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `data` | String | 是 | 文件内容的 Base64 编码字符串。 |
| `media_type` | String | 是 | 文件 MIME 类型，支持 `image/jpeg`、`image/png`、`image/webp`、`image/gif`、`application/pdf`。 |
| `filename` | String | 否 | 文件名，用于日志记录；PDF 上传时作为 OpenAI Files API 的文件名（默认 `document.pdf`）。 |


#### UserProfile 对象

用户画像用于在对话中向 Agent 注入用户的长期偏好与历史信息，所有字段均为可选，Agent 应仅参考已存在的字段。

| 字段名 | 类型 | 描述 |
| --- | --- | --- |
| `pace` | String | 出行节奏偏好，枚举值：`"relaxed"`（慢节奏，每天不超过 2 个景点）、`"moderate"`（适中）、`"intensive"`（高密度，每天 4 个以上景点）。 |
| `budget_level` | String | 预算档次偏好，枚举值：`"budget"`（经济型）、`"mid-range"`（舒适型）、`"luxury"`（豪华型）。 |
| `interests` | Array\<String\> | 兴趣标签列表，如 `["历史文化", "自然风景", "购物", "美食体验", "摄影"]`。 |
| `food_preferences` | Array\<String\> | 餐饮偏好标签，如 `["本地特色", "素食", "海鲜", "辣食"]`。 |
| `disliked_things` | Array\<String\> | 不喜欢或希望回避的内容，如 `["过于商业化的景点", "人多的地方", "早班机"]`。 |
| `accommodation` | AccommodationPreference | 住宿偏好，详见子对象定义。 |
| `transport` | TransportPreference | 交通偏好，详见子对象定义。 |
| `physical_level` | String | 体力/运动能力，枚举值：`"low"`（不适合长距离步行）、`"medium"`（一般）、`"high"`（可接受高强度徒步）。 |
| `group_type` | String | 常见出行类型，枚举值：`"solo"`、`"couple"`、`"family"`（含老人或儿童）、`"friends"`。 |
| `typical_trip_duration` | Integer | 常见出行天数（天），用于辅助判断行程疏密。 |
| `past_destinations` | Array\<String\> | 曾经去过的目的地城市/地区列表，如 `["北京", "上海", "成都"]`，避免重复推荐相同景点。 |
| `notes` | String | 纯文本备注，用于记录结构化字段无法涵盖的个性化信息，如特殊需求、过往旅行中的具体经历、对某次行程的感受等。Agent 规划时应参考此字段。 |

**AccommodationPreference 子对象**

| 字段名 | 类型 | 描述 |
| --- | --- | --- |
| `min_star` | Integer | 最低可接受星级（1–5）。 |
| `preferred_room_type` | String | 偏好房型，如 `"大床房"`、`"双床房"`。 |

**TransportPreference 子对象**

| 字段名 | 类型 | 描述 |
| --- | --- | --- |
| `avoid_overnight` | Boolean | 是否回避夜班车/红眼航班，`true` 表示回避。 |
| `preferred_modes` | Array\<String\> | 偏好的交通方式，枚举值：`"flight"`、`"train"`、`"coach"`、`"ferry"`。 |

**UserProfile 示例**

```json
{
  "pace": "moderate",
  "budget_level": "mid-range",
  "interests": ["历史文化", "自然风景", "美食体验"],
  "food_preferences": ["本地特色", "海鲜"],
  "disliked_things": ["早班机", "过于商业化的景点"],
  "accommodation": {
    "min_star": 4,
    "preferred_room_type": "大床房"
  },
  "transport": {
    "avoid_overnight": true,
    "preferred_modes": ["train", "flight"]
  },
  "physical_level": "medium",
  "group_type": "couple",
  "typical_trip_duration": 5,
  "past_destinations": ["北京", "上海", "成都"],
  "notes": "对人多的热门景点兴趣不大，偏好小众路线；上次去成都时对火锅印象极好，希望每次旅行都能安排一顿当地特色火锅类菜肴。"
}
```


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
  "selections": [
    { "type": "tool", "id": "amap_" },
    { "type": "tool", "id": "variflight_" },
    { "type": "skill", "id": "new_trip_planning" },
    { "type": "subagent", "id": "traffic" }
  ],
  "user_profile": {
    "pace": "moderate",
    "budget_level": "mid-range",
    "interests": ["历史文化", "自然风景"],
    "food_preferences": ["本地特色"],
    "disliked_things": ["早班机"],
    "accommodation": { "min_star": 4, "preferred_room_type": "大床房" },
    "transport": { "avoid_overnight": true, "preferred_modes": ["train", "flight"] },
    "physical_level": "medium",
    "group_type": "couple",
    "typical_trip_duration": 5,
    "past_destinations": ["上海", "成都"],
    "notes": "偏好小众路线，不喜欢人多的热门景点。"
  },
  "profile_callback_path": "/api/profile/update",
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

### 查询可用工具/技能/智能体

- 功能说明：返回当前系统中所有可供用户选择的工具、技能（skill）和子智能体（subagent）列表，前端可据此渲染选项控件，供用户按需启用或禁用。每项均包含 `type` 字段标识其类型，工具类项目额外含 `name` 字段。
- 接口地址: `GET /tools/options`
- 请求头
  - `Authorization: Bearer <token>`

#### 响应Body

返回一个列表，每项包含以下字段：

| 字段名 | 类型 | 适用类型 | 描述 |
| --- | --- | --- | --- |
| `type` | String | 全部 | 类型标识，枚举值：`"tool"`、`"skill"`、`"subagent"` |
| `id` | String | 全部 | 标识符，与 `selections` 传参时的 `id` 一致。工具类为前缀（如 `variflight_`），技能和子智能体为名称（如 `new_trip_planning`、`traffic`） |
| `name` | String | `tool` | 工具显示名称，取自 `display_names.yaml`（如"航班查询"）；`skill` 和 `subagent` 类型无此字段 |
| `description` | String | 全部 | 功能描述 |

#### 响应示例

```json
[
  {
    "type": "tool",
    "id": "variflight_",
    "name": "航班查询",
    "description": "航班信息查询"
  },
  {
    "type": "tool",
    "id": "12306_",
    "name": "铁路查询",
    "description": "高铁/火车票信息查询"
  },
  {
    "type": "tool",
    "id": "amap_",
    "name": "地图服务",
    "description": "POI 搜索、路线规划等地图功能"
  },
  {
    "type": "skill",
    "id": "new_trip_planning",
    "description": "从零规划完整旅行，适用于用户尚无行程、需要系统性制定出行计划的场景。"
  },
  {
    "type": "skill",
    "id": "budget_optimization",
    "description": "在用户明确预算上限的场景下，以性价比为核心目标进行旅行规划或方案调整。"
  },
  {
    "type": "skill",
    "id": "itinerary_modification",
    "description": "对已有行程进行局部增删或调整，适用于修改既有计划的场景。"
  },
  {
    "type": "skill",
    "id": "emergency_handling",
    "description": "处理行程中的突发情况（如航班取消、酒店变更等），快速给出应对方案。"
  },
  {
    "type": "subagent",
    "id": "traffic",
    "description": "交通规划专家，负责长途交通（机票/火车票）的查询与规划。"
  },
  {
    "type": "subagent",
    "id": "local_transport",
    "description": "市内出行专家，负责目的地内各景点间的短途交通规划。"
  },
  {
    "type": "subagent",
    "id": "hotel",
    "description": "酒店住宿专家，负责搜索和推荐符合需求的住宿方案。"
  },
  {
    "type": "subagent",
    "id": "attraction",
    "description": "景点游玩专家，负责按天数和偏好规划景点游览安排。"
  },
  {
    "type": "subagent",
    "id": "food",
    "description": "美食餐饮专家，负责为行程安排特色餐饮推荐。"
  }
]
```
