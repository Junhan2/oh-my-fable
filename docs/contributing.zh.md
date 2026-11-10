# 结构与贡献

[← oh-my-fable](../README.zh.md) · [한국어](contributing.md) · [English](contributing.en.md) · 中文

## 结构

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            插件清单
│   └── marketplace.json       把本仓库注册为市场
├── hooks/
│   ├── hooks.json             注册 SessionStart、SubagentStart、PostModelSwitch 钩子，并接入请求卡片 mod
│   ├── card/                  请求卡片 mod（register.tsx：绘制卡片 · parse.ts：读取改写后请求的代码块）
│   ├── session-start.sh       钩子本体（会话开始：有规则文件时只追加无人值守段落，否则全部 · 子代理：精简版 · 切换模型：模块 N · --status）
│   ├── always-on.md           模块原文（英文）
│   ├── rules-file.md          /fable-setup 复制到 ~/.claude/rules/oh-my-fable.md 的基础规则
│   ├── rules-file-unattended.md 无插件的纯无头环境用静态规则（含三个无人值守段落）
│   ├── effort-high.md         模块 N，仅在会话以 xhigh 或 max effort 开始时追加
│   ├── whats-new.txt          每个版本一行，更新后的第一个会话显示
│   ├── subagent.md            注入子代理的精简版
│   └── autonomy-unattended.md 仅无人值守模式追加的三个段落
├── skills/
│   ├── fable-setup/SKILL.md   冲突检查、模式切换、设置检查（第 2、3 层）
│   ├── fable-status/SKILL.md  当前生效内容一张表（只读）
│   ├── fable-audit/
│   │   ├── SKILL.md           对照指南检查我的规则（只读）
│   │   └── references/        按指南分节的检查清单与按模型注意事项
│   └── fable/
│       ├── SKILL.md           每次请求改写（第 1 层）
│       └── references/        模块原文（A 到 N）与前后示例
├── tests/card.test.ts         请求卡片测试（`claude plugin test .`）
├── tests/context-size.sh      检查钩子注入的文字不超过 1 万字符上限（`bash tests/context-size.sh`）
├── evals/                     `claude plugin eval` 评测集：8 个用例，按规则判分，不用模型评判
├── docs/                      详细文档（工作原理、设置与环境、症状对处方、常见问题、结构与贡献）
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 贡献

欢迎 Issue 和 PR。指南更新时请同时修改 `hooks/always-on.md`（注入原文）、`hooks/autonomy-unattended.md`（无人值守段落）、`hooks/rules-file.md`（把标记版本号加一）、`hooks/rules-file-unattended.md`、`hooks/effort-high.md`、`skills/fable/references/prompt-blocks.md`（完整模块列表）、`skills/fable/SKILL.md`（模块 F、G、H、J 的副本），然后运行 `bash tests/context-size.sh`。

想衡量插件实际带来了什么，运行 `claude plugin eval . --scaffold --allow-tools Edit Write`（每个用例也会在不加载插件的情况下运行作为对照）。

用例 `obstacle-retries-busy-tool` 需要 shell，请用 `--case obstacle-retries-busy-tool --allow-tools Edit Write Bash` 单独运行（把 shell 授权给所有用例时，`scope-fix-one-bug` 的新文件检查失败了）。

升级版本时，在 `hooks/whats-new.txt` 加一行、在 `CHANGELOG.md` 加一条；如果改了无人值守段落，还要把 `hooks/rules-file-unattended.md` 头部的 `u` 数字加一。

---

其他文档: [工作原理](how-it-works.zh.md) · [设置与环境](setup.zh.md) · [症状对处方](symptoms.zh.md) · [常见问题](faq.zh.md)
