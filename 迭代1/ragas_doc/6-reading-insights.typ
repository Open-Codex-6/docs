= 阅读收获

== 亮点

在阅读 Ragas 框架的代码实现过程中，我们发现了很多值得借鉴的架构设计和具体实现的方法。

=== 可插拔的后端存储架构

Ragas 框架采用了高度模块化的后端存储设计，通过定义统一的抽象基类 `BaseBackend`，将数据持久化逻辑与核心评估业务逻辑彻底解耦。

这种设计不仅提供了内存、本地文件（CSV/JSONL）以及云端存储（Google Drive）等多种开箱即用的实现方案，以适应从快速原型开发到团队协作的不同场景，还利用 Python 的 entry points 机制构建了灵活的插件注册系统，使得开发者能够在不侵入核心代码库的前提下，轻松扩展自定义存储后端，从而极大地提升了系统的可维护性和对不同基础设施的适应能力。

#figure(
  image("images/6-backends.png", width: 50%),
  caption: "后端的文件结构",
)

```toml
# pyproject.toml
[project.entry-points."ragas.backends"]
"local/csv" = "ragas.backends.local_csv:LocalCSVBackend"
"local/jsonl" = "ragas.backends.local_jsonl:LocalJSONLBackend"
"inmemory" = "ragas.backends.inmemory:InMemoryBackend"
"gdrive" = "ragas.backends.gdrive_backend:GDriveBackend"
```

=== 实验驱动的评估框架

Ragas 创新性地引入了实验驱动的评估范式，通过*装饰器模式*将普通的评估函数无缝转换为可追踪、可管理的实验对象，实现了评估逻辑与实验元数据的有机结合。

使用装饰器 `@experiment`，开发者可以轻松定义评估函数的输入输出格式、指定后端存储方案，并自动获得版本控制和结果追踪等功能，从而极大地简化了评估流程的管理和结果的可复现性。这种可以提升实验效率和结果可靠性的设计是值得我们在未来的项目中借鉴的。

```python
# /examples/ragas_examples/ag_ui_agent_experiments/experiments.py
@experiment(
    experiment_model=CustomModel,
    backend="local/csv",
    name_prefix="rag_v1"
)
async def evaluate_rag(row):
    # 评估逻辑
    response = await rag_system(row["query"])
    return {"response": response, **row}

# 自动版本化
version_experiment("rag_v1", create_branch=True)
```

=== 异步优先的执行引擎

在执行效率方面，Ragas 构建了一个高效的异步优先执行引擎，通过 `Executor` 类对 Python 的 `asyncio` 库进行了深度封装，实现了评估任务的高并发处理。

该引擎不仅支持细粒度的任务并发以显著缩短大规模数据集的评估时间，还引入了灵活的批处理机制来平衡内存消耗与吞吐量，同时完善的任务取消机制和异常处理策略保证了在长时间运行任务中的系统稳定性与控制力。

在后续我们复现 Agent 评估框架的过程中，面对大批量的评估任务时，可以借鉴 Ragas 的这种异步执行设计，以提升评估效率和系统的健壮性。

```python
@dataclass
class Executor:
    async def _process_batched_jobs(
        self, jobs_to_process, progress_manager, max_workers, results
    ):
        """Process jobs in batches with nested progress tracking."""
        batch_size = self.batch_size or len(jobs_to_process)
        batches = batched(jobs_to_process, batch_size)
        overall_pbar, batch_pbar, n_batches = progress_manager.create_nested_bars(
            len(jobs_to_process), batch_size
        )

        with overall_pbar, batch_pbar:
            for i, batch in enumerate(batches, 1):
                # 检查任务取消状态，及时退出以节省资源
                if self.is_cancelled():
                    break

                progress_manager.update_batch_bar(batch_pbar, i, n_batches, len(batch))

                # 创建协程列表以并发执行当前批次的所有任务
                coroutines = [
                    afunc(*args, **kwargs) for afunc, args, kwargs, _ in batch
                ]

                async for result in process_futures(
                    as_completed(
                        coroutines, max_workers, cancel_check=self.is_cancelled
                    )
                ):
                    # 如果任务执行过程中出现异常，根据配置决定是否抛出异常或继续处理剩余任务
                    if isinstance(result, Exception) and self.raise_exceptions:
                        raise result
                    results.append(result)
                    batch_pbar.update(1)
                # 更新总体进度条，反映已处理的任务数量
                overall_pbar.update(len(batch))
```

=== 双 Judge 评估策略

在提升基于 LLM 的评估（LLM-as-a-Judge）的客观性方面，Ragas 引入了创新的双 Judge 评估策略，借鉴了 NVIDIA 的相关研究成果，通过引入视角的对称性来抵消单一模型可能存在的评估偏差。

该策略设计了互为镜像的两个评估角色分别对“用户回答-参考答案”对进行独立打分，并将异构的评分结果标准化到统一区间后进行融合，这种方法不仅在不依赖大量人工标注数据的情况下显著提升了评估结果的一致性与鲁棒性，还通过算法设计层面的优化有效降低了模型幻觉对评估质量的影响。这种评估方法在我们未来设计 Agent 评估框架时，可以作为借鉴对象，以提升评估的客观性和可靠性。

```python
class AnswerAccuracy(BaseMetric):
    """
    Answer Accuracy metric using dual-judge evaluation.

    Measures answer accuracy compared to ground truth using a dual-judge system.
    This metric averages two distinct judge prompts to ensure robust evaluation.

    The metric uses NVIDIA's proven dual-judge approach:
    1. Judge 1: Direct User Answer vs Reference Answer comparison
    2. Judge 2: Swapped perspective for fairness
    3. Average both judges for final score

    Rating scale: 0 (no match), 2 (partial match), 4 (exact match)
    Final score: Average of both judges converted to 0.0-1.0 scale

    Attributes:
        llm: Modern instructor-based LLM for dual-judge evaluation
        name: The metric name
        allowed_values: Score range (0.0 to 1.0, higher is better)
        max_retries: Maximum retry attempts for invalid ratings
    """

    async def ascore(
        self, user_input: str, response: str, reference: str
    ) -> MetricResult:
        """
        Calculate answer accuracy score using dual-judge evaluation.

        Args:
            user_input: The original question
            response: The user's answer to evaluate
            reference: The ground truth reference answer

        Returns:
            MetricResult with answer accuracy score (0.0-1.0, higher is better)
        """
        # Input validation
        if not user_input:
            raise ValueError(
                "user_input is missing. Please add user_input to the test sample."
            )
        if not response:
            raise ValueError(
                "response is missing. Please add response to the test sample."
            )
        if not reference:
            raise ValueError(
                "reference is missing. Please add reference to the test sample."
            )

        # Get ratings from both judges
        judge1_rating = await self._get_judge_rating(
            self.judge1_prompt, user_input, response, reference
        )
        judge2_rating = await self._get_judge_rating(
            self.judge2_prompt, user_input, reference, response
        )  # Note: swapped order for judge 2

        # Average the scores (convert from 0,2,4 scale to 0.0-1.0)
        score = self._average_scores(judge1_rating / 4.0, judge2_rating / 4.0)

        return MetricResult(value=float(score))
```

== 反思

在深入阅读 Ragas 庞大而复杂的代码库过程中，我们也发现了一些值得改进的地方。

=== 缺乏统一的模型兼容层

当前实现的 `_map_openai_params` 方法存在大量针对特定未来模型版本的硬编码，在架构设计上存在明显的局限性。通过在代码中直接嵌入针对特定版本号（如 `o1` 至 `o9` 以及 `gpt-5` 至 `gpt-19`）的正则化判断与逻辑约束，系统严重违反了软件工程中的“开闭原则”。这种设计意味着框架对扩展是不开放的，每当模型供应商发布超出预设命名范围的新模型时，开发者必须介入并修改核心源代码，而非通过简单的配置更新来适配新特性。

```python
def _map_openai_params(self) -> t.Dict[str, t.Any]:
        """Map parameters for OpenAI/Azure reasoning models with special constraints.

        Pattern-based matching for future-proof coverage:
        - O-series: o1, o2, o3, o4, o5, ... (all reasoning versions)
        - GPT-5 series: gpt-5, gpt-5-*, gpt-6, gpt-7, ... (all GPT-5+ models)
        - Other: codex-mini
        """
        mapped_args = self.model_args.copy()

        model_lower = self.model.lower()

        # Pattern-based detection for reasoning models that require max_completion_tokens
        # Uses prefix matching to cover current and future model variants
        def is_reasoning_model(model_str: str) -> bool:
            """Check if model is a reasoning model requiring max_completion_tokens."""
            # O-series reasoning models (o1, o1-mini, o1-2024-12-17, o2, o3, o4, o5, o6, o7, o8, o9)
            # Pattern: "o" followed by single digit 1-9, then optional "-" or end of string
            # TODO: Update to support o10+ when OpenAI releases models beyond o9
            if (
                len(model_str) >= 2
                and model_str[0] == "o"
                and model_str[1] in "123456789"
            ):
                # Allow single digit o-series: o1, o2, ..., o9
                if len(model_str) == 2 or model_str[2] in ("-", "_"):
                    return True

            # GPT-5 and newer generation models (gpt-5, gpt-5-*, gpt-6, gpt-7, ..., gpt-19)
            # Pattern: "gpt-" followed by single or double digit >= 5, max 19
            # TODO: Update to support gpt-20+ when OpenAI releases models beyond gpt-19
            if model_str.startswith("gpt-"):
                version_str = (
                    model_str[4:].split("-")[0].split("_")[0]
                )  # Get version number
                try:
                    version = int(version_str)
                    if 5 <= version <= 19:
                        return True
                except ValueError:
                    pass

            # Other specific reasoning models
            if model_str == "codex-mini":
                return True

            return False

        # 省略其他模型参数映射逻辑...

        return mapped_args
```

=== 对 `LangChain` 框架的硬性依赖

Ragas 在架构设计上过度耦合了 LangChain 生态系统，对于整个软件的可扩展性和生态兼容性造成了严重的限制。

这种硬性依赖不仅体现在核心依赖库（如 `langchain-core` 和 `langchain-community`）的直接引入，更深层地渗透到了其内部的数据交换协议中。由于框架底层强行绑定了 LangChain 特有的 `LLMResult` 数据结构（如特定的 `generations` 多维数组格式），导致其在接入非 OpenAI 或非 LangChain 原生模型时表现出极差的兼容性。

在当前 LLM 推理后端（如 vLLM, TensorRT-LLM）快速演进的背景下，这种缺乏抽象层和标准化接口规范的现状，使得框架难以原生支持高吞吐的工业级评价场景，成为制约大规模评估任务性能提升的瓶颈。

在 #link("https://github.com/vibrantlabsai/ragas/issues/2058")[Issue \#2058]中，由于这种缺乏接口隔离的设计，迫使开发者在尝试使用 vLLM 等高性能推理引擎加速评估时，必须在外部编写冗余且别扭的异步转换代码，仅仅是为了对齐框架内部的封装逻辑，这种无意义的数据格式转换极大地降低了系统集成的灵活性与执行效率。

#figure(
  image("images/6-Issue-2058.png", width: 50%),
  caption: "Issue #2058 中的 vLLM 适配问题",
)
