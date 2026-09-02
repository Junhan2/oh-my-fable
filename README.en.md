<div align="center">

# oh-my-fable

**Get the best out of Claude Fable 5.1 in Claude Code. Set up once, send an improved request every time.**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-2e7d32.svg)](https://github.com/Junhan2/oh-my-fable)
[![GitHub stars](https://img.shields.io/github/stars/Junhan2/oh-my-fable?style=flat)](https://github.com/Junhan2/oh-my-fable/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/Junhan2/oh-my-fable)](https://github.com/Junhan2/oh-my-fable/commits/main)

[한국어](README.md) · English · [中文](README.zh.md)

</div>

---

```
/fable-prompt fix this
```
```
Improved request
Goal: remove the TS2345 error in apps/web/src/lib/pricing.ts so that tsc --noEmit ends with 0 errors
Context: the pasted error text. No related decisions
Scope: this file and the type definition file only. Report other visible errors as follow-ups, do not fix them
Done: pnpm tsc --noEmit prints 0 errors. Attach the output to the report
Effort: high
```

Two skills that apply the fixes from Anthropic's official [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1). The prompt blocks are used verbatim.

> **Fable only?** No. The four-field request shape (goal, context, scope, done) and the scope, targeted-edit, and progress rules help with any model, including Opus and Sonnet. Only a few lines are Fable 5.1 specific (the formatting rule, the autonomy block, the effort recommendations), and they do no harm elsewhere.

## Contents

- [What it does](#what-it-does)
- [Quick start](#quick-start)
- [Beginner flow](#beginner-flow)
- [How it works: three layers](#how-it-works-three-layers)
- [Layer 1 · every request](#layer-1--every-request)
- [Layer 2 · always-on](#layer-2--always-on)
- [Layer 3 · settings](#layer-3--settings)
- [Symptom to fix](#symptom-to-fix)
- [FAQ](#faq)
- [Layout](#layout)
- [Contributing and license](#contributing-and-license)

## What it does

| Part | When | What |
|---|---|---|
| **Always-on hook** | automatically once installed | At every session start, loads the Fable 5.1 guide's always-on rules (autonomy, scope limits, targeted edits, progress updates, formatting, batched tool calls) verbatim in English. CLAUDE.md is never touched |
| `/fable-prompt` | whenever a request is short or vague | shows a request with goal, context, scope, done criteria, and effort filled in, then runs it. Add `just the prompt` to only see the rewrite |
| `/fable-setup` | optional, when needed | flags rules in your CLAUDE.md and settings that conflict with the guide, switches interactive/unattended mode, lets you choose hook or CLAUDE.md delivery, and reviews effort settings |

Fable 5.1 got much better at finishing long tasks on its own, and its habits shifted with it. It narrates less while working, may call one tool per turn, tends to rewrite whole files for small edits, and at low effort answers from memory instead of searching. The official guide is a symptom-to-fix list for those shifts; this plugin applies the fixes for you.

## Quick start

The easiest way is one sentence to Claude Code:

```
install https://github.com/Junhan2/oh-my-fable
```

Manual install:

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```

Then one line inside Claude Code:

```
/reload-plugins
```

When `Reloaded: … plugins` appears you are done. The always-on rules are active from this session on; prefix vague requests with `/fable-prompt`. For unattended runs (headless, CI, agents) that need the full autonomy paragraph, run `/fable-setup unattended` once.

> **Requirements** Claude Code 2.1.258 or newer (for `/reload-plugins`). On older versions, restart after installing.

## Beginner flow

You type only the two bold steps.

| Step | Who | What |
|---|---|---|
| 1 | **You** | Tell Claude Code: `install https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | Reads this README, then registers the marketplace, installs the plugin, and verifies the install by itself |
| 3 | Claude | Says: "Type `/reload-plugins` and press Enter" |
| 4 | **You** | Type `/reload-plugins`, press Enter. `Reloaded: … plugins` means the always-on rules are active |
| 5 | You | Work as usual. `/fable-prompt fix this` for vague requests |

- **Two places to keep the rules, your choice.** Default is the **hook**: the plugin loads them at session start and touches no file. If you prefer, `/fable-setup claude-md` writes them **as a section inside CLAUDE.md** (visible next to your other rules, editable by hand). The CLAUDE.md route only works in a session that is not in auto permission mode, because Claude Code blocks an AI from editing its own instruction file; you approve the edit. Once the section is in CLAUDE.md the hook goes silent, so nothing is injected twice.
- **Unattended mode** (headless, CI, agents): `/fable-setup unattended` adds the "the user is not watching" paragraph. `/fable-setup interactive` switches back.
- **Conflicts with existing rules**: `/fable-setup` lists them in a table; you decide what to change.
- **Turn off**: write `{"enabled": false}` to `~/.claude/oh-my-fable.json`, or `claude plugin uninstall oh-my-fable@oh-my-fable`.

<details>
<summary>Procedure for the AI (Claude reads this README and executes it)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. Confirm `oh-my-fable@oh-my-fable` appears in `claude plugin list`
4. Tell the user only this: "Type `/reload-plugins` and press Enter. When the `Reloaded:` message appears you are done. Send vague requests as `/fable-prompt <request>`."
5. Say nothing else. Do not edit CLAUDE.md.

</details>

## How it works: three layers

The guide's fixes fall into three layers, each applied differently.

| Layer | What | How it is applied |
|---|---|---|
| **1. Every request** | goal, context, scope, done criteria, effort, the "assess only" exception, search nudge for time-sensitive questions, long-output note | filled in by `/fable-prompt` |
| **2. Always-on** | autonomy, scope and test limits, targeted edits, progress updates, formatting rule, batched tool calls | injected by the plugin hook at session start |
| **3. Settings** | interactive/unattended mode, effort default, thinking.display, conversation-history rules, subagents, vision crop | `/fable-setup` switches the mode and reports the rest as a checklist |

## Layer 1 · every request

A good request has four fields.

| Field | Bad | Good |
|---|---|---|
| Goal | a report please | one-page summary for the exec meeting, conclusion on top |
| Context | that thing from before | `2026-08-sales.xlsx`, sheet "raw" |
| Scope | (none) | the table only. Do not edit the source. Note outliers, do not fix them |
| Done | (none) | totals match the "summary" sheet. Report the match as numbers |

Add depending on the request:

- **When you only describe a problem** · "assess only, do not fix". The guide's explicit exception.
- **When fresh information matters** · keep effort at high or above, or add "search the name as I wrote it at least once" (block H).
- **Effort** · default `high`. Routine edits `medium`. `low` may skip searches. Long documents at `xhigh`/`max` get drafted twice and slow down, so attach the long-output note (block G) and leave room in `max_tokens`.
- **Dense prose** · `Please remove all mannered prose.`
- **Summarising sources** · include one correct example (block J).

## Layer 2 · always-on

The plugin's SessionStart hook loads the blocks below verbatim in English at every session start (file `hooks/always-on.md`). CLAUDE.md is not modified, and the text is English regardless of your language. The default is interactive mode, so the first paragraph of block A ("the user is not watching") is omitted; `/fable-setup unattended` turns it on.

| Block | One-line gist | Note |
|---|---|---|
| **A** autonomy | "The user is not watching. Proceed without asking on reversible actions, stop only for destructive ones. If your last paragraph is a plan, do it now" | the first sentence carries most of the effect. Full block for unattended use, self-check paragraph only for interactive use |
| **D** scope and tests | do not fix unrequested bugs or extend behaviour; report them as follow-ups. Commit tests only where asked or where the repo already keeps them | still implement everything that was asked, completely |
| **C** targeted edits | when the result is the same, edit surgically instead of rewriting the file | |
| **E** progress updates | one opening line, brief updates, a closing recap that stands on its own | first delete any old "hold everything for the final response" rule |
| **I** formatting rule | lists when the content is multifaceted, minimal formatting when asked, prose in conversation | delete old "no formatting" rules; 5.1 already under-formats |
| **B** batched tool calls | list what you need, then request every independent item in one response | |

## Layer 3 · settings

- Mode · `~/.claude/oh-my-fable.json` with `{"enabled": true, "mode": "interactive" | "unattended"}`. A project `.claude/oh-my-fable.json` wins over the global file. `/fable-setup` writes it for you.
- `CLAUDE_CODE_EFFORT_LEVEL` · recommend `high`. Effort names do not map to the same thinking across models, so do not carry Fable 5 values over unchanged.
- Direct API integrations · set `thinking.display: "updates"` or progress notes never reach the UI. Keep history append-only (thinking blocks included), send per-turn reminders as turn-scoped system messages, use server-side compaction or block K.
- Subagents · the start tool returns immediately; results come back as later messages.
- Vision · a crop-and-zoom tool gives most of the gain on charts and tables.
- Refusals · handle `stop_reason: "refusal"`. Ask "Are there any bugs?" rather than "Does it compile?".

## Symptom to fix

| Symptom | Fix |
|---|---|
| Stops with "Shall I?" | block A (`/fable-setup`) |
| Changes things you did not ask for | block D |
| Silent for minutes | delete old rule, then block E; thinking.display over the API |
| Rewrites the whole file for one line | block C |
| Does not search for fresh information | raise effort or block H |
| Dense prose | `Please remove all mannered prose.` |
| No lists where lists belong | replace anti-formatting rules with block I |
| Source text copied into summaries unmarked | block J example |
| Benign code request refused | ask "Are there any bugs?"; link docs for obscure languages |

Full block texts: [`skills/fable-prompt/references/prompt-blocks.md`](skills/fable-prompt/references/prompt-blocks.md)

## FAQ

**My CLAUDE.md already has similar rules.**
`/fable-setup` lists them. Same meaning: "already covered". Opposite meaning (no formatting, hold findings until the end): it proposes replacement text. You make the edit yourself, because Claude Code blocks an AI from editing its own CLAUDE.md.

**Hook or CLAUDE.md: what is the difference?**
| | Hook (default) | CLAUDE.md (`/fable-setup claude-md`) |
|---|---|---|
| Install | active on install, no file edited | once, in a session where you approve edits (not auto mode) |
| Where you see it | `hooks/always-on.md` | the `<!-- oh-my-fable:start v1 -->` section in your CLAUDE.md |
| Editing | mode only, via the config file | edit the sentences freely |
| Removal | uninstall or `{"enabled": false}` | delete the section |
| Token cost | once per session, same | once per session, same |

Both can coexist without duplication: writing to CLAUDE.md records `"delivery": "claude-md"` in the config and the hook goes silent.

**Does `/fable-prompt` attach long English blocks every time?**
No. The always-on blocks come from the hook, so only the four fields and the request-specific lines are attached.

**Does it work with models other than Fable 5.1?**
Yes. The four-field request shape and the working rules (scope limits, targeted edits, progress updates, batched tool calls) help regardless of model. The formatting rule, the autonomy block, and the effort recommendations were measured on Fable 5.1, so they may matter less elsewhere, but they do no harm.

**How do I remove it?**
`claude plugin uninstall oh-my-fable@oh-my-fable`. To pause instead, write `{"enabled": false}` to `~/.claude/oh-my-fable.json`.

## Layout

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            plugin manifest
│   └── marketplace.json       registers this repo as a marketplace
├── hooks/
│   ├── hooks.json             registers the SessionStart hook
│   ├── session-start.sh       injects the always-on rules at session start (reads the mode)
│   ├── always-on.md           the injected block text (English)
│   └── autonomy-unattended.md paragraph added only in unattended mode
├── skills/
│   ├── fable-setup/SKILL.md   audit, mode switch, settings checklist (layers 2 and 3)
│   └── fable-prompt/
│       ├── SKILL.md           per-request rewrite (layer 1)
│       └── references/        block texts (A to K) and before/after examples
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## Contributing and license

Issues and PRs are welcome. When the guide changes, edit only `skills/fable-prompt/references/prompt-blocks.md`; both skills read from it.

MIT © Junhan2. The guide text itself is copyright Anthropic.
