# Agent APP API 接口文档

接口响应中的`msg`字段的类型说明

| 内容 | 说明 |
| -- | -- |
| `SUCCESS` | 请求成功 |
| `INVALID_REQUEST` | 参数不合法 |
| `UNAUTHORIZED` | `token`失效 |

## 用户模块

### 创建用户

- 功能说明：创建新用户。
- 接口地址: `POST /api/accounts`
- 请求头
  - `Content-Type: application/json`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `username` | `String` | 是 | 用户名 |
| `password` | `String` | 是 | 密码 |

#### 请求示例

```json
{
    "username": "testuser",
    "password": "123456"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": 2
}
```

```json
{
    "code": "400",
    "msg": "INVALID_REQUEST:创建失败",
    "data": null
}
```

### 登录

- 功能说明：用户登录。
- 接口地址: `POST /api/accounts/login`
- 请求头
  - `Content-Type: application/json`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `username` | `String` | 是 | 用户名 |
| `password` | `String` | 是 | 密码 |

#### 请求示例

```json
{
    "username": "testuser",
    "password": "123456"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1IiwiZXhwIjoxNzQyOTAwNDUwfQ.R_GtVrXmg8E_hGjUY4Gm_zFKVCg0Dy8jWreAAmJrvCM"
}
```

```json
{
    "code": "400",
    "msg": "INVALID_REQUEST:用户不存在/用户密码错误",
    "data": null
}
```

### 更新用户信息

- 功能说明：更新用户信息。
- 接口地址: `PUT /api/accounts`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
    - 说明：`token`来自于login返回的`data`，若第一次`update`成功而后续失败，则为`token`已过期需重新login获取`token`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `username` | `String` | 是 | 用户名 |
| `password` | `String` | 是 | 密码 |

#### 请求示例

```json
{
    "username": "testuser",
    "password": "newpassword"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": "用户信息更新成功"
}
```

```json
{
    "code": "400",
    "msg": "UNAUTHORIZED:token与输入的用户名不匹配",
    "data": null
}
```

```json
{
    "code": "400",
    "msg": "INVALID_REQUEST:更新失败",
    "data": null
}
```

## 行程模块

### 创建行程

- 功能说明：创建一个新的行程，同时会自动创建一个初始对话和一个初始版本的旅行计划
- 接口地址：`POST /api/schedule`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `name` | `String` | 否 | 名字，默认值为“默认行程名” |

#### 请求示例

```json
{
    "name": "神秘初始行程自定义名111"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": 1//行程id
}
```

### 更改行程名

- 功能说明：同接口名
- 接口地址：`PUT /api/schedule`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型     | 是否必填 | 说明     |
| ------ | -------- | -------- | -------- |
| `id`   | `int`    | 是       | 行程`id` |
| `name` | `String` | 是       | 新名字   |

#### 请求示例

```json
{
    "id": 1,
    "name": "神秘初始行程自定义名222"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": "更新成功"
}
```

### 获取行程列表

- 功能说明：获取当前登录下的token的行程列表，按照时间排序，最新的在最上面，考虑迭代三加入分页，需要提供页的大小和第几页两个信息，暂定
- 接口地址: `GET /api/schedule`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

无

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": [
        {
            "id": 1,
            "name": "行程1",
            "updatedAt": "2026-04-01T10:00:00Z"
        },
        {
            "id": 2,
            "name": "行程2",
            "updatedAt": "2025-04-01T09:00:00Z"
        }
    ]
}
```

### 获取行程详情

- 功能说明：获取行程的详细信息，如果旅行计划处于待决策是否接受agent的建议的阶段，会返回两个`currentPlan`，版本新的为agent新生成的
- 接口地址: `GET /api/schedule/{id}`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 行程`id` |

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": {
        "name": "默认行程名",
        "currentVersion": 1,
        "currentPlan": {
            "version": 1,
            "updatedBy": "account",
            "items": //以下item内容待更改
            [
                {
                    "id": 1,
                    "type": "attraction",
                    "name": "故宫",
                    "date": "2026-05-01",
                    "time_slot": "09:00-12:00",
                    "notes": "需提前预约门票",
                    "status": "planned"
                },
                {
                    "id": 2,
                    "type": "hotel",
                    "name": "北京饭店",
                    "date": "2026-05-01",
                    "check_in": "14:00",
                    "check_out": "2026-05-02 12:00",
                    "status": "confirmed"
                }
            ]
        },
        "suggestedPlan": null,//存在时格式与currentPlan保持一致
        "chats": [
            {
                "id": 1,
                "name": "默认会话1"
            },
            {
                "id": 2,
                "name": "默认会话2"
            }
        ]
    }
}
```

### 删除行程

- 功能说明：删除行程
- 接口地址: `DELETE /api/schedule/{id}`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 行程`id` |

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": "删除成功"
}
```

## 会话模块

### 新建会话

- 功能说明：在当前行程下新建一个会话，返回会话`id`
- 接口地址: `POST /api/chat`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `schedule_id` | `int` | 是 | 所属行程`id` |
| `name` | `String` | 否 | 会话名，默认为“默认会话” |

#### 请求示例

```json
{
    "schedule_id": 1
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": 1
}
```

### 更改会话名

- 功能说明：同接口名
- 接口地址: `PUT /api/chat`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 会话`id` |
| `name` | `String` | 是 | 新会话名 |

#### 请求示例

```json
{
    "id": 1,
    "name": "新的会话名!"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": "更新成功"
}
```

### 发送消息

- 功能说明：发送消息并返回回复。后端会调用 Agent API 的 /chat/completions 接口，并将流式响应转发给前端。支持多模态输入（文本 + 文件）。终止后后端也会终止向agent的请求。
- 接口地址: `POST /api/chat/send`
- 请求头
  - `Content-Type: multipart/form-data`(支持文件上传)
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 会话`id` |
| `message` | `String` | 是 | 发送的内容 |
| `files` |	`File[]` | 否 | 上传的文件数组（支持图片、文档等，支持多文件） |

#### 请求示例

使用 `multipart/form-data` 上传：
- `id`: 1
- `message`: "帮我分析这个行程文件"

#### 响应示例

- 使用 Server-Sent Events (SSE) 进行流式输出，实时推送 Agent 的状态和内容。
- 常见事件类型：
  - thought: Agent 的内部思考过程增量输出（delta 模式）。
  - tool_call: 触发工具调用，携带 call_id。
  - tool_result: 工具调用结果，携带对应 call_id。
  - message_delta: 最终消息增量。
  - error: 错误信息。
  - done: 完成，包含 Token 使用统计。

- SSE 示例：

```text
event: thought
data: {"content": "用户上传了文件，正在分析行程。"}

event: tool_call
data: {"call_id": "call_123", "tool_name": "analyze_file", "params": {"file_id": "file_456"}}

event: tool_result
data: {"call_id": "call_123", "result": "分析完成，建议调整时间。"}

event: message_delta
data: {"content": "根据文件分析，建议将出发时间提前。"}

event: done
data: {"status": "success", "usage": {"prompt_tokens": 200, "completion_tokens": 100}}
```

- 响应示例（非流式，错误时）

```json
{
    "code": "400",
    "msg": "INVALID_REQUEST:文件格式不支持",
    "data": null
}
```

### 获取历史消息

- 功能说明：获取当前会话下的历史消息
- 接口地址: `GET /api/chat/{id}`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 会话`id` |

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "SUCCESS",
    "data": [
        {
            "id": 1,
            "role": "user",
            "content": "帮我规划行程",
            "timestamp": "2026-04-18T10:00:00Z"
        },
        {
            "id": 2,
            "role": "assistant",
            "content": "好的，我来帮你规划。",
            "timestamp": "2026-04-18T10:01:00Z"
        }
    ]
}
```