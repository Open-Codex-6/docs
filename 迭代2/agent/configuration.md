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

## MCP 工具配置

```plaintext
AMAP_MAPS_API_KEY=your_amap_maps_api_key_here  # 高德地图 API 密钥
VARIFLIGHT_API_KEY=your_variflight_api_key_here # 飞常准 API 密钥
```
