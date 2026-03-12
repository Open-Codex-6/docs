// TODO @zjh

= 阅读收获

== 可插拔的后端存储架构

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

== 实验驱动的评估框架
