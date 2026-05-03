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

- 功能说明：用户登录。
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

### 更新用户信息

- 功能说明：更新用户信息。
- 接口地址: `PUT /api/auth`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
   	- 说明：`token`来自于login返回的`data`，若第一次`update`成功而后续失败，则为`token`已过期需重新login获取`token`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `username` | `String` | 是 | 用户名（须与 token 中的用户名一致） |
| `password` | `String` | 是 | 新密码，至少 6 位 |

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

## 评测记录模块

### 获取评测记录列表

- 功能说明：获取所有评测记录，支持筛选、排序、分页。
- 接口地址: `GET /api/evaluations`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `Integer` | 是 | 页号，从 1 开始 |
| `pageSize` | `Integer` | 否 | 每页条数，默认 10 |
| `startTime` | `String` | 否 | 时间范围起点，ISO 8601 时间字符串 |
| `endTime` | `String` | 否 | 时间范围终点，ISO 8601 时间字符串 |
| `username` | `String` | 否 | 发起用户名称 |
| `scoreMin` | `Number` | 否 | 综合评估分数下限 |
| `scoreMax` | `Number` | 否 | 综合评估分数上限 |
| `eprPassed` | `Boolean` | 否 | EPR 是否通过 |
| `clprMin` | `Number` | 否 | C-LPR 下限 |
| `clprMax` | `Number` | 否 | C-LPR 上限 |
| `ragasMin` | `Number` | 否 | Ragas 指标下限 |
| `ragasMax` | `Number` | 否 | Ragas 指标上限 |
| `tag` | `String` | 否 | 评测 Tag |
| `sortBy` | `String` | 否 | 排序字段，可选 `createdAt`、`score`、`eprStatus`、`clpr`、`ragas`，默认 `createdAt` |
| `order` | `String` | 否 | 排序方向，可选 `asc`、`desc`，默认 `desc` |

#### 请求示例

```
GET /api/evaluations?page=1&pageSize=10&startTime=2026-04-01T00:00:00Z&endTime=2026-04-14T23:59:59Z&username=testuser&scoreMin=70&scoreMax=100&eprPassed=true&clprMin=0.7&clprMax=1.0&ragasMin=0.6&ragasMax=1.0&tag=travel-agent&sortBy=createdAt&order=desc
```

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "page": 1,
  "pageSize": 10,
  "total": 2,
  "records": [
   {
    "id": "eval_202604140001",
    "username": "testuser",
    "createdAt": "2026-04-14T10:20:30Z",
    "score": 86.5,
    "eprStatus": "PASS",
    "clpr": 0.84,
    "ragas": {
     "faithfulness": 0.88,
     "answerRelevancy": 0.9,
     "contextRecall": 0.79
    },
    "tags": [
     "travel-agent",
     "v1"
    ]
   },
   {
    "id": "eval_202604140002",
    "username": "testuser",
    "createdAt": "2026-04-14T09:10:11Z",
    "score": 82.1,
    "eprStatus": "FAIL",
    "clpr": 0.75,
    "ragas": {
     "faithfulness": 0.81,
     "answerRelevancy": 0.86,
     "contextRecall": 0.7
    },
    "tags": [
     "travel-agent"
    ]
   }
  ]
 }
}
```

```json
{
 "code": "400",
 "msg": "请求参数不合法",
 "data": null
}
```

### 获取评测记录详情

- 功能说明：获取某一次评测记录的详细信息。
- 接口地址: `GET /api/evaluations/:evaluationId`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `evaluationId` | `String` | 是 | 评测记录 ID（路径参数） |

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "id": "eval_202604140001",
  "username": "testuser",
  "userQuestion": "请生成一份 3 天杭州旅行计划",
  "agentAnswer": "已为你生成行程，并给出每日安排。",
  "agentExecution": {
   "tools": [
    "search_flights",
    "search_hotels",
    "local_weather"
   ],
   "traceId": "trace_abc123"
  },
  "createdAt": "2026-04-14T10:20:30Z",
  "metrics": {
   "score": 86.5,
   "eprStatus": "FAIL",
   "clpr": 0.84,
   "ragas": {
    "faithfulness": 0.88,
    "answerRelevancy": 0.9,
    "contextRecall": 0.79
   }
  },
  "failureReasons": {
   "eprFailedItems": [
    "必须包含预算上限"
   ],
   "lprUnmetConstraints": [
    "酒店距离地铁站 1km 内"
   ]
  },
  "tags": [
   "travel-agent",
   "v1"
  ]
 }
}
```

```json
{
 "code": "404",
 "msg": "评测记录不存在",
 "data": null
}
```

### 获取评估指标元数据

- 功能说明：获取所有评估指标定义及属性。
- 接口地址: `GET /api/evaluation-metrics/meta`
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
   "name": "eprStatus",
   "description": "硬约束规则是否满足",
   "valueRange": [
    "PASS",
    "FAIL"
   ],
   "betterDirection": "PASS",
   "category": "硬约束"
  },
  {
   "name": "clpr",
   "description": "约束满足偏好程度",
   "valueRange": [
    0,
    1
   ],
   "betterDirection": "higher",
   "category": "软偏好"
  },
  {
   "name": "ragas.faithfulness",
   "description": "回答忠实度",
   "valueRange": [
    0,
    1
   ],
   "betterDirection": "higher",
   "category": "软偏好"
  }
 ]
}
```

### 获取指标历史趋势

- 功能说明：按指标维度查询历史趋势数据，用于绘制曲线。
- 接口地址: `GET /api/evaluation-metrics/trends`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `metricName` | `String` | 是 | 指标名称，可选 `score`、`clpr`、`ragas.faithfulness`、`ragas.answerRelevancy`、`ragas.contextRecall` |
| `limit` | `Integer` | 否 | 近 N 次记录，和时间范围二选一 |
| `startTime` | `String` | 否 | 时间范围起点，ISO 8601 时间字符串 |
| `endTime` | `String` | 否 | 时间范围终点，ISO 8601 时间字符串 |

#### 请求示例

```
GET /api/evaluation-metrics/trends?metricName=clpr&limit=20
```

#### 响应示例

```json
{
 "code": "200",
 "msg": "",
 "data": {
  "metricName": "clpr",
  "points": [
   {
    "timestamp": "2026-04-14T10:20:30Z",
    "evaluationId": "eval_202604140001",
    "value": 0.84,
    "eprPassed": false
   },
   {
    "timestamp": "2026-04-14T09:10:11Z",
    "evaluationId": "eval_202604140002",
    "value": 0.75,
    "eprPassed": false
   }
  ]
 }
}
```

```json
{
 "code": "400",
 "msg": "metricName 不存在",
 "data": null
}
```

## 自定义指标模块

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
| `description` | `String` | 否 | 指标描述 |
| `scoreDesc` | `Array` | 否 | 评分说明列表，最多 20 项，每项包含 `score`（整数）和 `description`（字符串） |

#### 请求示例

```json
{
 "name": "response_completeness",
 "description": "衡量回答的完整性",
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
  "description": "衡量回答的完整性",
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
   "description": "衡量回答的完整性",
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
| `description` | `String` | 否 | 指标描述 |
| `scoreDesc` | `Array` | 否 | 评分说明列表，最多 20 项 |

#### 请求示例

```json
{
 "name": "response_completeness",
 "description": "衡量回答完整性（已更新）",
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

### 创建任务

- 功能说明：创建一个评测任务，绑定若干评测指标。
- 接口地址: `POST /api/tasks`
- 请求头
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `title` | `String` | 是 | 任务标题，最长 255 位 |
| `description` | `String` | 否 | 任务描述 |
| `metrics` | `Array` | 否 | 绑定的指标列表，每项包含 `id`（指标 ID 字符串）、`type`（`"system"` 或 `"custom"`）、`name`（指标名称） |

#### 请求示例

```json
{
 "title": "旅行助手评测",
 "description": "测试旅行规划场景",
 "metrics": [
  {"id": "avg_latency", "type": "system", "name": "平均延迟"},
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

### 获取任务列表

- 功能说明：获取当前用户创建的所有任务。
- 接口地址: `GET /api/tasks`
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
   "title": "旅行助手评测",
   "description": "测试旅行规划场景",
   "metrics": [
    {"id": "avg_latency", "type": "system", "name": "平均延迟"},
    {"id": "1", "type": "custom", "name": "response_completeness"}
   ],
   "evalCount": 3,
   "createdAt": "2026-05-01T10:00:00Z"
  }
 ]
}
```

### 更新任务

- 功能说明：更新任务标题、描述或绑定的指标（只能操作自己的任务）。
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
| `metrics` | `Array` | 否 | 绑定的指标列表 |

#### 请求示例

```json
{
 "title": "旅行助手评测 v2",
 "description": "更新后的描述",
 "metrics": [
  {"id": "avg_latency", "type": "system", "name": "平均延迟"}
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

- 功能说明：删除指定任务（只能操作自己的任务）。
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

### 获取任务评测历史

- 功能说明：获取指定任务的所有历史评测结果。
- 接口地址: `GET /api/tasks/:taskId/evaluations`
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
 "data": [
  {
   "seqNum": 1,
   "createdAt": "2026-05-01T10:30:00Z",
   "metricResults": [
    {
     "metric_name": "avg_latency",
     "score": 312.5,
     "reason": "全局共有 2 个有效轮次记录耗时，Session平均延迟为 312.50 ms",
     "status": "success"
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
    }
   ]
  }
 ]
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

- 功能说明：对指定任务提交一轮对话数据，调用评测计算系统完成指标计算，并保存评测结果。
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
| `rounds[].tools` | `Array` | 否 | 工具调用列表，每项包含 `name`、`inputs`（对象）、`observation`、`thought` |
| `rounds[].metadata` | `Object` | 否 | 元数据，包含 `latency_ms`（浮点数，本轮耗时毫秒）和 `tokens_used`（整数，本轮 token 数） |

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
     "observation": "返回景点列表",
     "thought": "需要先查询景点"
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
