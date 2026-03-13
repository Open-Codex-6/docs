// TODO @wh
// 请参考 `3-1.typ` 中 `核心模块` 的表格格式完成文档

== 核心模块

#table(
  columns: (15%, 25%, 15%, 45%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述*],
  [`A`], [`BB`], [`CCC`], [这是描述], // 参考

  [`src.ragas`],
  [`evaluation.py`],
  [`evaluate()` (函数) ],
  [*主评估同步入口*。接收测试数据集和指标列表，自动解析样本类型，并调度 `Executor` 启动评估流水线，最终汇总返回评估结果。],

  [`src.ragas`],
  [`evaluation.py`],
  [`aevaluate()` (函数) ],
  [*异步主跑入口（Deprecated/Async封装）*。在评估大量 Agent 多轮对话轨迹时，利用协程环境提供无阻塞的高并发评测执行。],

  [`src.ragas`],
  [`experiment.py`],
  [`Experiment`],
  [*实验管理器类*。用于在多次迭代或系统微调中，版本化跟踪 Agent 评估流水线的配置、数据集以及产生的评估结果历史记录。 ],

  [`src.ragas`],
  [`executor.py`],
  [`Executor`],
  [*并发与任务调度类*。针对 Agent 指标常常需要做复杂 LLM 验证的特性，提供严密的协程池管理、针对单个对话样本的报错隔离以及降级策略。],

  [`src.ragas`],
  [`run_config.py`],
  [`RunConfig`],
  [*全局运行时配置类*。设定底层调用 LLM 时的超时时间(Timeout)、并发上限(Max workers)和重试次数(Retries)等，保障长链路 Agent 评估的稳定性。],

  [`src.ragas`],
  [`dataset.py`],
  [`DataTable`],
  [*数据表泛型基类*。处理底层结构化数据的通用逻辑，支持将评估所需数据透明化转换为 Pandas DataFrame 或是 Python Dict。 ],

  [`src.ragas`],
  [`dataset.py`],
  [`Dataset`],
  [*封装数据集类*。继承自 `DataTable`，封装数据加载操作，作为更上层业务数据的载体。],

  [`src.ragas`],
  [`dataset_schema.py`],
  [`BaseSample`],
  [*评估样本的数据基类*。基于 Pydantic 设计，向下统一规范各个指标能够提取、处理的数据对象接口。],

  [`src.ragas`],
  [`dataset_schema.py`],
  [`SingleTurn-Sample`],
  [*单轮样本类*。针对于传统场景（如单一 RAG 知识库问答）定义，含 `user_input`, `retrieved_contexts`, `response` 等字段。],

  [`src.ragas`],
  [`dataset_schema.py`],
  [`MultiTurn-Sample`],
  [*Agent评估核心数据类*。多轮交互样本的定义，接收对话消息列表。它是所有面向 Agent 测试指标（例如对话逻辑跟踪、多步 Agent 任务图表）的数据载体起点。],

  [`src.ragas`],
  [`dataset_schema.py`],
  [`Evaluation-Dataset`],
  [*核心评估数据集合类*。作为最直接传入引擎的对象，用来强类型挂载 `SingleTurnSample` 和 `MultiTurnSample` 进行混合或批量评估检验。],

  [`src.ragas`],
  [`dataset_schema.py`],
  [`Evaluation-Result`],
  [*评估结果数据类*。用于聚合、统计执行完的所有指标得分以及记录未能成功评估的数据栈（Exceptions），保障反馈闭环。],

  [`src.ragas`],
  [`messages.py`],
  [`Message` / `Human-Message` / `AIMessage` / `ToolMessage`],
  [*Agent评估核心上下文实体*。针对多轮对话封装的具体角色消息实体。将文本严格化为带意图和角色的记录，便于下游的 Agent 行为审查器去评判特定轮次的执行是否正确。],

  [`src.ragas`],
  [`messages.py`],
  [`ToolCall`],
  [*Agent工具链测评数据类*。结构化描述 Agent 所调用的具体函数名（Name）及入参参数字典（Args），是 `tool_call_accuracy` 等指标直接提取与匹配评分的原材料。],
)

== 指标系统

#table(
  columns: (15%, 25%, 15%, 45%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述*],
  [`src.ragas
  .metrics`],
  [`base.py`],
  [`Metric`],
  [*所有评估指标的抽象基类 (ABC)*。统一定义了 `name` 属性和初始化方式，强制所有派生指标遵循一致的接口约定。],

  [`src.ragas
  .metrics`],
  [`base.py`],
  [`Metric-WithLLM`],
  [*需要调用大模型作为“裁判”的指标基类*。继承自 `Metric`，内置了 Prompt 管理和 LLM 调用的基础能力逻辑。大部分高阶 Agent 指标都继承于此。],

  [`src.ragas
  .metrics`],
  [`base.py`],
  [`Single-TurnMetric`],
  [*单轮对话指标接口类*。针对常规一问一答提取特征，内部定义了处理 `SingleTurnSample` 的抽象验证与打分逻辑。],

  [`src.ragas
  .metrics`],
  [`base.py`],
  [`MultiTurn-Metric`],
  [*Agent评估核心基类*。多轮对话指标接口类。专门用于接收和解析 `MultiTurnSample`（即 Agent 长历史轨迹），所有 Agent 专属的行为/意图评价类必须实现此接口。],

  [`src.ragas
  .metrics`],
  [`validators.py`],
  [`Discrete-Validator` / `Numeric-Validator` ],
  [*指标结果的类型验证器类*。用于校验不同指标的输出格式（离散类别如 Yes/No，或连续数值如 0.0-1.0），保障传入汇总模块前的类型安全。],

  [`src.ragas
  .metrics`],
  [`decorator.py` ],
  [`@metric` (装饰器) ],
  [*指标工厂装饰器*。允许用户直接写一个判别函数，自动将其转换为 `SimpleBaseMetric` 子类，对需要按业务快速自定义 Agent 特定规则指标非常有用。],

  [`src.ragas
  .metrics`],
  [`discrete.py` / `numeric.py`],
  [`Discrete-Metric` / `Numeric-Metric` ],
  [*常规大语言模型简单指标基类*。将 LLM 调用和 `Validator` 验证器结合的通用模板，方便派生基础的判定指标。],

  [`src.ragas
  .metrics`],
  [`goal_accuracy.py`],
  [`AgentGoal-Accuracy-With-Reference` ],
  [*Agent目的达成率指标类（有参）*。继承自多轮评估基类。输入 Agent 的完整多轮执行轨迹和预期目标，通过 LLM 裁定 Agent 最终是否跨多步达成了既定目标。],

  [`src.ragas
  .metrics`],
  [`goal_accuracy.py`],
  [`AgentGoal-Accuracy-Without-Reference`],
  [*Agent目的达成率指标类（无参）*。在没有标准答案介入的情境下，仅凭 Agent 的对话轨迹和工具响应，自主评判其是否逻辑自洽地达成了用户诉求。],

  [`src.ragas
  .metrics`],
  [`tool_call
  _accuracy.py`],
  [`ToolCall-Accuracy` ],
  [*Agent工具链准确率类*。用于微观检验 Agent 行动（Action）的指标。精确比对 Agent 在历史轨迹中作出的 Tool Calls（工具名及参数）与标准解的正确匹配度。],

  [`src.ragas
  .metrics`],
  [`tool_call_f1.py`],
  [`ToolCallF1` ],
  [*Agent工具链F1分数类*。基于多轮会话计算工具调用的 Precision 和 Recall，评价 Agent 是否出现“乱调用（召回误报）”或“漏调用（未采取应有行动）”。],

  [`src.ragas
  .metrics
  .collections`],
  [`base.py`],
  [`BaseMetric` ],
  [*面向预组合包的业务指标基类*。集成验证器与基础功能，为 `collections` 下的即用型纯文本指标（如 Rouge、Bleu 等用于补充观测的辅助指标）提供规范。],
)
