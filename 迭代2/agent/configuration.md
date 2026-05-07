# Base Agent Parameters

## OpenAI 配置

```plaintext
OPENAI_API_KEY=your_openai_api_key_here  # OpenAI API 密钥
OPENAI_BASE_URL=https://api.openai.com/v1  # OpenAI API 的基础 URL，用于指定 API 端点
OPENAI_MODEL=gpt-4o-mini  # Agent 将调用此模型进行推理
```

## Agent 运行时

```plaintext
AGENT_WORKER_TIMEOUT=60  # SubAgent 单次执行超时秒数，超时后返回空结果
MAX_LLM_ITERATIONS=10  # Supervisor / Worker LLM 最大 tool-call 轮次，防止无限循环
```

## Backend API 配置

Agent 通过以下环境变量连接后台 APP API（行程读写、计划项增删）：

```plaintext
BACKEND_API_BASE_URL=http://localhost:8000/api  # 后台 API 前缀
BACKEND_API_TIMEOUT=30  # 请求超时秒数
```

> 认证 token 来自于客户端请求的 `Authorization: Bearer <token>` 头，运行时通过 `contextvars` 注入，无需额外配置。

## MCP 工具配置

```plaintext
AMAP_MAPS_API_KEY=your_amap_maps_api_key_here  # 高德地图 API 密钥
VARIFLIGHT_API_KEY=your_variflight_api_key_here # 飞常准 API 密钥
```
