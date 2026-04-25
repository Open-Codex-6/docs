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

## 选题：旅游规划 Agent

- 每一次旅行对应一个旅行计划，后续的旅行相关操作都基于旅行计划进行
- 旅行前
  - 基于用户的预算、需求和过往画像生成初始旅游计划
  - 基于生成的计划进行购票、酒店预订、景点预约等自动化操作
  - 基于生成的计划推荐合适的旅行装备、套票等
- 旅行中
  - 基于现场的突发情况（恶劣天气、堵车、场馆闭馆）动态调整计划：语音？
  - 和地图、导航等集成
  - 实时介绍展品、地点历史
- 旅行后
  - 生成旅行报告
  - 基于用户的选择、反馈，更新记忆和用户画像，用于后续旅行的规划：景点偏好、体力情况
  - 分享旅行计划，供其他用户调用 Agent 时参考
- 参考竞品：<https://www.imean.ai/>
- Benchmark：<https://arxiv.org/abs/2412.13682>

## 分工

- Base Agent
  - @zjh @hzx
  - @hzx 还需完成评估平台的评估部分的开发
- 前端：@cyy @wh
- 后端：@zyf @kyt
- Agent 应用
  - 组长 @zjh
- Agent 评估平台
  - 组长 @hzx
- CI/CD @wh @zjh

## 技术选型

- 前端：React + TS + MUI
- 后端：Go + Redis + MySQL
  - 高并发, mq, 分布式事务, 分布式锁, 数据库主从备份（待资源充足后另行配置）
- Agent：Python

## 项目

|项目|校内仓库|Github 仓库|校内网址|校外网址|
|-|-|-|-|-|
|Agent 本体|<http://172.29.4.49/2026seiii-016/agent-base>|<https://github.com/Open-Codex-6/agent-base>|<http://172.29.5.12:8000>|<https://agent-base.cos.tg>|
|Agent 应用 前端|<http://172.29.4.49/2026seiii-016/agent-app-frontend/>|<https://github.com/Open-Codex-6/agent-app-frontend>|<http://172.29.5.12:3000>|<https://trip.cos.tg>|
|Agent 应用 后端|<http://172.29.4.49/2026seiii-016/agent-app-backend>|<https://github.com/Open-Codex-6/agent-app-backend>|<http://172.29.5.12:18151>||
|Agent 评估平台 前端|<http://172.29.4.49/2026seiii-016/agent-evaluation-frontend>|<https://github.com/Open-Codex-6/agent-evaluation-frontend>|<http://172.29.5.12:3001>|<https://eval.cos.tg>|
|Agent 评估平台 后端|<http://172.29.4.49/2026seiii-016/agent-evaluation-backend>|<https://github.com/Open-Codex-6/agent-evaluation-backend>|<http://172.29.5.12:15182>||

- 每次 clone 新仓库前，请按照 <https://se3.cos.tg/#/rules/git?id=%e8%ae%be%e7%bd%ae%e7%94%a8%e6%88%b7%e5%90%8d%e9%82%ae%e7%ae%b1%e3%80%81gpg> 的要求配置好 git 用户名、邮箱和 GPG key。

## 后端所需资源

## 评估

- 指标：可以自己想指标
  - 性能：响应时间、延迟、Token 消耗
  - 输出质量：路径规划的合理性、用户满意度
  - 其余自定义指标
- 自行构建 Benchmark
- 想法：消融掉不同的工具 / Memory，同时看看不同范式下性能的变化

## 进一步拓展项目

- Agent：Context Engineering/Memory，工具集选取，MCP，Agentic RL，上下文压缩……
- 应用功能本身
