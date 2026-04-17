# Agent APP API 接口文档

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
    "msg": "",
    "data": 1//行程id
}
```

### 更改行程名

- 功能说明：同接口名
- 接口地址：`UPDATE /api/schedule`
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
    "msg": "",
    "data": "更新成功"
}
```

### 获取行程列表

- 功能说明：获取当前登录下的token的行程列表，按照时间排序，最新的在最上面
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
    "msg": "",
    "data": [
        {
            "id": 1,
            "name": "行程1",
            "updatedAt": 2026-4-1 10:00:00
        },
        {
            "id": 2,
            "name": "行程2",
            "updatedAt": 2025-4-1 09:00:00
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
    "msg": "",
    "data": {
        "name": "默认行程名",
        "currentVersion": 1,
        "currentPlan": [{
            "version": 1,
            "updatedBy": "account",
            "items": [
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
        }],
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
    "msg": "",
    "data": "删除成功"
}
```

## 旅行计划模块

### 获取旅行计划详情

- 功能说明：获取某行程下当前版本的信息
- 接口地址: `GET /api/schedule/{schedule_id}/plan`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `schedule_id` | `int` | 是       | 行程`id` |

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": {
        "version": 1,
        "updatedBy": "account",
        "items": [
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
    }
}
```

### 更新旅行计划-增加计划项(用户操作)

- 功能说明：更新旅行计划，增加计划项，返回新的计划项的`id`
- 接口地址: `POST /api/schedule/add`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 旅行计划的`id` |
| `name` | `string` | 是 | 计划项的名字 |
| `date` | `date` | 是 | 计划的时间 |
| `time_slot` | `string`，格式必须为HH:MM-HH:MM且合法 | 是 | 时间段 |
| `notes` | `string` | 是 | 状态 |

#### 请求示例

```json
{
    "id": 1,
    "name": "itemName",
    "date": 2026-4-17,
    "time_slot": "11:00-23:59",
    "notes": "planned"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": 1
}
```

### 更新旅行计划-删除计划项(用户操作)

- 功能说明：更新旅行计划，删除计划项
- 接口地址: `POST /api/schedule/delete`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名        | 类型  | 是否必填 | 说明           |
| ------------- | ----- | -------- | -------------- |
| `schedule_id` | `int` | 是       | 旅行计划的`id` |
| `item_id`     | `int` | 是       | 计划项的`id`   |

#### 请求示例

```json
{
    "schedule_id": 1,
    "item_id": 2
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": "删除成功"
}
```

### 更新旅行计划(用户操作)

- 功能说明：更新旅行计划，更新旅行计划中的计划项，返回更新后的item的`id`
- 接口地址: `POST /api/schedule/update`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| ------ | ---- | -------- | ---- |
| `schedule_id` | `int` | 是 | 旅行计划的`id` |
| `item_id` | `int` | 是 | 计划项的`id` |
| `name` | `string` | 否 | 计划项的名字 |
| `date` | `date` | 否 | 计划的时间 |
| `time_slot` | `string`，格式必须为HH:MM-HH:MM且合法 | 否 | 时间段 |
| `notes` | `string` | 否 | 状态 |

#### 请求示例

```json
{
    "schedule_id": 1,
    "item_id": 3,
    "name": "new_name"
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": 4
}
```

### 更新旅行计划(agent使用)

- 功能说明：更新旅行计划，包含三个接口，除路径外均与用户使用的相同，只是后端在实现时会进行标注的区别
- 接口地址: `POST /api/schedule/agent/`+`add`或`delete`或`update`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

#### 请求示例

#### 响应示例

三者均与用户使用的接口一致

### 获取旅行计划历史版本

- 功能说明：获取当前行程下的所有旅行计划历史版本
- 接口地址: `GET /api/schedule/{id}/allVersions`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是       | 行程`id` |

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": [
        {
            "id": 1,
            "updatedBy": "account",
            "version": 1
        },
        {
            "id": 2,
            "updatedBy": "agent",
            "version": 2
        }
    ]
}
```

### 获取旅行计划单个历史版本详情

- 功能说明：见接口名
- 接口地址: `GET /api/plan/{id}`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 旅行计划`id` |

#### 请求示例

无

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": {
        "version": 1,
        "updatedBy": "account",
        "items": [
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
    }
}
```

### 旅行计划历史版本回退

- 功能说明：回退到历史版本，返回回到的版本的详情
- 接口地址: `UPDATE /api/note/version/back`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 行程`id` |
| `version` | `int` | 是 | 想要回退的版本号，一定要存在 |

#### 请求示例

```json
{
    "id": 1,
    "version": 3
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": {
        "version": 3,
        "updatedBy": "account",
        "items": [
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
    }
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
    "msg": "",
    "data": 1
}
```

### 更改会话名

- 功能说明：同接口名
- 接口地址: `UPDATE /api/chat`
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
    "msg": "",
    "data": "更新成功"
}
```

### 发送消息

//TODO:由于需要流式输出,文档暂时无法完善,需要调研如何流式输出

- 功能说明：发送消息并返回回复
- 接口地址: `POST /api/chat/send`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 会话`id` |
| `message` | `String` | 是 | 发送的内容 |

#### 请求示例

```json
{
    "id": 1,
    "message": "那我问你?"
}
```

#### 响应示例

//TODO:待定,应为流式输出

```json
{
    "code": "200",
    "msg": "",
    "data": ""
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

//TODO:内容暂定,取决于agent的输出形式

```json
{
    "code": "200",
    "msg": "",
    "data": ""
}
```

### 终止生成

//TODO:也涉及流式输出,待定

- 功能说明：终止正在输出的内容
- 接口地址: `POST /api/chat/stop`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |

#### 请求示例

```json
{
    "": ""
}
```

#### 响应示例

```json
{
    "code": "200",
    "msg": "",
    "data": ""
}
```
