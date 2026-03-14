== 核心模块

#table(
  columns: (9%, 25%, 24%, 42%),
  align: (center, center, center, left),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 14)[`ragas`],

  table.cell(rowspan: 2)[`experiment`],
  [`Experiment`], [实验环境管理器封装，继承自 `DataTable`，在迭代中进行版本控制与配置快照。],
  [`ExperimentWrapper`], [实验函数的包装器类，将加上 `@experiment` 装饰器的测试函数打包为标准协议接口。],

  [`executor`],
  [`Executor`], [异步任务统一调度器，管理工作协程池、批处理限流与单样本防崩溃重启。],

  [`run_config`],
  [`RunConfig`], [全生命周期的执行统筹配置类，挂载超时、最大重试及并发线程数限制设定。],

  table.cell(rowspan: 2)[`dataset`],
  [`DataTable`], [支持数据同步的基础表类，具备通用 CRUD 与底层将字典列转为对齐 `Pandas DataFrame` 的能力。],
  [`Dataset`], [应用层的核心数据集容器，面向终端的实体载体，支持不同 Backend 的快照存储。],

  table.cell(rowspan: 5)[`dataset_schema`],
  [`BaseSample`], [通用的 `Pydantic` 测例基类，约束测试输入的数据格式。],
  [`SingleTurnSample`], [单轮测例数据类，含 `user_input` 甚至附带 `retrieved_contexts`，适用于基准 `RAG` 模型。],
  [`MultiTurnSample`], [多轮对话测例数据类，代理/Agent 专属核心，搭载会话序列以追踪完整推演能力。],
  [`EvaluationDataset`], [用于聚合特定验证集的类型安全池，为引擎打包分发异构单多轮样本提供保障。],
  [`EvaluationResult`], [结构化的最终记分卡与反馈栈，包裹通过或失败评估的过程快照结果。],

  table.cell(rowspan: 3)[`messages`],
  [`Message`], [消息基类，面向人类/机器的意图表达基础。],
  [`Human/AIMessage`], [具体的聊天轮次对象，作为 `MultiTurnSample` 中的核心单元描摹会话时序。],
  [`ToolCall`], [结构化表达外部函数和执行特征参数的模型，是评估工具编排准确率（Agent 典型指标）的核心素材。],
)

== 指标系统

#table(
  columns: (9%, 25%, 24%, 42%),
  align: (center, center, center, left),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 20)[`ragas`],

  table.cell(rowspan: 7)[`metrics.base`],
  [`Metric`], [系统级顶层指标抽象，声明名字定义、同步计分及异步打分的实现协议规范。],
  [`MetricWithLLM`], [基于提示词和模型生成的有状态指标基类，包裹 LLM 配置和多项重试挂载属性。],
  [`SingleTurnMetric`], [适配于单轮事实或文档处理校验的特化基类，处理 `SingleTurnSample` 型对象。],
  [`MultiTurnMetric`], [为智能体或代理设置的长路径、意图评估基类，处理 `MultiTurnSample` 数据结构流。],
  [`SimpleBaseMetric`], [辅助指标混合类的泛型母类，是快速创建免大语言模型辅助判别逻辑的基底。],
  [`SimpleLLMMetric`], [快速构建模型主观验证任务的最简基类集，简化提示流开发。],
  [`ModeMetric`], [处理统计和众数运算的数值抽象协议实体。],

  table.cell(rowspan: 3)[`metrics.validators`],
  [`BaseValidator`], [对生成或推演结果的格式守门员接口。],
  [`DiscreteValidator`], [针对类似 是/否、对/错 等分类任务判定的离散数据验证器。],
  [`NumericValidator`], [处理比如相似度分数 (0.0-1.0) 这种含有连续精度概念量化产出的规范校验器。],

  table.cell(rowspan: 1)[`metrics.decorator`],
  [`CustomMetric`], [装饰器内部返回的动态构建类工厂产物。],

  table.cell(rowspan: 2)[`metrics.discrete` / `numeric`],
  [`DiscreteMetric`], [集成了基础大模型能力和固定类型验证器的混合型 (Mixin) 产物，专门输出离散属性。],
  [`NumericMetric`], [集成了连续验证器 (`NumericValidator`) 和简单验证模块的具体打分特化指标子类。],

  table.cell(rowspan: 2)[`metrics.`\
    `_goal_accuracy`],
  [`AgentGoalAccuracy`\
    `WithReference`],
  [具备标准答案对照的代理意图成功率模型，基于 LLM 解析最终回复以核对既定事实流。],
  [`AgentGoalAccuracy`\
    `WithoutReference`],
  [零样本标准下的代理目标判断器，强依赖基于上下问进行自然语言语义判别的闭环内聚性。],

  [`metrics.`\
    `_tool_call_accuracy`],
  [`ToolCallAccuracy`], [专注校验多轮调用步骤下工具选择/函数填参的命中正确度的确定性计算指标系统类。],

  [`metrics.`\
    `_tool_call_f1`],
  [`ToolCallF1`], [更进阶基于 Precision 与 Recall 结合，用以避免模型产生恶意“长尾胡乱工具调用尝试”的检测模型计算类。],

  table.cell(rowspan: 3)[`metrics.`\
    `collections.base`],
  [`BaseMetric`], [在集合模块为各个纯功能实现（如模糊匹配、字符串距离等）注入属性包装规范的基础。],
  [`DistanceMeasure`], [基础字符串算法库用于表达匹配编辑尺度的枚举支持映射层。],
  [`StringPresence`], [继承于大基类体系，专注于目标答案是否存在于生成的参考文档的验证规则实现子类。],
)
