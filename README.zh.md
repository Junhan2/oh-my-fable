<div align="center">

# oh-my-fable

**在 Claude Code 中用好 Claude Fable 5.1。配置一次，每次都用改进后的请求。**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-2e7d32.svg)](https://github.com/Junhan2/oh-my-fable)
[![GitHub stars](https://img.shields.io/github/stars/Junhan2/oh-my-fable?style=flat)](https://github.com/Junhan2/oh-my-fable/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/Junhan2/oh-my-fable)](https://github.com/Junhan2/oh-my-fable/commits/main)

[한국어](README.md) · [English](README.en.md) · 中文

</div>

---

```
/fable-prompt 帮我修一下这个
```
```
改进后的请求
目标：消除 apps/web/src/lib/pricing.ts 中的 TS2345 错误，使 tsc --noEmit 以 0 错误结束
上下文：粘贴的错误原文。无相关决策
范围：仅此文件和类型定义文件。旁边可见的其他错误不要修，作为后续事项汇报
完成标准：pnpm tsc --noEmit 输出 0 errors。把输出原文附在汇报中
effort：high
```

把 Anthropic 官方文档 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1) 的处方装进两个技能。提示词模块原文照用。

> **只能用于 Fable 吗？** 不是。四字段请求结构（目标、上下文、范围、完成标准）以及范围限制、局部编辑、进度汇报规则对 Opus、Sonnet 等任何模型都同样有帮助。只有少数几条是 Fable 5.1 专用（排版规则、自主执行模块、effort 建议值），放在其他模型上也无害。

## 目录

- [做什么](#做什么)
- [快速开始](#快速开始)
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
| **常驻规则钩子** | 安装后自动 | 每次会话开始时，按英文原文加载 Fable 5.1 指南的常驻规则（自主执行、范围限制、局部编辑、进度汇报、排版、批量工具调用）。不修改 CLAUDE.md |
| `/fable-prompt` | 每当请求简短或模糊 | 展示补全了目标、上下文、范围、完成标准和 effort 的请求并直接执行。加 `只要提示词` 则只展示 |
| `/fable-setup` | 可选，需要时 | 用表格指出 CLAUDE.md 和设置中与指南冲突的规则，切换交互式/无人值守模式，检查 effort 设置 |

Fable 5.1 独立完成长任务的能力大幅提升，习惯也随之改变：工作中话更少，可能每轮只调用一个工具，小改动也倾向重写整个文件，low effort 下凭记忆作答而不搜索。官方指南是针对这些变化的"症状对处方"清单，本插件替你自动应用。

## 快速开始

最简单的方式是对 Claude Code 说一句话：

```
安装 https://github.com/Junhan2/oh-my-fable
```

手动安装：

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```

然后在 Claude Code 中输入一行：

```
/reload-plugins
```

出现 `Reloaded: … plugins` 即完成。常驻规则从本次会话起自动生效，模糊的请求前加 `/fable-prompt` 即可。无人值守场景（无头运行、CI、代理）需要完整自主执行段落时，运行一次 `/fable-setup unattended`。

> **要求** Claude Code 2.1.258 或更新（`/reload-plugins` 命令）。更早版本安装后重启即可。

## 新手流程

需要自己输入的只有加粗的两步。

| 步骤 | 谁 | 做什么 |
|---|---|---|
| 1 | **你** | 对 Claude Code 说：`安装 https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | 读取本 README，自行完成注册市场、安装插件、确认安装 |
| 3 | Claude | 提示："请输入 `/reload-plugins` 并回车" |
| 4 | **你** | 输入 `/reload-plugins` 并回车。出现 `Reloaded: … plugins` 即表示常驻规则已生效 |
| 5 | 你 | 之后照常工作。模糊的请求用 `/fable-prompt 帮我修一下这个` |

- **不修改 CLAUDE.md。** 规则由插件钩子在会话开始时加载。Claude Code 会阻止 AI 修改自己的指令文件，所以从一开始就不采用改文件的方式。
- **无人值守模式**（无头、CI、代理）：`/fable-setup unattended` 会加上"用户没有在看"的段落。`/fable-setup interactive` 切回。
- **与现有规则的冲突**：`/fable-setup` 用表格列出，由你决定是否修改。
- **关闭**：在 `~/.claude/oh-my-fable.json` 写入 `{"enabled": false}`，或 `claude plugin uninstall oh-my-fable@oh-my-fable`。

<details>
<summary>AI 执行的步骤（Claude 读取本 README 后执行）</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. 用 `claude plugin list` 确认出现 `oh-my-fable@oh-my-fable`
4. 只这样告诉用户："输入 `/reload-plugins` 并回车。出现 `Reloaded:` 消息即完成。模糊的请求用 `/fable-prompt <请求>` 发送。"
5. 不做其他说明。不修改 CLAUDE.md。

</details>

## 工作原理：三层

指南的处方分为应用方式不同的三层。

| 层 | 内容 | 如何应用 |
|---|---|---|
| **1. 每次请求** | 目标、上下文、范围、完成标准、effort、"只诊断不修改"的例外、时效性问题的搜索提示、长输出提示 | 由 `/fable-prompt` 补全 |
| **2. 常驻规则** | 自主执行、范围与测试限制、局部编辑、进度汇报、排版规则、批量工具调用 | 由插件钩子在会话开始时注入 |
| **3. 设置项** | 交互式/无人值守模式、effort 默认值、thinking.display、对话历史规则、子代理、视觉裁剪 | `/fable-setup` 切换模式，其余以清单提示 |

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
- **effort** · 默认 `high`。日常编辑 `medium`。`low` 可能跳过搜索。用 `xhigh`/`max` 生成长文档会打两遍草稿而变慢，请附上长输出提示（模块 G）并给 `max_tokens` 留足空间。
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
- `CLAUDE_CODE_EFFORT_LEVEL` · 建议 `high`。不同模型同名级别的实际思考量不同，不要照搬 Fable 5 的值。
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

**为什么用钩子而不写入 CLAUDE.md？**
两个原因。Claude Code 的权限分类器会阻止 AI 修改自己的指令文件，所以要做到一句话安装就不能碰文件。而且 SessionStart 钩子每次会话只加载一次，token 成本与 CLAUDE.md 相同。

**`/fable-prompt` 每次都附上长段英文吗？**
不会。常驻模块由钩子提供，只附四个字段和按请求追加的内容。

**Fable 5.1 以外的模型能用吗？**
能。四字段请求结构和工作规则（范围限制、局部编辑、进度汇报、批量工具调用）与模型无关，都有收益。排版规则、自主执行模块和 effort 建议值是在 Fable 5.1 上测得的，在其他模型上效果可能较小，但无害。

**如何移除？**
`claude plugin uninstall oh-my-fable@oh-my-fable`。只想暂停，在 `~/.claude/oh-my-fable.json` 写入 `{"enabled": false}`。

## 结构

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            插件清单
│   └── marketplace.json       把本仓库注册为市场
├── hooks/
│   ├── hooks.json             注册 SessionStart 钩子
│   ├── session-start.sh       会话开始时注入常驻规则（读取模式）
│   ├── always-on.md           注入的模块原文（英文）
│   └── autonomy-unattended.md 仅无人值守模式追加的段落
├── skills/
│   ├── fable-setup/SKILL.md   冲突检查、模式切换、设置检查（第 2、3 层）
│   └── fable-prompt/
│       ├── SKILL.md           每次请求改写（第 1 层）
│       └── references/        模块原文（A 到 K）与前后示例
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 贡献与许可

欢迎 Issue 和 PR。指南更新时只需修改 `skills/fable-prompt/references/prompt-blocks.md`，两个技能共用。

MIT © Junhan2。指南原文版权归 Anthropic 所有。
