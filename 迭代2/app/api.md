# Agent APP API 接口文档

## Agent 模块

- 创建会话：登录后可以新建一个对话会话，创建时可选填会话标题，不填则由后端自动生成；创建成功后返回会话 ID，后续所有消息都基于该会话。
- 发送消息：登录后向指定会话发送一条消息（之后可以考虑<mark>多模态</mark>，加入文档、图片等等），后端调用 Agent 处理并返回回复内容，若消息包含需要 Agent 调用工具的场景（如搜索景点、订票订酒店等），后端应返回 Agent 调用了哪些工具及其结果；若使用流式响应，前端能够逐段展示 Agent 的思考过程和回复内容。
- 查看历史消息：登录后可以查看任意会话的消息记录，按时间顺序展示用户消息和 Agent 回复，Agent 回复中应包含调用过的工具信息。每一个问题都应有对应ID，方便前端界面设计“快速访问历史对话”的逻辑。
- 删除会话：可以删除不需要的会话，一并清除该会话的所有消息。
- 终止生成：当 Agent 正在生成回复时，用户可以主动终止生成，终止后返回已生成的部分内容。用户可以重新输入问题。
- 获取会话列表：登录后可以查看当前用户创建的所有会话，按更新时间倒序排列。
- （可选）地图API：类似会议文件里竞品的页面，调用地图API展示酒店、景点等位置信息。

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
    "msg": "",
    "data": 2
}
```

```json
{
    "code": "400",
    "msg": "创建失败",
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
    "msg": "",
    "data": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1IiwiZXhwIjoxNzQyOTAwNDUwfQ.R_GtVrXmg8E_hGjUY4Gm_zFKVCg0Dy8jWreAAmJrvCM"
}
```

```json
{
    "code": "400",
    "msg": "用户不存在/用户密码错误",
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
    "msg": "",
    "data": "用户信息更新成功"
}
```

```json
{
    "code": "400",
    "msg": "token与输入的用户名不匹配",
    "data": null
}
```

```json
{
    "code": "400",
    "msg": "更新失败",
    "data": null
}
```
