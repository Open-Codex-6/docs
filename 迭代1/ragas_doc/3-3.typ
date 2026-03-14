// TODO @zyf
// 请参考 `3-1.typ` 中 `核心模块` 的表格格式完成文档

== 优化器
#table(
  columns: (20%, 20%, 33%, 27%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 17)[`ragas.optimizers`],

  table.cell(rowspan: 1)[`base`],
  [`Optimizer`], [抽象基类：定义 `optimize` 抽象方法及优化器通用属性（如 `metric`、`llm`）。所有具体优化器应继承此类并实现优化流程，保证接口一致性与可插拔性。],

  table.cell(rowspan: 6)[`genetic`],
  [`GeneticOptimizer`], [基于遗传算法的主要优化器实现：实现端到端的优化流程（种群初始化、反馈变异、交叉变异、适应度评估），并负责并行执行、进度汇报与最终候选选择。对 prompt 变异与候选评估有完整的控制逻辑。],
  [`FormattedExamples`], [辅助数据模型：把原始示例转换为用于 Prompt 生成/反向工程的结构化示例列表（用于 `ReverseEngineerPrompt` 的输入）。],
  [`OutputInstruction`], [Pydantic 输出模型：包装生成的指令文本，作为 prompt 类输出的结构化格式。],
  [`ReverseEngineerPrompt`], [Prompt 类（`PydanticPrompt` 派生）：用于根据人工注释样本反推最可能的指示（instruction），作为生成初始候选的种子提示。],
  [`ParentPrompts`], [Pydantic 输入模型：包装两个父提示字符串，作为交叉操作的输入结构。],
  [`CrossOverPrompt`], [Prompt 类：用于对两个父提示执行“交叉”操作，生成子代提示，帮助在语义上结合父代信息以探索新候选。],

  table.cell(rowspan: 5)[`genetic (feedback)`],
  [`FeedbackExample`], [反馈示例数据模型：封装单个样本的输入/输出/期望输出，供反馈生成 prompt 使用。],
  [`FeedbackMutationInput`], [反馈生成 Prompt 的输入模型：包含指令与若干 `FeedbackExample`，用于请求模型产生对指令的改进意见。],
  [`FeedbackMutationOutput`], [反馈生成 Prompt 的输出模型：包含若干具体反馈字符串，用于后续指令改写。],
  [`FeedbackMutationPrompt`], [Prompt 类：生成针对给定指令与示例的改进反馈，限制反馈数量并避免建议通过修改示例来改进（聚焦指令本身）。],
  [`FeedbackMutation` `PromptGeneration`], [Prompt 类：根据指令与反馈集合生成改写后的指令文本（即将反馈落地为新的 prompt）。],

  table.cell(rowspan: 1)[`genetic (misc)`],
  [`-`], [其它内部函数与私有协程（如 `_reverse_engineer_instruction`、`_feedback_mutation`、`_cross_over_prompts` 等）负责与 LLM 的交互、candidate 的生成与组合，这些为 `GeneticOptimizer` 的子步骤实现。],

  table.cell(rowspan: 1)[`utils`],
   [ `hamming_distance` ], [工具函数：计算候选预测向量之间的汉明距离（返回距离矩阵），用于交叉变异阶段的父代选择（寻找行为差异最大的配对）。],

  table.cell(rowspan: 1)[`dspy_optimizer`],
  [`DSPyOptimizer`], [与外部库 DSPy 集成的高级优化器：将 Ragas 的 Prompt/数据/损失适配为 DSPy 格式，调用 MIPROv2 进行联合示例与指令搜索，支持参数校验与结果缓存（依赖 `dspy-ai`）。适合需要更系统搜索能力的场景。],

  table.cell(rowspan: 1)[`dspy_adapter`],
  [ `pydantic_prompt` `_to_dspy_signature`, `ragas_dataset` `_to_dspy_examples`, `create_dspy_metric`, `setup_dspy_llm` ], [适配器集合：负责把 Ragas 的 `PydanticPrompt`、注释数据与 Loss 转换为 DSPy 所需的 Signature、Example 与 metric 函数，并配置 DSPy 使用的 LLM。],

  table.cell(rowspan: 1)[`dspy_llm_wrapper`],
  [`RagasDSPyLM`], [LLM 适配器类：将 `BaseRagasLLM` 包装为 DSPy 可调用的 LM 接口，处理同步/异步调用差异并返回文本生成结果，方便 DSPy 在优化过程中直接调用 Ragas 的 LLM 实现。],
)


== 后端存储
#table(
  columns: (20%, 20%, 33%, 27%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 7)[`ragas.backends`],

  table.cell(rowspan: 1)[`base`],
  [`BaseBackend`], [抽象后端基类：定义存取数据集与实验（load/save/list）的统一接口契约，要求子类实现持久化细节并在缺失时抛出 FileNotFoundError，确保返回格式为 List[Dict]。],

  table.cell(rowspan: 1)[`inmemory`],
  [`InMemoryBackend`], [内存后端实现：将数据集与实验保存在进程内字典中，适用于测试与临时计算，提供深拷贝保护以避免外部修改，并实现与 BaseBackend 相同的公共接口。],

  table.cell(rowspan: 1)[`local_csv`],
  [`LocalCSVBackend`], [本地 CSV 文件后端：按目录分离 datasets/ 与 experiments/，以 CSV 格式持久化表格数据；适合简单扁平结构的数据，但会将复杂结构扁平化为字符串。],

  table.cell(rowspan: 1)[`local_jsonl`],
  [`LocalJSONLBackend`], [本地 JSONL 文件后端：以 JSONL（每行一个 JSON 对象）保存数据，保留嵌套结构与常见 Python 类型（含 datetime 的序列化/反序列化逻辑），适用于复杂数据与大规模流式写入场景。],

  table.cell(rowspan: 1)[`registry`],
  [`BackendRegistry`], [后端注册表类：单例模式管理可用后端的发现、注册、别名与创建，支持通过 setuptools entry points 自动发现插件后端并提供 dict-like 访问接口（create/get/register/aliases 等）。],

  table.cell(rowspan: 1)[`gdrive_backend`],
  [`GDriveBackend`], [Google Drive 后端实现：将数据集与实验保存为 Google Sheets，支持 OAuth 与 Service Account 两种认证方式，负责在指定 Drive 文件夹下创建/读取表格并做类型转换与错误处理。],

  table.cell(rowspan: 1)[`utils`],
  [`MemorableNames`], [实用类：生成可记忆且通常唯一的名称（如 "adjective_scientist"），用于为实验或数据集生成人类友好的默认标识，内置去重与批量生成方法。],
)


== 集成
#table(
  columns: (20%, 20%, 33%, 27%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 11)[`ragas.` `integrations`],

  table.cell(rowspan: 3)[`tracing.langfuse`],
  [`LangfuseTrace`], [Langfuse trace 的封装类：包装 Langfuse 返回的 trace 对象，提供统一的 `get_url()` 与简单过滤方法，并在缺少依赖时通过类型桩保持兼容。],

  
  [`TraceWithFullDetails`], [描述 Langfuse trace 的详细数据结构类型：包含完整的 trace 元数据、观测（observations）、分数与其他辅助字段，便于消费端解析与显示。],

  
  [`Observation`], [Langfuse trace 中单个观测项的类型桩：表示在 trace 中记录的单条观测记录的字段与结构，供代码在缺少真实依赖时类型检查使用。],

  table.cell(rowspan: 3)[`tracing.mlflow`],
  [`MLflowTrace`], [MLflow trace 的封装类：将 mlflow 的 trace 对象包装为统一接口，负责根据环境构造可访问的 trace URL 并提供按 span 名称过滤的能力。],

  
  [`Span`], [mlflow 中单个 span 的类型/兼容桩：表示 trace 中的 span 条目（主要用于按名称筛选与展示）。],

  
  [`Trace`], [mlflow trace 的类型/兼容桩：包含 trace 的元信息（如 request_id、experiment_id）并提供按名称搜索 spans 的方法，供封装类构造 URL 与做过滤。],

  table.cell(rowspan: 1)[`langchain`],
  [`EvaluatorChain`], [将 Ragas 的 `Metric` 适配为 LangChain/ LangSmith 的 Chain/RunEvaluator：负责输入/输出键映射、将 LLM/Embeddings 懒注入为 LangChain 可用 wrapper，并在 chain 调用时执行 metric 评估。],

  table.cell(rowspan: 1)[`opik`],
  [`OpikTracer`], [继承并扩展 Opik/LangChain 的 tracer：拦截评估流程的 start/end 事件，区分评估 run 与子 trace，并向 Opik 平台上报评分与元数据。],

  table.cell(rowspan: 1)[`ag_ui`],
  [`AGUIEventCollector`], [AG-UI 协议事件收集与重构核心类：从流式事件或快照重建完整消息，管理 streaming triads（Start/Content/End）与工具调用状态，最终输出可供 Ragas 评估使用的消息列表。],

  table.cell(rowspan: 2)[`helicone`],
  [`HeliconeSingleton`], [Helicone 集成的单例配置类：集中管理 API 密钥、base_url 与可选缓存配置，提供 `default_headers()` 生成用于 Helicone 请求的 header 集合并暴露是否启用的判断。],

  [`CacheConfig`], [缓存配置数据类：定义缓存的 TTL 与最大大小（`ttl`, `maxsize`），用于 Helicone 客户端的缓存策略配置。],

)
== 工具模块
#table(
  columns: (9%, 25%, 24%, 42%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 4)[`ragas`],

  table.cell(rowspan: 4)[`utils`],
  [`DeprecationHelper`], [处理过时类/函数的包装器：在调用被弃用的 API 时发出 DeprecationWarning 并委托到新的目标实现；当通过属性访问时也会发出警告，便于平滑迁移和兼容旧导出。],

  [`_ContextualFormatter`], [自定义日志格式化器：扩展 `logging.Formatter`，在日志记录中注入 UTC/local 时间、Ragas 用户 ID（ragas_id）、应用版本等上下文字段，统一日志格式以便可观测性与追踪。],

  [`ProgressBarManager`], [进度条管理器：封装 `tqdm` 的单条与嵌套批处理进度条创建与更新逻辑，便于在批量/异步任务中展示进度与分批进度细节。],

  [`MemorableNames`], [可记忆名称生成器：生成类似 `adjective_scientist` 的友好名称并维护去重集合，支持单个/批量生成，常用于为实验或数据集生成默认标识符。],

)