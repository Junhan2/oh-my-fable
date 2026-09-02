# oh-my-fable

[한국어](README.md) · [English](README.en.md) · 中文

在 Claude Code 中用好 Claude Fable 5.1 的简明指南和两个技能。
依据是 Anthropic 官方文档 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)，提示词模块原文照用。

## 新手流程（从头到尾）

面向第一次使用 Claude Code 的人。需要自己输入的只有加粗的三步。

| 步骤 | 谁 | 做什么 |
|---|---|---|
| 1 | **你** | 对 Claude Code 说：`安装 https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | 读取本 README，自行完成注册市场、安装插件、确认安装 |
| 3 | Claude | 提示："请输入这两行：`/reload-plugins`，然后 `/fable-setup auto`" |
| 4 | **你** | 输入 `/reload-plugins`。刚安装的插件无需重启即可生效 |
| 5 | **你** | 输入 `/fable-setup auto` |
| 6 | Claude | 读取环境（CLAUDE.md 位置、设置、代理文件），用表格列出冲突的旧规则，把常驻规则写入 CLAUDE.md，然后展示写入内容和撤销方法。不提问 |
| 7 | Claude | 最后给出三行用法："请求简短或模糊时用 `/fable-prompt <请求>`。只看改写不执行则在后面加 `只要提示词`" |
| 8 | 你 | 之后照常工作。模糊的请求用 `/fable-prompt 帮我修一下这个` |

- 想要边问边配置？第 5 步去掉 `auto`，运行 `/fable-setup`。会问两个问题：主要使用方式（交互式 / 无人值守 / API 对接）、规则放在哪里（全局 `~/.claude/CLAUDE.md` 对所有项目生效，或仅本项目的 `CLAUDE.md`）。
- `auto` 使用最宽范围，即全局 `~/.claude/CLAUDE.md`（不存在则创建）。只想用于某一个项目，请不带 `auto` 运行，在第二个问题中选择项目。
- 撤销：删除 CLAUDE.md 中从 `<!-- oh-my-fable:start -->` 到 `<!-- oh-my-fable:end -->` 的内容即可。
- 为什么需要第 4 步：新安装的插件要在 `/reload-plugins`（Claude Code 2.1.258）或重启后才会加载。它是内置命令，Claude 不能替你执行。

<details>
<summary>AI 执行的步骤（Claude 读取本 README 后执行）</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. 用 `claude plugin list` 确认出现 `oh-my-fable@oh-my-fable`
4. 只告诉用户这两行：先 `/reload-plugins`，再 `/fable-setup auto`
5. 不做其他说明。用法提示由 `/fable-setup` 在结尾给出

</details>

## 手动安装（30 秒）

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```

然后在 Claude Code 中运行一次：

```
/fable-setup
```

它会读取环境，问两个问题（使用方式、规则位置），把常驻规则写入 CLAUDE.md。之后当请求简短或模糊时：

```
/fable-prompt 帮我修一下这个
```

它会展示补全了目标、上下文、范围、完成标准和 effort 的请求，并直接执行。只想查看改写，在后面加 `只要提示词`。

## 为什么需要（30 秒）

Fable 5.1 独立完成长任务的能力大幅提升，习惯也随之改变：工作中话更少，可能每轮只调用一个工具，小改动也倾向重写整个文件，low effort 下会凭记忆作答而不去搜索。官方指南就是针对这些变化的"症状对处方"清单。处方分三层，每层的应用方式不同。

## 三层

| 层 | 内容 | 如何应用 |
|---|---|---|
| **1. 每次请求** | 目标、上下文、范围、完成标准、effort、"只诊断不修改"的例外、时效性问题的搜索提示、长输出提示 | 由 `/fable-prompt` 补全 |
| **2. 一次性配置** | 自主执行、范围与测试限制、局部编辑、进度汇报、排版规则、批量工具调用 | 由 `/fable-setup` 写入 CLAUDE.md |
| **3. 设置项** | effort 默认值、thinking.display、对话历史规则、子代理、视觉裁剪 | `/fable-setup` 以清单形式提示，由管理员修改 |

## 第 1 层 · 每次请求

好的请求有四个字段。

| 字段 | 差 | 好 |
|---|---|---|
| 目标 | 来份报告 | 高管会议用一页摘要，结论放最上面 |
| 上下文 | 刚才那个 | `2026-08-sales.xlsx` 的 "raw" 工作表 |
| 范围 | （无） | 只做表格。不改原文件。异常值只标注不修改 |
| 完成标准 | （无） | 合计与 "summary" 工作表总额一致。用数字汇报是否一致 |

按情况追加：
- **只是描述问题时**："只诊断，不修改"。这是指南的明确例外。
- **需要最新信息时**：effort 保持 high 以上，或加上"按我写的名称至少搜索一次"（模块 H）。
- **effort**：默认 `high`。日常编辑 `medium`。`low` 可能跳过搜索。用 `xhigh`/`max` 生成长文档会先在推理中打草稿再输出一遍而变慢，请附上长输出提示（模块 G）并给 `max_tokens` 留足空间。
- **文字过于密集**：`Please remove all mannered prose.`
- **总结资料**：附上一个正确示例（模块 J）。

## 第 2 层 · 一次性配置（CLAUDE.md）

`/fable-setup` 会把以下内容写成 `## Fable 5.1 prompting (oh-my-fable)` 段落。再次运行会原地更新同一段落。

| 模块 | 一句话要点 | 注意 |
|---|---|---|
| A 自主执行 | "用户没有在看。可逆操作不要问直接做，只在破坏性操作前停下。如果最后一段是计划，现在就执行" | 第一句承担大部分效果。无人值守用完整版，交互式只用自检段落 |
| D 范围与测试 | 未被要求的 bug 和改进不要修，作为后续事项汇报。只在被要求或仓库已有惯例时提交测试 | 被要求的内容要完整实现 |
| C 局部编辑 | 结果相同时，只改需要的部分，不要重写整个文件 | |
| E 进度汇报 | 开头一句，中间简短更新，结尾一段只看最后一条消息也能懂的总结 | 先删除旧的"最后统一汇报"类指令 |
| I 排版规则 | 内容多面时用列表，被要求时最少排版，对话式用散文 | 删除旧的"不要排版"规则；5.1 已经很少用排版 |
| B 批量工具调用 | 先列出需要的内容，再一次性请求所有互不依赖的项 | |

## 第 3 层 · 设置项（管理员）

- `CLAUDE_CODE_EFFORT_LEVEL`：建议 `high`。不同模型同名级别的实际思考量不同，不要照搬 Fable 5 的值。
- 直接对接 API：需开启 `thinking.display: "updates"`，否则进度备注不会到达界面。对话历史只追加（含 thinking 块），每轮提醒用 turn-scoped system message，压缩用服务端压缩或模块 K。
- 子代理：启动工具立即返回，结果以后续消息送回。
- 视觉：图表和表格配上裁剪放大工具即可获得大部分收益。
- 处理 `stop_reason: "refusal"`。用"有没有 bug？"代替"能编译吗？"。

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

## 结构

```
oh-my-fable/
├── .claude-plugin/        plugin.json, marketplace.json
├── skills/
│   ├── fable-setup/       一次性配置（第 2、3 层）
│   └── fable-prompt/      每次请求改写（第 1 层）+ references/ 模块原文与示例
└── README.md              本指南
```

MIT。指南原文版权归 Anthropic 所有。
