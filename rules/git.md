# Git 协作规范

## Git 配置

### 设置用户名和邮箱

> 每次 clone 仓库均应进行以下配置

```bash
# 参见 2026软⼯三-团队创建与软件过程要求 2.4
git config user.name "姓名拼音"
git config user.email "校园邮箱" 
```

### 一些便于协作的配置

> 以下为全局配置，只需进行一次即可

```bash
git config --global merge.ff true # 启用 fast forward
git config --global pull.rebase true # 开启 pull rebase
```

## 分支规范

Git 库应该通过长期短期分支结合的方式进行版本管理。原则上，长期分支有 `main`；短期分支有 `feat` `fix`。

| **分支类型** | **描述** | **和其它分支交互** |
| --- | --- | --- |
| `main` | 稳定分支。代码经过充分测试，保持最可部署状态 | 分支锁定，只接受经过充分 Code Review 和测试的 Pull Request 合并 |
| `feat-xxx` | 特性分支。包含一个特性开发的最新进度 | 从 `main` 中分出；通过单元测试后可开 PR 并入 `main`，应以 rebase 方式时刻从 `main` 更新主线上最新的代码 |
| `fix-xxx` | 修复分支。包含一个 bug 修复的最新进度 | 从 `main` 中分出；通过单元测试后可开 PR 并入 `main`，应以 rebase 方式时刻从 `main` 更新主线上最新的代码 |

### 分支命名

- `feat-xxx` `fix-xxx` 中的 `xxx` 应当简明扼要地描述特性/修复的内容
  - 如：`feat-login-api` `fix-user-not-found`

## Commit Message 规范

Commit message 应由两部分组成， `type` 和 `description`， 形如 `[type]: [description]`

`type` 表示本次提交的性质， 应从以下中选择一个

- `feat` 增加新特性
- `test` 更新测试集
- `fix` 修复 BUG
- `docs` 更新文档
- `refactor` 重构
- `chore` 无实质性变动的修改
- `style` 风格 (如代码风格) 变动
- `perf` 性能优化
- `revert` 回滚版本

`description` 应当是一句话， 简明扼要地解释 Commit 内容

### 示例

- `feat: auto format` 增加自动格式化功能
- `chore: format` Github Actions Bot 自动格式化代码
- `fix: dot after h2 counter` 修复 `h2` 标题后多余的点号
- `docs: git rules` 更新 Git 规范文档

## 协作流程

> [!WARNING]
> 请确保开一次 PR 只对应一个功能的开发或一个 bug 的修复，切勿在一个 PR 中提交多个功能的开发或多个 bug 的修复！

- 每次开发某个功能或修复某个 bug 时，先从 `main` 分出一个新的分支， 命名为 `feat-xxx` 或 `fix-xxx`

```bash
git checkout main
git pull origin main # 确保本地 main 是最新的
git checkout -b feat-xxx
```

- 在新分支上进行开发，期间应当**时刻从 `main` 更新主线上最新的代码**

```bash
git fetch origin
git rebase origin/main
git push origin feat-xxx --force-with-lease # 由于 rebase 修改了提交历史，因此需要强制推送；使用 --force-with-lease 可以避免误操作导致的代码丢失
```

- 按照 Commit Message 规范提交代码，并推送到远程仓库

```bash
git add .
git commit -m "feat: xxx"
git push origin feat-xxx
```

- 一个功能的开发需要多次 commit，在全部开发完成后，先进行一次 rebase

```bash
git fetch origin
git rebase origin/main
git push origin feat-xxx --force-with-lease # 由于 rebase 修改了提交历史，因此需要强制推送；使用 --force-with-lease 可以避免误操作导致的代码丢失
```

- 随后在 Gitlab 上打开仓库，创建 Merge Request（也就是 Github 的 Pull Request）

![image-20260305095029800](./git.assets/image-20260305095029800.png)

- 在标题中用一句话介绍变更的主要内容，在描述中可以详细说明每个文件主要变更的内容（[示例](http://172.29.4.49/2026seiii-016/docs/-/merge_requests/1)）
- 提交后，QQ 通知负责人进行 Code Review 和测试
  - 若代码无需更改：负责人直接合并到 `main`，此次开发完成
  - 若代码需更改
    - 负责人在 Merge Request 中进行评论，开发者根据评论修改代码并 push 到远程仓库，**Merge Request 会自动更新**，无需额外操作
    - 在 push 完成后再次通知负责人进行 Code Review 和测试，直到代码满足要求为止
