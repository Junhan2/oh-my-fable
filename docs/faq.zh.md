# 常见问题

[← oh-my-fable](../README.zh.md) · [한국어](faq.md) · [English](faq.en.md) · 中文

[安装与移除](#安装与移除) · [确认是否生效](#确认是否生效) · [界面显示](#界面显示) · [规则与设置](#规则与设置) · [模型](#模型) · [其他运行环境](#其他运行环境)

## 安装与移除

### 为什么想立即使用要先 `/reload-plugins` 再 `/clear`？

按官方文档，两者作用不同。`/reload-plugins` 会"无需重启地重新加载插件、技能、代理、钩子、MCP 服务器"（[Plugins](https://code.claude.com/docs/en/plugins)）。注入规则的 SessionStart 钩子只在 `startup`、`resume`、`/clear`、`compact`、`fork` 时运行（[Hooks](https://code.claude.com/docs/en/hooks#sessionstart)）。

所以 reload 只注册钩子而不运行它，在安装的那个会话里需要 `/clear` 让它运行一次。新开会话则两者都不需要。

### 如何移除？

`/fable-setup remove` 会删除配置文件、规则文件和 CLAUDE.md 段落。然后 `claude plugin uninstall oh-my-fable@oh-my-fable`。只想暂停，在 `~/.claude/oh-my-fable.json` 写入 `{"enabled": false}`。

## 确认是否生效

### 现在生效的是什么？

`/fable-status`。一张表列出插件版本、规则位置、本会话模式（含自动检测依据）、effort、规则文件版本、CLAUDE.md 冲突，不做任何改动。新开会话时同样的信息会以一行提示显示在屏幕上（不进入 Claude 的上下文）。

### `/plugin` 把 oh-my-fable 列在 "Not used recently" 下。

连续 14 天且 10 个会话没有被记录的使用时就会出现这个标题，而官方文档列出的"算作使用"的项目里没有钩子（plugins measure 文档），所以一段时间没输入 `/fable` 或其他命令时可能出现。注入规则的钩子在每个会话里照常运行，可以用 `/fable-status` 确认。

## 界面显示

### 请求卡片是什么？怎么关闭？

它把 `/fable` 展示的改写后请求在对话中画成卡片。它是 Claude Code 的 [mod](https://code.claude.com/docs/en/plugins/mods/overview)（在 Claude Code 内部运行的插件代码），只做一件事：重新绘制那一个代码块（`claude plugin validate` 列出的调用只有 `$.ui.resolve`）。

Claude 读到的内容和保存的对话都不变；回复输出过程中显示的是代码块，这一段回复结束后才变成卡片。在终端中，Claude Code 2.1.287 或更新版本会绘制，已在 2.1.292 上确认。桌面应用中也会绘制（已在内置 Claude Code 2.1.289 的应用上确认）；VS Code 扩展面板、`claude -p` 和 2.1.287 之前的版本仍显示代码块。

Claude Code 2.1.290 修复了 mod 绘制非拉丁文字的多行文本时界面卡顿的问题，2.1.295 修复了最后一个已知的卡片问题，因此建议使用 2.1.295 或更新版本。关闭方法：在 `/config` 里关掉 `Improved request card`（无需重启，立即生效），或 `/plugin` → oh-my-fable → Configure options。

安装时就关闭：`claude plugin install oh-my-fable@oh-my-fable --config card=false`。

### 怎么关闭每次开会话时显示的那一行？

在 `/config` 里关闭 oh-my-fable 的 `Status line at session start`。关闭后，安装后第一个会话的欢迎语、更新后的一行说明，以及需要你处理的提示仍会显示。

## 规则与设置

### CLAUDE.md 里已经有类似规则怎么办？

`/fable-setup` 会用表格列出。意思相同标为"已有"；意思相反（禁止排版、最后统一汇报）则给出替换文本。修改由你自己完成，因为 Claude Code 会阻止 AI 修改自己的 CLAUDE.md。

### 我想把规则放在 CLAUDE.md 以外的地方。

默认情况下，规则只存在于插件内部，由钩子每次会话注入，所以既不创建规则文件也不改 CLAUDE.md。推荐的设置是规则文件（`/fable-setup rules-file`）：Claude Code 的钩子文档建议不会变的规则放在文件而不是钩子文本里，代理团队也会读取它。CLAUDE.md 段落是第三种选择。比较表见[更改规则存放位置](setup.zh.md#更改规则存放位置)。

### `/fable-audit` 和 `/doctor prompt-audit` 有什么区别？

两者方向相反。`/fable-audit` 找出你的规则缺少提示指南的哪些节（要补的）；Claude Code 的 `/doctor prompt-audit`（2.1.283 或更新）找出你的规则里过时、失效或互相矛盾的文字（要删的）。两者都不会自行修改，整理设置时两个都运行。

## 模型

### Opus 5.5 上能用吗？

能。Opus 5.5 现在是 Claude Code 的默认模型，所以从 2.2.0 起本插件以两份指南为共同基准。做到底、范围限制、进度汇报这几条，两份指南说法一致；只在无人值守会话追加的"不要只汇报进度就停下"段落（模块 M）来自 Opus 5.5 指南。排版规则、局部编辑、批量工具调用来自 Fable 5.1 指南，在 Opus 5.5 上效果可能较小，但无害。

Sonnet 5.5、Haiku 5.5、Opus 5、Sonnet 5 同样如此。Sonnet 5.5 和 Haiku 5.5 在 Claude Code 中同样从 `medium` effort 开始，并忽略用户设置里的全局 `effortLevel`，状态行会显示这一点。在 Haiku 5.5 上，`/fable` 用该指南自己的搜索文字代替模块 H。

Fable 5.2 同样从 `medium` 开始并忽略同一个全局值；来自其指南的模块 O 会加入无人值守会话和子代理，模块 P、Q 由 `/fable` 按请求附加。

## 其他运行环境

### 无法安装插件的纯无头环境（独立 CLAUDE_CONFIG_DIR、CI）怎么办？

把 `hooks/rules-file-unattended.md` 复制到该环境的 `rules/oh-my-fable.md`（或软链接到本仓库的检出目录；链接请放在该环境用户级的 `rules/` 文件夹里，因为项目 `.claude/rules/` 中指向项目外的链接需要批准后才会加载，见 memory 文档）。无需插件即可加载完整的无人值守规则；钩子把该文件视为用户管理文件并保持静默。

### 云端会话和定时任务（routine）呢？

在本机启用的插件不会在云端会话（claude.ai/code）和定时任务中运行；只有提交到仓库的内容会随克隆一起带过去，其中包括 `.claude/rules/`（cloud environments 文档）。请把 `hooks/rules-file-unattended.md` 作为 `.claude/rules/oh-my-fable.md` 提交：定时任务运行时不会请求批准，所以适合无人值守版本。那里用不了 `/fable` 和请求卡片。

### 设置了 `omitClaudeMd: true` 的子代理能收到规则吗？

通过规则文件或 CLAUDE.md 收不到。在 Claude Code 2.1.284 上实测：设置了 `omitClaudeMd: true` 的自定义子代理既看不到 `~/.claude/rules/*.md`，也看不到项目的 `.claude/rules/*.md` 和 CLAUDE.md；同一个代理去掉这一项后三者都能看到。

钩子无法区分这类代理（SubagentStart 的输入只有代理类型），所以在仅钩子方式下它和其他子代理一样收到精简版，在其他方式下它从本插件什么也收不到。这符合该选项"精简上下文"的用意；必须送达的规则请写进该代理自己的提示词。

### 我直接使用 API 或 Agent SDK。

`/fable-setup` 需要提问工具，在 SDK 下只能用 `/fable-setup auto`。最简单的做法是把 `hooks/always-on.md` 原样放进你的 system prompt。第 3 层的 API 项目（thinking.display 等）是你那边的设置。

---

其他文档: [工作原理](how-it-works.zh.md) · [设置与环境](setup.zh.md) · [症状对处方](symptoms.zh.md) · [结构与贡献](layout.zh.md)
