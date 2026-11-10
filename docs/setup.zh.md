# 设置与环境

[← oh-my-fable](../README.zh.md) · [한국어](setup.md) · [English](setup.en.md) · 中文

默认设置即可工作。环境特殊或想改默认值时再看这一页。

## 按环境

| 环境 | 要做的事 |
|---|---|
| 终端 · 桌面应用 · IDE 扩展 | 只需安装。识别为交互式 |
| `claude -p` · Agent SDK · 代理框架（Buzz 等） | 只需安装。识别为无人值守并追加三个无人值守段落（"用户不在旁边"、"不要只汇报进度就停下"、"遇到普通障碍要设法解决"）。例外：`claude -p --bare` 会跳过钩子、插件和 CLAUDE.md，按无头模式文档它将在今后的版本中成为 `-p` 的默认值；这时请用 `--append-system-prompt-file hooks/rules-file-unattended.md` 直接传入规则（含基础规则和三个无人值守段落） |
| 无法安装插件的纯无头环境（独立 `CLAUDE_CONFIG_DIR`、CI） | 把 `hooks/rules-file-unattended.md` 复制到该环境的 `rules/oh-my-fable.md`（[常见问题](faq.zh.md)） |
| Cowork | 不使用终端安装的插件。请在 claude.ai 账户设置中启用 |
| 云端会话（claude.ai/code）· 定时任务（routine） | 在本机启用的插件在那里不会运行（[常见问题](faq.zh.md)）。把 `hooks/rules-file-unattended.md` 作为 `.claude/rules/oh-my-fable.md` 提交到仓库 |

## 版本与更新

- **要求** Claude Code 2.1.258 或更新（2.5.0 已在 2.1.258、2.1.286 和 2.1.292 上安装并确认规则正常注入）。不支持更低的版本：较旧的 Claude Code（已在 2.1.69 上确认）无法安装也无法加载本插件，请运行 `claude update` 升级。**Windows 必须安装 Git for Windows（Git Bash）**：钩子通过 bash 运行。安装后立刻出现钩子错误就是这个原因。请求卡片在 2.1.287 或更新版本中绘制（建议 2.1.295 或更新，其中包含已知问题的全部修复：升级后第一个会话不加载、非拉丁文字多行文本卡顿、被另一个大型插件挤掉）；在 mod 未开启的较低版本（已在 2.1.258 上确认）中仍显示普通代码块。无头会话建议 2.1.296 或更新（修复了插件的 SessionStart 钩子在无头会话中被跳过的一种情况）。
- **自动更新** Claude Code 对第三方市场默认关闭自动更新。要自动收到新版本，只需一次：`/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update。或者不定期运行 `claude plugin update oh-my-fable@oh-my-fable`。

## 更改规则存放位置

**规则的三种位置**（问题 1）

| | 规则文件 + 钩子（推荐） | 仅钩子（未设置时的默认） | CLAUDE.md 段落 |
|---|---|---|---|
| 在哪里 | 基础规则在 `~/.claude/rules/oh-my-fable.md`（自动加载），无人值守段落和模块 N 由钩子每次会话追加 | 插件内部（`hooks/always-on.md`） | 你的 CLAUDE.md 中的 `<!-- oh-my-fable:start v3 -->` 段落 |
| 文件改动 | 一个规则文件，不碰 CLAUDE.md | 无 | 编辑 CLAUDE.md，需批准（auto 模式不可） |
| 交互式/无人值守自动检测 | 是 | 是 | 否（固定） |
| 对子代理生效 | 是（普通子代理读文件，Explore、Plan 收钩子的精简版） | 是（SubagentStart 钩子向所有子代理发送精简版） | 是（Explore、Plan 收钩子的精简版） |
| 对代理团队生效 | 是（按文档，团队成员会加载规则文件） | 同一窗口内的成员（in-process）是（按钩子文档，成员每处理一条消息都会运行 SubagentStart）；分窗格的成员未验证 | 是 |
| 插件更新后 | 规则文件过旧时会话开始会提示，`/fable-setup refresh` 更新 | 始终最新 | 段落过旧时会话开始会提示，`/fable-setup claude-md` 替换 |
| 移除 | 删除文件 + 卸载 | 卸载或 `{"enabled": false}` | 删除段落 |

**为什么推荐规则文件。** Claude Code 的[钩子文档](https://code.claude.com/docs/en/hooks)写道"不会变的指令请放在 CLAUDE.md（for instructions that never change, prefer CLAUDE.md）"（规则文件以同样方式加载），并提醒写成系统命令口吻的钩子文本可能触发 Claude 的提示注入防御。默认仍是钩子，是因为插件在安装时无法写文件；也正因如此，钩子文本以一句陈述事实的引导语开头（"The user installed oh-my-fable; these are the user's standing working rules."）。规则文件的代价是它是一份副本：过旧时会话开始会提示，`/fable-setup refresh` 可更新。

同一时间只有一种生效。CLAUDE.md 中已有段落或存在手工创建的规则文件时，钩子会自动静默（不会重复注入）。从 1.7 起钩子自己负责子代理：在 Claude Code 的 `SubagentStart` 事件注入精简版（`hooks/subagent.md`：范围限制、局部编辑、批量调用、做到最后、"不要提问，汇报阻碍"）。Explore、Plan 子代理既不读 CLAUDE.md 也不读规则文件，所以无论哪种方式都会收到这份精简版。继承整个对话的 fork 类型子代理已经带着规则，因此跳过。

- **使用方式默认自动检测。** 在终端或 IDE 打开的会话为交互式；以无头方式（`claude -p`）、Agent SDK 或代理框架启动的会话为无人值守，按 Claude Code 设置的 `CLAUDE_CODE_ENTRYPOINT` 值逐会话判断。混用交互式和无头也无需切换。想固定为一种，在问题 2 选"交互式"或"无人值守"。无人值守会加上"用户没有在看"段落和"不要只汇报进度就停下"段落，且只能在全局配置中开启，仓库内的配置文件无法开启，以防克隆的仓库把你的代理切换为无人值守。自动检测在两种含钩子的方式下都有效；只有 CLAUDE.md 段落是静态文本，需选定一种模式。
- **effort**：本插件不再设置它。Opus 5.5、Sonnet 5.5 和 Haiku 5.5 在 Claude Code 中默认 `medium`（各自指南为代理式工作建议的起点），Fable 5.2 也默认 `medium`（其指南建议困难或长时间无人值守的工作用 `high`）；Fable 5.1 默认 `high`。想按模型保存，在用该模型打开的会话里输入 `/effort <级别>` 后回车；只想本次会话生效则按 `s`。`/fable-status` 会显示当前值和来源。

---

其他文档: [工作原理](how-it-works.zh.md) · [症状对处方](symptoms.zh.md) · [常见问题](faq.zh.md) · [结构与贡献](layout.zh.md)
