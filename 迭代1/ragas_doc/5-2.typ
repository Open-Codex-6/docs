== 实验管理与版本控制

#table(
  columns: (20%, 20%, 25%, 35%),
  align: (center, center, center, center),
  table.header[*用户功能*][*系统功能*][*实现模块*][*实现方法/类*],

  table.cell(rowspan: 7)[实验管理与版本控制],

  table.cell(rowspan: 2)[实验追踪],
  table.cell(rowspan: 2)[`experiment`],
  [`Experiment`],
  [`ExperimentWrapper`],

  [版本控制集成],
  [`experiment`],
  [`version_experiment()`],

  table.cell(rowspan: 4)[实验结果存储],
  table.cell(rowspan: 4)[`backends`],
  [`BaseBackend`],
  [`LocalCSVBackend`],
  [`LocalJSONLBackend`],
  [`GDriveBackend`],
)

== 测试数据自动生成

#table(
  columns: (20%, 20%, 25%, 35%),
  align: (center, center, center, center),
  table.header[*用户功能*][*系统功能*][*实现模块*][*实现方法/类*],

  table.cell(rowspan: 8)[测试数据自动生成],

  table.cell(rowspan: 3)[智能数据合成],
  [`testset.`\ `synthesizers.`\ `generate`], [`TestsetGenerator`],
  [`testset.`\ `graph`], [`KnowledgeGraph`],
  [`testset.`\ `synthesizers.`\ `base`], [`BaseSynthesizer`],

  table.cell(rowspan: 2)[RAG 和 Agent\ 场景支持],
  [`testset.`\ `synthesizers.`\ `single_hop.`\ `base`], [`SingleHopQuerySynthesizer`],
  [`testset.`\ `synthesizers.`\ `multi_hop.`\ `base`], [`MultiHopQuerySynthesizer`],

  table.cell(rowspan: 3)[可配置的生成策略],
  table.cell(rowspan: 3)[`testset.`\ `transforms.`\ `base`],
  [`BaseGraphTransformation`],
  [`Extractor`],
  [`RelationshipBuilder`],
)

== 框架集成与可观测性

#table(
  columns: (20%, 20%, 25%, 35%),
  align: (center, center, center, center),
  table.header[*用户功能*][*系统功能*][*实现模块*][*实现方法/类*],

  table.cell(rowspan: 9)[框架集成与可观测性],

  table.cell(rowspan: 4)[主流框架集成],
  [`integrations.`\ `langchain`], [`EvaluatorChain`],
  [`integrations.`\ `ag_ui`], [`AGUIEventCollector`],
  table.cell(rowspan: 2)[`llms.base`], [`LangchainLLMWrapper`],
  [`LlamaIndexLLMWrapper`],

  table.cell(rowspan: 4)[可观测性工具集成],
  [`integrations.`\ `tracing.`\ `langfuse`], [`LangfuseTrace`],
  [`integrations.`\ `tracing.`\ `mlflow`], [`MLflowTrace`],
  [`integrations.`\ `opik`], [`OpikTracer`],
  [`integrations.`\ `helicone`], [`HeliconeSingleton`],

  [统一的回调接口],
  [`callbacks`],
  [`Callbacks`],
)