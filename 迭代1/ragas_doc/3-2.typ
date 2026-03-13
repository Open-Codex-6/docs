// TODO @kyt
// 请参考 `3-1.typ` 中 `核心模块` 的表格格式完成文档
== 测试集生成
#table(
  columns: (9%, 25%, 24%, 42%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述*],

  table.cell(rowspan: 17)[`ragas`],

  table.cell(rowspan: 3)[`testset.graph`],
  [`Node`], [知识图节点，封装实体属性与类型，是后续抽取、过滤和关系构建的基本单元。],
  [`Relationship`], [知识图边，连接两个节点并记录关系类型与属性，用于多跳推理路径构造。],
  [`KnowledgeGraph`], [测试集生成的核心数据结构，承载节点与关系，并提供增删改查与序列化能力。],

  table.cell(rowspan: 2)[`testset.persona`],
  [`Persona`], [用户画像模型，描述角色名称与背景，用于生成风格化、多样化查询。],
  [`Persona Generation Prompt`], [基于 `PydanticPrompt` 的人物生成提示模板，从知识图主题中自动构建 persona。],

  table.cell(rowspan: 2)[
    `testset.synthesizers.`\
    `base`
  ],
  [`BaseScenario`], [场景抽象数据模型，统一约束 single-hop 和 multi-hop 的输入结构。],
  [`BaseSynthesizer`], [查询合成器抽象基类，定义场景生成、样本生成与异步执行接口。],

  [
    `testset.synthesizers.`\
    `generate`
  ],
  [`Testset Generator`], [测试集生成入口类，协调文档转换、知识图构建、查询分布采样与最终 Testset 产出。],

  [
    `testset.synthesizers.`\
    `single_hop.`\
    `base`
  ],
  [`Single Hop Query Synthesizer`], [单跳查询合成器，针对单节点/单事实生成可直接检索的问题与答案。],

  [
    `testset.synthesizers.`\
    `multi_hop.`\
    `base`
  ],
  [`Multi Hop Query Synthesizer`], [多跳查询合成器，组合多个概念或节点关系，生成需要跨段推理的问题。],

  table.cell(rowspan: 2)[
    `testset.synthesizers.`\
    `testset_schema`
  ],
  [`TestsetSample`], [测试样本模型，保存 `user_input`、`reference` 等字段，作为评测最小单位。],
  [`Testset`], [测试集容器，聚合 TestsetSample 并提供导入导出与格式转换能力。],

  table.cell(rowspan: 3)[`testset.transforms.base`],
  [`Base Graph Transformation`], [图转换抽象基类，统一抽取、分割、关系构建、过滤等步骤的执行协议。],
  [`Extractor`], [从节点文本抽取结构化信息的基类，供 LLM、Regex、Embedding 提取器复用。],
  [`Relationship Builder`], [关系构建器基类，按相似度或规则在节点间创建边。],

  [
    `testset.transforms.`\
    `extractors.`\
    `llm_based`
  ],
  [`Summary Extractor`], [LLM 摘要提取器，生成节点摘要，服务于主题归纳与后续关系构建。],

  [
    `testset.transforms.`\
    `relationship_builders.`\
    `cosine`
  ],
  [`Cosine Similarity Builder`], [通过向量余弦相似度构建节点关系，形成语义邻接结构。],
)

== LLM 和嵌入

#table(
  columns: (9%, 25%, 24%, 42%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 13)[`ragas`],

  table.cell(rowspan: 4)[`llms.base`],
  [`Base Ragas LLM`], [LLM 抽象基类，统一同步、异步生成、重试、温度策略与完成态检查。],
  [`Langchain LLM Wrapper`], [将 LangChain BaseLanguageModel 适配为 Ragas LLM 接口，兼容 `n-completion` 与回调链路。],
  [`Llama Index LLM Wrapper`], [将 LlamaIndex LLM 适配为 Ragas LLM 接口，复用统一的生成与追踪机制。],
  [`Instructor Base Ragas LLM`], [结构化输出 LLM 抽象层，面向 Pydantic 模型约束的 JSON 输出生成。],

  [`llms.adapters.base`],
  [`Structured Output Adapter`], [结构化输出适配器基类，屏蔽不同提供方在 schema 与调用方式上的差异。],

  [
    `llms.adapters.`\
    `litellm`
  ],
  [`Lite LLM Adapter`], [LiteLLM 结构化输出适配器，用统一接口接入多家模型服务。],

  [`llms.litellm_llm`],
  [`Lite LLM Structured LLM`], [LiteLLM 的结构化 LLM 实现，直接提供 `response_model` 驱动的生成能力。],

  table.cell(rowspan: 3)[`embeddings.base`],
  [`Base Ragas Embedding`], [现代 embedding 抽象基类，定义 `embed_text` 与 `embed_texts` 的同步、异步语义。],
  [`Base Ragas Embeddings`], [LangChain Embeddings 兼容抽象层，支持 `run_config`、缓存和批处理行为统一。],
  [`Langchain Embeddings Wrapper`], [将 LangChain embeddings 包装为 Ragas 可用对象，便于旧代码迁移。],

  [
    `embeddings.`\
    `openai_provider`
  ],
  [`OpenAI Embeddings`], [OpenAI 向量模型实现，常用于语义检索和关系构建。],

  [
    `embeddings.`\
    `huggingface_provider`
  ],
  [`HuggingFace Embeddings`], [Hugging Face embedding 提供者实现，支持本地与远程模型。],

  [
    `embeddings.`\
    `litellm_provider`
  ],
  [`LiteLLM Embeddings`], [LiteLLM embedding 统一接入层，便于跨提供方切换模型。],
)

== 提示系统

#table(
  columns: (9%, 25%, 24%, 42%),
  align: (center, center, center, center),
  table.header[*包*][*模块*][*类*][*描述与作用*],

  table.cell(rowspan: 12)[`ragas`],

  table.cell(rowspan: 2)[`prompt.base`],
  [`Base Prompt`], [提示系统抽象基类，约束生成接口与序列化能力，是所有 prompt 组件的共同父类。],
  [`String Prompt`], [最简字符串提示模板，适用于轻量任务和快速格式化输出。],

  [`prompt.mixin`],
  [`Prompt Mixin`], [为合成器、提取器提供 prompt 注册、覆写和配置能力的混入类。],

  table.cell(rowspan: 3)[
    `prompt.`\
    `pydantic_prompt`
  ],
  [`Pydantic Prompt`], [核心泛型提示类，支持 `Input`、`Output` Pydantic 模型、`JSON schema` 约束与解析重试。],
  [`Ragas Output Parser`], [输出解析器，负责把 LLM 文本解析为目标 Pydantic 模型并统一异常语义。],
  [`Fix Output Format`], [输出修复提示模板，用于在解析失败时重构格式并提升可解析率。],

  table.cell(rowspan: 2)[
    `prompt.`\
    `few_shot_pydantic_prompt`
  ],
  [`Example Store`], [少样本示例仓库抽象接口，定义检索与更新示例的方法。],
  [`FewShot Pydantic Prompt`], [少样本增强版 PydanticPrompt，支持示例拼接与语义检索驱动示例选择。],

  [
    `prompt.`\
    `dynamic_few_shot`
  ],
  [`Dynamic FewShot Prompt`], [动态 `few-shot` 提示类，按输入实时检索最相关示例以提升生成质量。],

  table.cell(rowspan: 2)[
    `prompt.`\
    `multi_modal_prompt`
  ],
  [`ImageText Prompt`], [多模态提示类，组合图片与文本上下文完成视觉和文本联合推理。],
  [`ImageText PromptValue`], [多模态提示值对象，封装可发送到底层模型的图文消息结构。],

  [
    `prompt.metrics.`\
    `base_prompt`
  ],
  [`Base Prompt`], [指标提示基类，专用于 `metric` 评分链路，支持多语言模板与结构化输出。],
)