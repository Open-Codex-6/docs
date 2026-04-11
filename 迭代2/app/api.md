# API 接口文档

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
