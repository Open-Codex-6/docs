# Base Agent Parameters

## OpenAI 配置

```plaintext
OPENAI_API_KEY=your_openai_api_key_here  # OpenAI API 密钥
OPENAI_BASE_URL=https://api.openai.com/v1  # OpenAI API 的基础 URL，用于指定 API 端点
OPENAI_MODEL=gpt-4o-mini  # Agent 将调用此模型进行推理
```

## 高德地图 MCP 工具配置

```plaintext
AMAP_MAPS_API_KEY=your_amap_maps_api_key_here  # 高德地图 API 密钥
MCP_AMAP_COMMAND=npx  # 启动高德 MCP 服务的命令（npx 用于运行 npm 全局包）
MCP_AMAP_ARGS=-y @amap/amap-maps-mcp-server  # 高德 MCP 服务的启动参数（-y 自动确认安装，@amap/amap-maps-mcp-server 为包名）
```
