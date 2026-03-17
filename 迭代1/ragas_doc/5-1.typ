== 管理评估样本数据

#table(
  columns: (20%, 20%, 25%, 35%),
  align: (center, center, center, center),
  table.header[*用户功能*][*系统功能*][*实现模块*][*实现方法/类*],

  table.cell(rowspan: 8)[管理评估样本数据],

  table.cell(rowspan: 4)[创建与管理数据],
  table.cell(rowspan: 2)[`dataset`],
  [`Dataset`],
  [`DataTable`],

  table.cell(rowspan: 2)[`dataset_schema`],
  [`SingleTurnSample`],
  [`MultiTurnSample`],

  table.cell(rowspan: 3)[数据集聚合与分发],
  table.cell(rowspan: 3)[`dataset_schema`],
  [`EvaluationDataset`],
  [`BaseSample`],
  [`EvaluationResult`],

  [上下文管理],
  [`messages`],
  [`Message`],
)

== 评估指标体系

#table(
  columns: (20%, 20%, 25%, 35%),
  align: (center, center, center, center),
  table.header[*用户功能*][*系统功能*][*实现模块*][*实现方法/类*],

  table.cell(rowspan: 12)[评估指标体系],

  table.cell(rowspan: 5)[丰富的预置指标],
  table.cell(rowspan: 4)[`metrics.`\ `base`],
  [`Metric`],
  [`SingleTurnMetric`],
  [`MultiTurnMetric`],
  [`MetricWithLLM`],
  [`metrics.`\ `discrete`], [`DiscreteMetric`],

  table.cell(rowspan: 4)[Agent 专项评估],
  [`metrics.`\ `_tool_call_accuracy`], [`ToolCallAccuracy`],
  [`metrics.`\ `_tool_call_f1`], [`ToolCallF1`],
  table.cell(rowspan: 2)[`metrics.`\ `_goal_accuracy`], [`AgentGoalAccuracy`\ `WithReference`],
  [`AgentGoalAccuracy`\ `WithoutReference`],

  table.cell(rowspan: 3)[自定义指标能力],
  [`metrics.`\ `base`], [`SimpleBaseMetric`],
  [`metrics.`\ `decorator`], [`CustomMetric`],
  [`metrics.`\ `validators`], [`BaseValidator`],
)

== 模型评估执行

#table(
  columns: (20%, 20%, 25%, 35%),
  align: (center, center, center, center),
  table.header[*用户功能*][*系统功能*][*实现模块*][*实现方法/类*],

  table.cell(rowspan: 7)[模型评估执行],

  table.cell(rowspan: 3)[同步与异步评估],
  [`executor`], [`Executor`],
  [`run_config`], [`RunConfig`],
  [`metrics.`\ `base`], [`Metric`],

  table.cell(rowspan: 2)[多维度评估报告],
  table.cell(rowspan: 2)[`dataset_schema`],
  [`EvaluationResult`],
  [`EvaluationDataset`],

  table.cell(rowspan: 2)[灵活的 LLM 配置],
  table.cell(rowspan: 2)[`llms.`\ `base`],
  [`BaseRagasLLM`],
  [`LangchainLLMWrapper`],
)