# Agent Eval API 接口文档

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

```json
{
	"page": 1,
	"pageSize": 10,
	"startTime": "2026-04-01T00:00:00Z",
	"endTime": "2026-04-14T23:59:59Z",
	"username": "testuser",
	"scoreMin": 70,
	"scoreMax": 100,
	"eprPassed": true,
	"clprMin": 0.7,
	"clprMax": 1.0,
	"ragasMin": 0.6,
	"ragasMax": 1.0,
	"tag": "travel-agent",
	"sortBy": "createdAt",
	"order": "desc"
}
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
- 接口地址: `GET /api/evaluations/{evaluationId}`
- 请求头
  - `Authorization: Bearer <token>`

#### 请求参数

| 参数名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `evaluationId` | `String` | 是 | 评测记录 ID（路径参数） |

#### 请求示例

```json
{
	"evaluationId": "eval_202604140001"
}
```

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
		}
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

#### 请求示例

```json
{}
```

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
| `metricName` | `String` | 是 | 指标名称，如 `clpr`、`ragas.faithfulness` |
| `limit` | `Integer` | 否 | 近 N 次记录，和时间范围二选一 |
| `startTime` | `String` | 否 | 时间范围起点，ISO 8601 时间字符串 |
| `endTime` | `String` | 否 | 时间范围终点，ISO 8601 时间字符串 |

#### 请求示例

```json
{
	"metricName": "clpr",
	"limit": 20
}
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
