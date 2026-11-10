# 症状对处方

[← oh-my-fable](../README.zh.md) · [한국어](symptoms.md) · [English](symptoms.en.md) · 中文

| 症状 | 处方 |
|---|---|
| 停下来问"要做吗？" | 模块 A、M（无人值守会话自动生效，想始终加上用 `/fable-setup unattended`） |
| 无人值守只汇报进度就结束这一轮 | 模块 M（无人值守会话自动生效） |
| 在 `xhigh`/`max` 下，工作完成后仍继续审查、加固，或启动审查用子代理 | 模块 N（以 `xhigh`/`max` 开始的会话自动生效），或把日常工作放在 `high` 及以下 |
| 遇到超时或工具失败就停下，不换办法再试 | 模块 O（无人值守会话和子代理自动生效） |
| 最终报告让没看过程的人难以读懂 | 模块 P（`/fable` 会在报告和交接类请求中附上） |
| 不合并现有代码，又写一份类似的 | 模块 Q，仅在允许改动结构时使用 |
| 索要不必要的审批，或搁置日常工作 | 在审批规则中写明具体操作，把例外写进"绝不"规则本身（`/fable-audit` 的 N19、N20） |
| 改了没让改的地方 | 模块 D |
| 做得比吩咐的范围窄或宽 | 模块 L |
| 几分钟没有动静 | 删旧指令后加模块 E；API 场景开 thinking.display |
| 改一行却重写整个文件 | 模块 C |
| 需要最新信息却不搜索 | 提高 effort 或模块 H |
| 文字密集 | `Please remove all mannered prose.` |
| 该有列表的地方没有 | 把禁止排版规则换成模块 I |
| 总结中原文未标注引用 | 模块 J 示例 |
| 普通代码请求被拒绝 | 改问"有没有 bug？"；冷门语言附文档链接 |

模块原文：[`skills/fable/references/prompt-blocks.md`](https://github.com/Junhan2/oh-my-fable/blob/main/skills/fable/references/prompt-blocks.md)

---

其他文档: [工作原理](how-it-works.zh.md) · [设置与环境](setup.zh.md) · [常见问题](faq.zh.md) · [结构与贡献](layout.zh.md)
