# 迭代 2

## 任务

1. 选题
2. Base Agent：文档/Agent 仅提供基础 Agent 功能，无需特别复杂的前端
3. Agent 应用：文档/前端/后端
4. Agent 评估平台：文档/前端/后端
5. 文档
6. 视频演示

## 时间安排

- 4/1 初步确定选题；确定 Base Agent 的接口规范；确定 Agent 应用和 Agent 评估平台的架构/功能
- 4/8 完成 Base Agent 的核心功能开发
- 4/22 完成 Agent 应用和 Agent 评估平台的核心功能开发
- 5/11 ddl，6 周

### 依赖关系

- 1 2 可同时推进
- 3 4 可同时推进，但需在 2 的接口规范确定后才能开始
- 5 6 最后再说也来得及

## 分工

- Base Agent
  - @zjh @hzx
  - @hzx 还需完成评估平台的评估部分的开发
- Agent 应用
  - 组长 @zjh
  - 前 @cyy
  - 后 @zyf
- Agent 评估平台
  - 组长 @hzx
  - 前 @wh
  - 后 @kyt
- CI/CD @wh @zjh

## 技术选型

- 前端：React + TS + MUI
- 后端：Go + Redis + MySQL
  - 高并发, mq, 分布式事务, 分布式锁, 数据库主从备份
- Agent：Python

## 仓库

|仓库用途|校内地址|Github 地址|
|-|-|-|
|Agent 本体|<http://172.29.4.49/2026seiii-016/agent-base>|<https://github.com/Open-Codex-6/agent-base>|
|Agent 应用 前端|<http://172.29.4.49/2026seiii-016/agent-app-frontend/>|<https://github.com/Open-Codex-6/agent-app-frontend>|
|Agent 应用 后端|<http://172.29.4.49/2026seiii-016/agent-app-backend>|<https://github.com/Open-Codex-6/agent-app-backend>|
|Agent 评估平台 前端|<http://172.29.4.49/2026seiii-016/agent-evaluation-frontend>|<https://github.com/Open-Codex-6/agent-evaluation-frontend>|
|Agent 评估平台 后端|<http://172.29.4.49/2026seiii-016/agent-evaluation-backend>|<https://github.com/Open-Codex-6/agent-evaluation-backend>|

- 每次 clone 新仓库前，请按照 <https://se3.cos.tg/#/rules/git?id=%e8%ae%be%e7%bd%ae%e7%94%a8%e6%88%b7%e5%90%8d%e9%82%ae%e7%ae%b1%e3%80%81gpg> 的要求配置好 git 用户名、邮箱和 GPG key。

## 进一步拓展项目

- Agent：Context Engineering/Memory，工具集选取，MCP，Agentic RL，上下文压缩……
- 应用功能本身
