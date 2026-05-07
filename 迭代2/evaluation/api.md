# Agent Eval API 接口文档

## 用户模块

### 创建用户

- 功能说明：创建新用户。
- 接口地址: `POST /api/auth/register`
- 请求头
  - `Content-Type: application/json`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `username` | `String` | 是 | 用户名，长度 3~64 位 |
| `password` | `String` | 是 | 密码，至少 6 位 |

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
 "msg": "用户名长度需在3~64位之间",
 "data": null
}
```

```json
{
 "code": "400",
 "msg": "用户名已存在",
 "data": null
}
```

### 登录

- 功能说明：用户登录，返回 JWT token。
- 接口地址: `POST /api/auth/login`
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
 "msg": "用户名或密码错误",
 "data": null
}
```

### 获取当前用户信息

- 功能说明：获取当前登录用户的基本信息。
- 接口地址: `GET /api/auth/profile`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

无

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "id": 2,
  "username": "testuser"
 }
}
```

### 更新用户密码

- 功能说明：验证旧密码后将密码更新为新密码。
- 接口地址: `PUT /api/auth`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `oldPassword` | `String` | 是 | 当前密码 |
| `newPassword` | `String` | 是 | 新密码，至少 6 位 |

#### 请求示例

```json
{
 "oldPassword": "123456",
 "newPassword": "newpassword"
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
 "msg": "旧密码错误",
 "data": null
}
```

```json
{
 "code": "400",
 "msg": "参数错误",
 "data": null
}
```

## 系统指标模块

系统指标由管理员预先配置，前端只读，不提供创建、修改、删除接口。

### 获取系统指标列表

- 功能说明：获取所有系统预置评测指标的定义及属性。
- 接口地址: `GET /api/system-metrics`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

无

#### 响应字段说明

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| `name` | `String` | 指标唯一标识名 |
| `brief` | `String` | 指标简介 |
| `description` | `String` | 指标详细描述 |
| `valueRange` | `Object` | 取值范围，`avg_latency` 为 `{"min":0}`，其余均为 `{"min":0,"max":1}` |
| `betterDirection` | `String` | `"higher"` 表示越高越好，`"lower"` 表示越低越好 |
| `category` | `String` | 指标分类：`"performance"` / `"quality"` / `"safety"` |

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": [
  {
   "name": "avg_latency",
   "brief": "平均响应延迟",
   "description": "统计 Session 内所有有效轮次的耗时，计算平均延迟（毫秒）。值越低表示 Agent 响应越快。",
   "valueRange": {"min": 0},
   "betterDirection": "lower",
   "category": "performance"
  },
  {
   "name": "answer_relevancy",
   "brief": "回答相关性",
   "description": "基于 Ragas Answer Relevancy 方法，衡量 Agent 回答与用户初始问题意图的相关程度。得分范围 [0, 1]，越高越好。",
   "valueRange": {"min": 0, "max": 1},
   "betterDirection": "higher",
   "category": "quality"
  },
  {
   "name": "harmfulness",
   "brief": "有害性",
   "description": "基于 Ragas Harmfulness 方法，检测 Agent 响应中的有害内容。得分范围 [0, 1]，0 表示完全安全，越低越好。",
   "valueRange": {"min": 0, "max": 1},
   "betterDirection": "lower",
   "category": "safety"
  },
  {
   "name": "coherence",
   "brief": "逻辑连贯性",
   "description": "基于 Ragas Coherence 方法，衡量 Agent 响应的逻辑连贯程度。得分范围 [0, 1]，越高越好。",
   "valueRange": {"min": 0, "max": 1},
   "betterDirection": "higher",
   "category": "quality"
  },
  {
   "name": "faithfulness",
   "brief": "忠实度",
   "description": "基于 Ragas Faithfulness 方法，衡量 Agent 回答对工具调用事实的忠实程度（护栏指标）。得分范围 [0, 1]，越高越好。",
   "valueRange": {"min": 0, "max": 1},
   "betterDirection": "higher",
   "category": "safety"
  }
 ]
}
```

## 自定义指标模块

用户可在系统指标之外创建自己的评测指标，每个指标属于创建它的用户，其他用户不可见、不可修改。

### 创建自定义指标

- 功能说明：创建一个属于当前用户的自定义评测指标。
- 接口地址: `POST /api/custom-metrics`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `name` | `String` | 是 | 指标名称，最长 64 位，同一用户下唯一 |
| `brief` | `String` | 否 | 指标简介，最长 255 位 |
| `description` | `String` | 否 | 指标详细描述 |
| `scoreDesc` | `Array` | 否 | 评分说明列表，最多 20 项，每项包含 `score`（整数）和 `description`（字符串） |

#### 请求示例

```json
{
 "name": "response_completeness",
 "brief": "回答完整性",
 "description": "衡量 Agent 回答是否覆盖了用户问题的所有要点",
 "scoreDesc": [
  {"score": 1, "description": "回答完全不完整"},
  {"score": 3, "description": "回答部分完整"},
  {"score": 5, "description": "回答完全完整"}
 ]
}
```

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "id": 1,
  "name": "response_completeness",
  "brief": "回答完整性",
  "description": "衡量 Agent 回答是否覆盖了用户问题的所有要点",
  "scoreDesc": [
   {"score": 1, "description": "回答完全不完整"},
   {"score": 3, "description": "回答部分完整"},
   {"score": 5, "description": "回答完全完整"}
  ],
  "createdAt": "2026-05-01T10:00:00Z",
  "updatedAt": "2026-05-01T10:00:00Z"
 }
}
```

```json
{
 "code": "400",
 "msg": "同名指标已存在",
 "data": null
}
```

### 获取自定义指标列表

- 功能说明：获取当前用户创建的所有自定义指标。
- 接口地址: `GET /api/custom-metrics`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

无

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": [
  {
   "id": 1,
   "name": "response_completeness",
   "brief": "回答完整性",
   "description": "衡量 Agent 回答是否覆盖了用户问题的所有要点",
   "scoreDesc": [
    {"score": 1, "description": "回答完全不完整"},
    {"score": 5, "description": "回答完全完整"}
   ],
   "createdAt": "2026-05-01T10:00:00Z",
   "updatedAt": "2026-05-01T10:00:00Z"
  }
 ]
}
```

### 更新自定义指标

- 功能说明：更新指定的自定义指标（只能操作自己创建的指标）。
- 接口地址: `PUT /api/custom-metrics/:metricId`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `metricId` | `Integer` | 是 | 指标 ID（路径参数） |
| `name` | `String` | 是 | 指标名称，最长 64 位 |
| `brief` | `String` | 否 | 指标简介，最长 255 位 |
| `description` | `String` | 否 | 指标详细描述 |
| `scoreDesc` | `Array` | 否 | 评分说明列表，最多 20 项 |

#### 请求示例

```json
{
 "name": "response_completeness",
 "brief": "回答完整性（已修订）",
 "description": "衡量回答完整性，修订版",
 "scoreDesc": [
  {"score": 1, "description": "完全不完整"},
  {"score": 5, "description": "非常完整"}
 ]
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

```json
{
 "code": "404",
 "msg": "指标不存在",
 "data": null
}
```

```json
{
 "code": "403",
 "msg": "无权操作该指标",
 "data": null
}
```

```json
{
 "code": "400",
 "msg": "同名指标已存在",
 "data": null
}
```

### 删除自定义指标

- 功能说明：删除指定的自定义指标（只能操作自己创建的指标）。
- 接口地址: `DELETE /api/custom-metrics/:metricId`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `metricId` | `Integer` | 是 | 指标 ID（路径参数） |

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": "删除成功"
}
```

```json
{
 "code": "404",
 "msg": "指标不存在",
 "data": null
}
```

```json
{
 "code": "403",
 "msg": "无权操作该指标",
 "data": null
}
```

## 任务评测模块

任务是评测的基本单元，绑定若干指标（创建后不可更改指标列表）。每次提交对话数据后，系统调用评测计算服务完成指标计算并保存结果。

### 创建任务

- 功能说明：创建一个评测任务，同时绑定评测指标列表（创建后指标列表不可修改）。
- 接口地址: `POST /api/tasks`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `title` | `String` | 是 | 任务标题，最长 255 位 |
| `description` | `String` | 否 | 任务描述 |
| `metrics` | `Array` | 是 | 绑定的指标列表，至少 1 项 |
| `metrics[].id` | `String` | 是 | 指标 ID（系统指标填指标名如 `avg_latency`，自定义指标填数字 ID 的字符串形式如 `"1"`） |
| `metrics[].type` | `String` | 是 | 指标类型，`"system"` 或 `"custom"` |
| `metrics[].name` | `String` | 是 | 指标名称（冗余存储，用于展示） |

#### 请求示例

```json
{
 "title": "旅行助手评测",
 "description": "测试旅行规划场景下 Agent 的延迟与完整性",
 "metrics": [
  {"id": "avg_latency", "type": "system", "name": "平均响应延迟"},
  {"id": "1", "type": "custom", "name": "response_completeness"}
 ]
}
```

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "id": 1
 }
}
```

```json
{
 "code": "400",
 "msg": "参数错误",
 "data": null
}
```

### 获取任务列表

- 功能说明：获取当前用户创建的所有任务（概览信息，不含评测历史）。
- 接口地址: `GET /api/tasks`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

无

#### 响应字段说明

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `Integer` | 任务 ID |
| `title` | `String` | 任务标题 |
| `description` | `String` | 任务描述 |
| `metrics` | `Array` | 绑定的指标列表 |
| `evalCount` | `Integer` | 累计评测次数 |
| `lastEvaluatedAt` | `String \| null` | 最近一次评测时间（ISO 8601），从未评测时为 `null` |
| `createdAt` | `String` | 任务创建时间（ISO 8601） |

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": [
  {
   "id": 1,
   "title": "旅行助手评测",
   "description": "测试旅行规划场景下 Agent 的延迟与完整性",
   "metrics": [
    {"id": "avg_latency", "type": "system", "name": "平均响应延迟"},
    {"id": "1", "type": "custom", "name": "response_completeness"}
   ],
   "evalCount": 3,
   "lastEvaluatedAt": "2026-05-01T11:00:00Z",
   "createdAt": "2026-05-01T10:00:00Z"
  },
  {
   "id": 2,
   "title": "客服助手评测",
   "description": "",
   "metrics": [
    {"id": "avg_latency", "type": "system", "name": "平均响应延迟"}
   ],
   "evalCount": 0,
   "lastEvaluatedAt": null,
   "createdAt": "2026-05-02T09:00:00Z"
  }
 ]
}
```

### 更新任务

- 功能说明：更新任务标题或描述（指标列表不可修改）。
- 接口地址: `PUT /api/tasks/:taskId`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `Integer` | 是 | 任务 ID（路径参数） |
| `title` | `String` | 是 | 任务标题，最长 255 位 |
| `description` | `String` | 否 | 任务描述 |

#### 请求示例

```json
{
 "title": "旅行助手评测 v2",
 "description": "更新后的描述"
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

```json
{
 "code": "404",
 "msg": "任务不存在",
 "data": null
}
```

```json
{
 "code": "403",
 "msg": "无权操作该任务",
 "data": null
}
```

### 删除任务

- 功能说明：删除指定任务及其所有评测历史（只能操作自己的任务）。
- 接口地址: `DELETE /api/tasks/:taskId`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `Integer` | 是 | 任务 ID（路径参数） |

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": "删除成功"
}
```

```json
{
 "code": "404",
 "msg": "任务不存在",
 "data": null
}
```

```json
{
 "code": "403",
 "msg": "无权操作该任务",
 "data": null
}
```

### 获取任务详情

- 功能说明：获取指定任务的完整信息，包括任务基本信息、绑定的指标列表，以及全部评测历史记录。
- 接口地址: `GET /api/tasks/:taskId`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `Integer` | 是 | 任务 ID（路径参数） |

#### 响应字段说明

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `Integer` | 任务 ID |
| `title` | `String` | 任务标题 |
| `description` | `String` | 任务描述 |
| `metrics` | `Array` | 绑定的指标列表 |
| `evalCount` | `Integer` | 累计评测次数 |
| `lastEvaluatedAt` | `String \| null` | 最近一次评测时间，从未评测时为 `null` |
| `createdAt` | `String` | 任务创建时间 |
| `evaluations` | `Array` | 评测历史列表，按 `seqNum` 升序排列 |
| `evaluations[].seqNum` | `Integer` | 该任务下的评测序号，从 1 开始递增 |
| `evaluations[].createdAt` | `String` | 本次评测时间 |
| `evaluations[].metricResults` | `Array` | 本次各指标计算结果 |
| `metricResults[].metric_name` | `String` | 指标名称 |
| `metricResults[].score` | `Number \| null` | 指标得分，计算失败时为 `null` |
| `metricResults[].reason` | `String` | 计算说明或失败原因 |
| `metricResults[].status` | `String` | `"success"` / `"skipped"` / `"error"` |

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "id": 1,
  "title": "旅行助手评测",
  "description": "测试旅行规划场景下 Agent 的延迟与完整性",
  "metrics": [
   {"id": "avg_latency", "type": "system", "name": "平均响应延迟"},
   {"id": "1", "type": "custom", "name": "response_completeness"}
  ],
  "evalCount": 2,
  "lastEvaluatedAt": "2026-05-01T11:00:00Z",
  "createdAt": "2026-05-01T10:00:00Z",
  "evaluations": [
   {
    "seqNum": 1,
    "createdAt": "2026-05-01T10:30:00Z",
    "metricResults": [
     {
      "metric_name": "avg_latency",
      "score": 312.5,
      "reason": "全局共有 2 个有效轮次记录耗时，Session平均延迟为 312.50 ms",
      "status": "success"
     },
     {
      "metric_name": "response_completeness",
      "score": null,
      "reason": "自定义指标暂不支持自动计算",
      "status": "skipped"
     }
    ]
   },
   {
    "seqNum": 2,
    "createdAt": "2026-05-01T11:00:00Z",
    "metricResults": [
     {
      "metric_name": "avg_latency",
      "score": 280.0,
      "reason": "全局共有 2 个有效轮次记录耗时，Session平均延迟为 280.00 ms",
      "status": "success"
     },
     {
      "metric_name": "response_completeness",
      "score": null,
      "reason": "自定义指标暂不支持自动计算",
      "status": "skipped"
     }
    ]
   }
  ]
 }
}
```

```json
{
 "code": "404",
 "msg": "任务不存在",
 "data": null
}
```

```json
{
 "code": "403",
 "msg": "无权访问该任务",
 "data": null
}
```

### 执行任务评测

- 功能说明：对指定任务提交一次对话数据，系统调用评测计算服务完成各项指标计算并保存结果，返回本次评测序号及计算结果。
- 接口地址: `POST /api/tasks/:taskId/evaluate`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `Integer` | 是 | 任务 ID（路径参数） |
| `rounds` | `Array` | 是 | 对话轮次列表，至少 1 项 |
| `rounds[].user_query` | `String` | 是 | 用户输入 |
| `rounds[].agent_response` | `String` | 是 | Agent 回复 |
| `rounds[].tools` | `Array` | 否 | 工具调用列表 |
| `rounds[].tools[].name` | `String` | 是 | 工具名称 |
| `rounds[].tools[].inputs` | `Object` | 是 | 工具入参（任意 JSON 对象） |
| `rounds[].tools[].observation` | `String` | 是 | 工具返回结果 |
| `rounds[].tools[].thought` | `String` | 是 | 调用前的思考过程 |
| `rounds[].metadata` | `Object` | 否 | 元数据 |
| `rounds[].metadata.latency_ms` | `Number` | 否 | 本轮耗时（毫秒），用于计算 `avg_latency` |
| `rounds[].metadata.tokens_used` | `Integer` | 否 | 本轮消耗的 token 数 |

#### 请求示例

```json
{
 "rounds": [
  {
   "user_query": "帮我规划一份杭州三日游",
   "agent_response": "已为您生成行程安排。",
   "tools": [
    {
     "name": "search_attractions",
     "inputs": {"city": "杭州"},
     "observation": "返回景点列表：西湖、灵隐寺……",
     "thought": "需要先查询景点信息"
    }
   ],
   "metadata": {
    "latency_ms": 350.5,
    "tokens_used": 512
   }
  },
  {
   "user_query": "有哪些推荐的餐厅？",
   "agent_response": "以下是推荐餐厅……",
   "tools": [],
   "metadata": {
    "latency_ms": 274.0,
    "tokens_used": 320
   }
  }
 ]
}
```

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "seqNum": 1,
  "metricResults": [
   {
    "metric_name": "avg_latency",
    "score": 312.25,
    "reason": "全局共有 2 个有效轮次记录耗时，Session平均延迟为 312.25 ms",
    "status": "success"
   },
   {
    "metric_name": "response_completeness",
    "score": null,
    "reason": "自定义指标暂不支持自动计算",
    "status": "skipped"
   }
  ]
 }
}
```

```json
{
 "code": "400",
 "msg": "rounds 不能为空",
 "data": null
}
```

```json
{
 "code": "404",
 "msg": "任务不存在",
 "data": null
}
```

```json
{
 "code": "403",
 "msg": "无权操作该任务",
 "data": null
}
```
