<div align="center" markdown="1">

# oh-my-fable

**在 Claude Code 中用好 Claude Fable 5.1。配置一次，每次都用改进后的请求。**

在 Opus 5 和 Sonnet 5 上输出质量同样会提升。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-2e7d32.svg)](https://github.com/Junhan2/oh-my-fable)
[![GitHub stars](https://img.shields.io/github/stars/Junhan2/oh-my-fable?style=flat)](https://github.com/Junhan2/oh-my-fable/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/Junhan2/oh-my-fable)](https://github.com/Junhan2/oh-my-fable/commits/main)

[한국어](README.md) · [English](README.en.md) · 中文

</div>

---

**随手一句话，也会变成完整的请求并直接执行。**

👤 **你输入的**
```
/fable-prompt 登录按钮点了没反应，帮我修一下
```
🤖 **Claude 实际收到的请求**（从对话上下文自动补全）
```
目标：点击登录按钮时调用 /api/login，成功后跳转到 /dashboard
上下文：src/components/LoginButton.tsx，控制台错误 "TypeError: onSubmit is not a function"，昨天改认证方式的提交之后出现
范围：只改这个按钮和它的处理函数。旁边的注册表单和其他错误不要修，作为后续事项汇报
完成标准：实际复现点击并确认跳转到 /dashboard，控制台错误 0，附上改动文件列表
```

把 Anthropic 官方文档 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1) 的处方装进两个技能。提示词模块原文照用。

> **只能用于 Fable 吗？** 不是。**在 Opus 5 和 Sonnet 5 上输出质量同样会提升。** 四字段请求结构（目标、上下文、范围、完成标准）在任何模型上都能减少反复追问和跑偏的结果；范围限制、局部编辑、进度汇报、做到底等规则无论模型如何都会提高工作质量。只有少数几条是 Fable 5.1 专用（排版规则、自主执行模块、effort 建议值），放在其他模型上也无害。

## 目录

- [做什么](#做什么)
- [安装：一句话](#安装一句话)
- [用法：照常](#用法照常)
- [新手流程](#新手流程)
- [工作原理：三层](#工作原理三层)
- [第 1 层 · 每次请求](#第-1-层--每次请求)
- [第 2 层 · 常驻规则](#第-2-层--常驻规则)
- [第 3 层 · 设置项](#第-3-层--设置项)
- [症状对处方](#症状对处方)
- [常见问题](#常见问题)
- [结构](#结构)
- [贡献与许可](#贡献与许可)

## 做什么

| 组成 | 何时 | 做什么 |
|---|---|---|
| **常驻规则** | 安装后自动 | 每次会话开始时按英文原文加载 Fable 5.1 指南的常驻规则（自主执行、范围限制、局部编辑、进度汇报、排版、批量工具调用）。基础规则放在自动加载的规则文件中，钩子每次会话追加无人值守段落。用 Agent 工具启动的子代理由钩子单独注入精简版 |
| `/fable-prompt` | 请求简短或模糊时 | 展示补全了目标、上下文、范围、完成标准和 effort 的请求并直接执行。加 `只要提示词` 则只展示 |
| `/fable-status` | 想知道当前生效了什么时 | 一张表：插件版本、规则位置、检测到的模式、effort、规则文件是否最新、CLAUDE.md 冲突数。不写任何文件 |
| `/fable-setup` | 安装后一次（由 Claude 代为执行） | 三个简短问题决定规则位置（钩子 / 独立规则文件 / CLAUDE.md）、使用方式（交互式 / 无人值守）、effort 默认值（high / medium），并列出与现有规则的冲突 |

Fable 5.1 独立完成长任务的能力大幅提升，习惯也随之改变：工作中话更少，可能每轮只调用一个工具，小改动也倾向重写整个文件，low effort 下凭记忆作答而不搜索。官方指南是针对这些变化的"症状对处方"清单，本插件替你自动应用。

## 安装：一句话

对 Claude Code 说：

```
安装 https://github.com/Junhan2/oh-my-fable
```

Claude 会安装插件，问一次（三个选项），并按答案完成设置。下次打开 Claude Code 时自动生效，你不需要输入任何命令。想在当前会话立即使用，先输入 `/reload-plugins`（加载刚安装的插件），再输入 `/clear`（注入规则），每行一个。

<details>
<summary>手动安装</summary>

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```
新开会话，或 `/reload-plugins` 后 `/clear`。然后 `/fable-setup`（不提问用默认值：`/fable-setup auto`）。

> **要求** Claude Code 2.1.258 或更新。**Windows 必须安装 Git for Windows（Git Bash）**：钩子通过 bash 运行。安装后立刻出现钩子错误就是这个原因。
>
> **自动更新** Claude Code 对第三方市场默认关闭自动更新。要自动收到新版本，只需一次：`/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update。或者不定期运行 `claude plugin update oh-my-fable@oh-my-fable`。

</details>

## 用法：照常

像平时一样提出请求即可，常驻规则已经生效。请求简短或模糊时在前面加：

```
/fable-prompt 帮我修一下这个
```

它会展示补全了目标、上下文、范围、完成标准和 effort 的请求并直接执行。只想预览，在后面加 `只要提示词`。

## 新手流程

| 步骤 | 谁 | 做什么 |
|---|---|---|
| 1 | **你** | `安装 https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | 注册市场、安装插件、确认安装 |
| 3 | Claude | 问一次：规则位置 · 使用方式（推荐自动检测） · effort（推荐 medium）（每项一行选项，标注推荐）。在项目内会再问范围，有冲突会问是否修复 |
| 4 | Claude | 按答案写入配置（以及所选的规则文件或 CLAUDE.md 段落），用表格列出与现有规则的冲突 |
| 5 | Claude | 提示"下次会话自动生效，现在就用请先 `/reload-plugins` 再 `/clear`" |
| 6 | 你 | 之后照常工作。模糊的请求用 `/fable-prompt 帮我修一下这个` |

**规则的三种位置**（问题 1）

| | 规则文件 + 钩子（默认） | 仅钩子 | CLAUDE.md 段落 |
|---|---|---|---|
| 在哪里 | 基础规则在 `~/.claude/rules/oh-my-fable.md`（自动加载），无人值守段落由钩子每次会话追加 | 插件内部（`hooks/always-on.md`） | 你的 CLAUDE.md 中的 `<!-- oh-my-fable:start v1 -->` 段落 |
| 文件改动 | 一个规则文件，不碰 CLAUDE.md | 无 | 编辑 CLAUDE.md，需批准（auto 模式不可） |
| 交互式/无人值守自动检测 | 是 | 是 | 否（固定） |
| 对子代理生效 | 是（普通子代理读文件，Explore、Plan 收钩子的精简版） | 是（SubagentStart 钩子向所有子代理发送精简版） | 是（Explore、Plan 收钩子的精简版） |
| 对代理团队生效 | 是（按文档，团队成员会加载规则文件） | 未验证 | 是 |
| 插件更新后 | 规则文件过旧时会话开始会提示，`/fable-setup refresh` 更新 | 始终最新 | 重新粘贴段落 |
| 移除 | 删除文件 + 卸载 | 卸载或 `{"enabled": false}` | 删除段落 |

同一时间只有一种生效。CLAUDE.md 中已有段落或存在手工创建的规则文件时，钩子会自动静默（不会重复注入）。从 1.7 起钩子自己负责子代理：在 Claude Code 的 `SubagentStart` 事件注入精简版（`hooks/subagent.md`：范围限制、局部编辑、批量调用、做到最后、"不要提问，汇报阻碍"）。Explore、Plan 子代理既不读 CLAUDE.md 也不读规则文件，所以无论哪种方式都会收到这份精简版。

- **使用方式默认自动检测。** 在终端或 IDE 打开的会话为交互式；以无头方式（`claude -p`）、Agent SDK 或代理框架启动的会话为无人值守，按 Claude Code 设置的 `CLAUDE_CODE_ENTRYPOINT` 值逐会话判断。混用交互式和无头也无需切换。想固定为一种，在问题 2 选"交互式"或"无人值守"。无人值守会加上"用户没有在看"段落，且只能在全局配置中开启，仓库内的配置文件无法开启，以防克隆的仓库把你的代理切换为无人值守。自动检测在两种含钩子的方式下都有效；只有 CLAUDE.md 段落是静态文本，需选定一种模式。
- **effort**：推荐 `medium`（以更低成本达到 Fable 5 水平，困难任务在该会话用 `/effort high` 提高）。Anthropic 指南默认为 `high`，优先质量可选它。写入设置中的 `effortLevel`，可能出现批准提示。

<details>
<summary>AI 执行的步骤（Claude 读取本 README 后执行）</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. 从 `~/.claude/plugins/installed_plugins.json` 读取 `oh-my-fable@oh-my-fable` 的 `installPath`
4. 读取 `<installPath>/skills/fable-setup/SKILL.md` 并**在本会话中立即**按其步骤执行（`${CLAUDE_PLUGIN_ROOT}` 即 `<installPath>`）。按该文件要求把问题合并为一次提问
5. 完成后只告诉用户："安装和设置已完成。下次会话自动生效。现在就用请输入 `/reload-plugins` 并回车，再输入 `/clear` 并回车（每行一个）。模糊的请求用 `/fable-prompt <请求>` 发送。"
6. 不做其他说明。两者都需要：`/reload-plugins` 把刚安装的插件（钩子和技能）加载到本会话，而规则只在会话开始、`/clear` 和压缩时注入

</details>

## 工作原理：三层

指南的处方分为应用方式不同的三层。

| 层 | 内容 | 如何应用 |
|---|---|---|
| **1. 每次请求** | 目标、上下文、范围、完成标准、effort、"只诊断不修改"的例外、时效性问题的搜索提示、长输出提示 | 由 `/fable-prompt` 补全 |
| **2. 常驻规则** | 自主执行、范围与测试限制、局部编辑、进度汇报、排版规则、批量工具调用 | 由插件钩子在会话开始时注入 |
| **3. 设置项** | 交互式/无人值守模式、effort 默认值、thinking.display、对话历史规则、子代理、视觉裁剪 | `/fable-setup` 写入模式和 effort，其余以清单提示 |

## 第 1 层 · 每次请求

好的请求有四个字段。

| 字段 | 差 | 好 |
|---|---|---|
| 目标 | 来份报告 | 高管会议用一页摘要，结论放最上面 |
| 上下文 | 刚才那个 | `2026-08-sales.xlsx` 的 "raw" 工作表 |
| 范围 | （无） | 只做表格。不改原文件。异常值只标注不修改 |
| 完成标准 | （无） | 合计与 "summary" 工作表总额一致。用数字汇报 |

按情况追加：

- **只是描述问题时** · "只诊断，不修改"。指南的明确例外。
- **需要最新信息时** · effort 保持 high 以上，或加上"按我写的名称至少搜索一次"（模块 H）。
- **effort** · 推荐 `medium`（指南默认 `high`）。仅困难任务 `/effort high`。`low` 可能跳过搜索。用 `xhigh`/`max` 生成长文档会打两遍草稿而变慢，请附上长输出提示（模块 G）并给 `max_tokens` 留足空间。
- **文字过密** · `Please remove all mannered prose.`
- **总结资料** · 附上一个正确示例（模块 J）。

## 第 2 层 · 常驻规则

插件的 SessionStart 钩子在每次会话开始时按英文原文加载以下模块（文件 `hooks/always-on.md`）。不修改 CLAUDE.md，且无论用户语言如何都是英文。默认是交互式模式，模块 A 的第一段（"用户没有在看"）被省略，`/fable-setup unattended` 可开启。

| 模块 | 一句话要点 | 注意 |
|---|---|---|
| **A** 自主执行 | "用户没有在看。可逆操作直接做，只在破坏性操作前停下。最后一段若是计划，现在就执行" | 第一句承担大部分效果。无人值守用完整版，交互式只用自检段落 |
| **D** 范围与测试 | 未被要求的 bug 和改进不要修，作为后续事项汇报。只在被要求或仓库已有惯例时提交测试 | 被要求的内容要完整实现 |
| **C** 局部编辑 | 结果相同时只改需要的部分，不重写整个文件 | |
| **E** 进度汇报 | 开头一句，中间简短更新，结尾一段只看最后一条也能懂的总结 | 先删除旧的"最后统一汇报"类指令 |
| **I** 排版规则 | 内容多面时用列表，被要求时最少排版，对话式用散文 | 删除旧的"不要排版"规则；5.1 已经很少排版 |
| **B** 批量工具调用 | 先列出需要的内容，再一次性请求所有互不依赖的项 | |

## 第 3 层 · 设置项

- 模式 · `~/.claude/oh-my-fable.json` 内容为 `{"enabled": true, "mode": "interactive" | "unattended"}`。项目的 `.claude/oh-my-fable.json` 优先于全局文件。`/fable-setup` 会替你写入。
- effort · 设置文件中的 `effortLevel`（全局）或 `modelSettings.<model>.effortLevel`（按模型）。环境变量 `CLAUDE_CODE_EFFORT_LEVEL` 优先于两者，要用按模型值请清除它。推荐 `medium`，指南默认 `high`。不同模型同名级别的实际思考量不同，不要照搬 Fable 5 的值。
- 直接对接 API · 需开启 `thinking.display: "updates"`，否则进度备注不会到达界面。对话历史只追加（含 thinking 块），每轮提醒用 turn-scoped system message，压缩用服务端压缩或模块 K。
- 子代理 · 启动工具立即返回，结果以后续消息送回。
- 视觉 · 图表和表格配上裁剪放大工具即可获得大部分收益。
- 拒绝 · 处理 `stop_reason: "refusal"`。用"有没有 bug？"代替"能编译吗？"。

## 症状对处方

| 症状 | 处方 |
|---|---|
| 停下来问"要做吗？" | 模块 A（`/fable-setup`） |
| 改了没让改的地方 | 模块 D |
| 几分钟没有动静 | 删旧指令后加模块 E；API 场景开 thinking.display |
| 改一行却重写整个文件 | 模块 C |
| 需要最新信息却不搜索 | 提高 effort 或模块 H |
| 文字密集 | `Please remove all mannered prose.` |
| 该有列表的地方没有 | 把禁止排版规则换成模块 I |
| 总结中原文未标注引用 | 模块 J 示例 |
| 普通代码请求被拒绝 | 改问"有没有 bug？"；冷门语言附文档链接 |

模块原文：[`skills/fable-prompt/references/prompt-blocks.md`](skills/fable-prompt/references/prompt-blocks.md)

## 常见问题

**CLAUDE.md 里已经有类似规则怎么办？**
`/fable-setup` 会用表格列出。意思相同标为"已有"；意思相反（禁止排版、最后统一汇报）则给出替换文本。修改由你自己完成，因为 Claude Code 会阻止 AI 修改自己的 CLAUDE.md。

**我想把规则放在 CLAUDE.md 以外的地方。**
在 `/fable-setup` 的第一个问题中选择：钩子（无文件）、独立规则文件（`~/.claude/rules/oh-my-fable.md`，自动加载）或 CLAUDE.md 段落。比较表见[新手流程](#新手流程)。

**Fable 5.1 以外的模型能用吗？**
能。四字段请求结构和工作规则（范围限制、局部编辑、进度汇报、批量工具调用）与模型无关，都有收益。排版规则、自主执行模块和 effort 建议值是在 Fable 5.1 上测得的，在其他模型上效果可能较小，但无害。

**为什么想立即使用要先 `/reload-plugins` 再 `/clear`？**
按官方文档，两者作用不同。`/reload-plugins` 会"无需重启地重新加载插件、技能、代理、钩子、MCP 服务器"（[Plugins](https://code.claude.com/docs/en/plugins)）。注入规则的 SessionStart 钩子只在 `startup`、`resume`、`/clear`、`compact`、`fork` 时运行（[Hooks](https://code.claude.com/docs/en/hooks#sessionstart)）。所以 reload 只注册钩子而不运行它，在安装的那个会话里需要 `/clear` 让它运行一次。新开会话则两者都不需要。

**现在生效的是什么？**
`/fable-status`。一张表列出插件版本、规则位置、本会话模式（含自动检测依据）、effort、规则文件版本、CLAUDE.md 冲突，不做任何改动。新开会话时同样的信息会以一行提示显示在屏幕上（不进入 Claude 的上下文）。

**如何移除？**
`/fable-setup remove` 会删除配置文件、规则文件和 CLAUDE.md 段落。然后 `claude plugin uninstall oh-my-fable@oh-my-fable`。只想暂停，在 `~/.claude/oh-my-fable.json` 写入 `{"enabled": false}`。

**无法安装插件的纯无头环境（独立 CLAUDE_CONFIG_DIR、CI）怎么办？**
把 `hooks/rules-file-unattended.md` 复制到该环境的 `rules/oh-my-fable.md`（或软链接到本仓库的检出目录）。无需插件即可加载完整的无人值守规则；钩子把该文件视为用户管理文件并保持静默。

**我直接使用 API 或 Agent SDK。**
`/fable-setup` 需要提问工具，在 SDK 下只能用 `/fable-setup auto`。最简单的做法是把 `hooks/always-on.md` 原样放进你的 system prompt。第 3 层的 API 项目（thinking.display 等）是你那边的设置。

## 结构

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            插件清单
│   └── marketplace.json       把本仓库注册为市场
├── hooks/
│   ├── hooks.json             注册 SessionStart、SubagentStart 钩子
│   ├── session-start.sh       钩子本体（会话开始：有规则文件时只追加无人值守段落，否则全部 · 子代理：精简版 · --status）
│   ├── always-on.md           模块原文（英文）
│   ├── rules-file.md          /fable-setup 复制到 ~/.claude/rules/oh-my-fable.md 的基础规则
│   ├── rules-file-unattended.md 无插件的纯无头环境用静态规则（含无人值守段落）
│   ├── subagent.md            注入子代理的精简版
│   └── autonomy-unattended.md 仅无人值守模式追加的段落
├── skills/
│   ├── fable-setup/SKILL.md   冲突检查、模式切换、设置检查（第 2、3 层）
│   ├── fable-status/SKILL.md  当前生效内容一张表（只读）
│   └── fable-prompt/
│       ├── SKILL.md           每次请求改写（第 1 层）
│       └── references/        模块原文（A 到 K）与前后示例
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 贡献与许可

欢迎 Issue 和 PR。指南更新时请同时修改 `hooks/always-on.md`（注入原文）和 `skills/fable-prompt/references/prompt-blocks.md`（完整模块列表）。

MIT © Junhan2。指南原文版权归 Anthropic 所有。
