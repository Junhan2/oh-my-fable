# Layout and contributing

[← oh-my-fable](../README.en.md) · [한국어](layout.md) · English · [中文](layout.zh.md)

## Layout

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            plugin manifest
│   └── marketplace.json       registers this repo as a marketplace
├── hooks/
│   ├── hooks.json             registers the SessionStart, SubagentStart and PostModelSwitch hooks and the request card mod
│   ├── card/                  the request card mod (register.tsx draws the card · parse.ts reads the improved request block)
│   ├── session-start.sh       the hook (session start: unattended paragraph only when a rules file exists, else everything · subagents: short version · model switch: block N · --status)
│   ├── always-on.md           block text (English)
│   ├── rules-file.md          base rules that /fable-setup copies to ~/.claude/rules/oh-my-fable.md
│   ├── rules-file-unattended.md static rules (with the three unattended paragraphs) for headless-only environments without the plugin
│   ├── subagent.md            short version injected into subagents
│   ├── effort-high.md         block N, added only when the session starts at xhigh or max effort
│   ├── whats-new.txt          one line per version, shown on the first session after an update
│   └── autonomy-unattended.md the three paragraphs added only in unattended mode
├── skills/
│   ├── fable-setup/SKILL.md   audit, mode switch, settings checklist (layers 2 and 3)
│   ├── fable-status/SKILL.md  what is in effect, one table (read-only)
│   ├── fable-audit/
│   │   ├── SKILL.md           scores your rules against the guides (read-only)
│   │   └── references/        per-section checklist and model-specific notes
│   └── fable/
│       ├── SKILL.md           per-request rewrite (layer 1)
│       └── references/        block texts (A to N) and before/after examples
├── tests/card.test.ts         request card tests (`claude plugin test .`)
├── tests/context-size.sh      keeps the injected text under the hook's 10,000-character cap (`bash tests/context-size.sh`)
├── evals/                     `claude plugin eval` suite: 8 cases, deterministic graders
├── docs/                      detail pages (how it works, setup and environments, symptom to fix, FAQ, layout and contributing)
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## Contributing

Issues and PRs are welcome. When the guide changes, update `hooks/always-on.md` (the injected text), `hooks/autonomy-unattended.md` (the unattended paragraphs), `hooks/rules-file.md` (bump the marker version), `hooks/rules-file-unattended.md`, `hooks/effort-high.md`, `skills/fable/references/prompt-blocks.md` (the full block list), and `skills/fable/SKILL.md` (its copies of blocks F, G, H and J) together, then run `bash tests/context-size.sh`.

To measure what the plugin contributes, run `claude plugin eval . --scaffold --allow-tools Edit Write` (each case also runs without the plugin as a baseline). The case `obstacle-retries-busy-tool` needs a shell, so run it on its own with `--case obstacle-retries-busy-tool --allow-tools Edit Write Bash` (with the shell granted to every case, the new-files check of `scope-fix-one-bug` failed).

When you bump the version, add a line to `hooks/whats-new.txt` and an entry to `CHANGELOG.md`, and raise the `u` number in the header of `hooks/rules-file-unattended.md` if the unattended paragraphs changed.

---

Other pages: [How it works](how-it-works.en.md) · [Setup and environments](setup.en.md) · [Symptom to fix](symptoms.en.md) · [FAQ](faq.en.md)
