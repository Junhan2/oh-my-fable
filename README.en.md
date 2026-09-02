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

## Contents

- [What it does](#what-it-does)
- [Quick start](#quick-start)
- [Beginner flow](#beginner-flow)
- [How it works: three layers](#how-it-works-three-layers)
- [Layer 1 · every request](#layer-1--every-request)
- [Layer 2 · set once](#layer-2--set-once)
- [Layer 3 · settings](#layer-3--settings)
- [Symptom to fix](#symptom-to-fix)
- [FAQ](#faq)
- [Layout](#layout)
- [Contributing and license](#contributing-and-license)

## What it does

| Skill | When | What |
|---|---|---|
| `/fable-setup` | once after install | reads your environment (CLAUDE.md, settings, agent files), flags conflicting old rules, and writes the always-on rules into CLAUDE.md. Add `auto` to skip all questions |
| `/fable-prompt` | whenever a request is short or vague | shows a request with goal, context, scope, done criteria, and effort filled in, then runs it. Add `just the prompt` to only see the rewrite |

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

Then, inside Claude Code:

```
/reload-plugins
/fable-setup auto
```

Done. From now on, prefix vague requests with `/fable-prompt`.

> **Requirements** Claude Code 2.1.258 or newer (for `/reload-plugins`). On older versions, restart after installing.

## Beginner flow

You type only the three bold steps.

| Step | Who | What |
|---|---|---|
| 1 | **You** | Tell Claude Code: `install https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | Reads this README, then registers the marketplace, installs the plugin, and verifies the install by itself |
| 3 | Claude | Says: "Type these two lines: `/reload-plugins`, then `/fable-setup auto`" |
| 4 | **You** | Type `/reload-plugins`. The plugin becomes active without a restart |
| 5 | **You** | Type `/fable-setup auto` |
| 6 | Claude | Reads your environment, shows a table of conflicting old rules, writes the always-on section into CLAUDE.md, then shows what it wrote and how to undo it. No questions |
| 7 | Claude | Ends with a three-line usage note: "For short or vague requests use `/fable-prompt <request>`. Add `just the prompt` to see the rewrite only" |
| 8 | You | Work as usual. `/fable-prompt fix this` |

- **Prefer to be asked?** Drop `auto` in step 5. Two questions: how you mostly work (interactive / unattended / API integration), and where the rules live (global `~/.claude/CLAUDE.md` for every project, or this project's `CLAUDE.md` only).
- **Scope of `auto`** is the widest one, global `~/.claude/CLAUDE.md` (created if missing). To limit it to one project, run without `auto` and pick the project.
- **Undo** by deleting everything from `<!-- oh-my-fable:start -->` to `<!-- oh-my-fable:end -->` in CLAUDE.md.

<details>
<summary>Procedure for the AI (Claude reads this README and executes it)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. Confirm `oh-my-fable@oh-my-fable` appears in `claude plugin list`
4. Tell the user exactly two lines: first `/reload-plugins`, then `/fable-setup auto`
5. Say nothing else. `/fable-setup` gives the usage note at its end

</details>

## How it works: three layers

The guide's fixes fall into three layers, each applied differently.

| Layer | What | How it is applied |
|---|---|---|
| **1. Every request** | goal, context, scope, done criteria, effort, the "assess only" exception, search nudge for time-sensitive questions, long-output note | filled in by `/fable-prompt` |
| **2. Set once** | autonomy, scope and test limits, targeted edits, progress updates, formatting rule, batched tool calls | written to CLAUDE.md by `/fable-setup` |
| **3. Settings** | effort default, thinking.display, conversation-history rules, subagents, vision crop | reported as a checklist by `/fable-setup`; changed by an admin |

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

## Layer 2 · set once

`/fable-setup` writes the following into CLAUDE.md as a `## Fable 5.1 prompting (oh-my-fable)` section. Running it again updates the same section in place.

| Block | One-line gist | Note |
|---|---|---|
| **A** autonomy | "The user is not watching. Proceed without asking on reversible actions, stop only for destructive ones. If your last paragraph is a plan, do it now" | the first sentence carries most of the effect. Full block for unattended use, self-check paragraph only for interactive use |
| **D** scope and tests | do not fix unrequested bugs or extend behaviour; report them as follow-ups. Commit tests only where asked or where the repo already keeps them | still implement everything that was asked, completely |
| **C** targeted edits | when the result is the same, edit surgically instead of rewriting the file | |
| **E** progress updates | one opening line, brief updates, a closing recap that stands on its own | first delete any old "hold everything for the final response" rule |
| **I** formatting rule | lists when the content is multifaceted, minimal formatting when asked, prose in conversation | delete old "no formatting" rules; 5.1 already under-formats |
| **B** batched tool calls | list what you need, then request every independent item in one response | |

## Layer 3 · settings

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
`/fable-setup` flags them first. Same meaning: marked "already covered", not duplicated. Opposite meaning (no formatting, hold findings until the end): a replacement is proposed.

**Does `/fable-prompt` attach long English blocks every time?**
No. When CLAUDE.md contains the `oh-my-fable` section, only the four fields and the request-specific lines are attached. The blocks are inlined only when the section is missing, and `/fable-setup` is suggested.

**Does it work with models other than Fable 5.1?**
The four-field request shape helps with any model. The blocks are tuned to Fable 5.1's habits and are not guaranteed to help elsewhere.

**How do I remove it?**
Delete the `<!-- oh-my-fable:start -->` to `<!-- oh-my-fable:end -->` section from CLAUDE.md and run `claude plugin uninstall oh-my-fable@oh-my-fable`.

## Layout

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            plugin manifest
│   └── marketplace.json       registers this repo as a marketplace
├── skills/
│   ├── fable-setup/SKILL.md   one-time setup (layers 2 and 3)
│   └── fable-prompt/
│       ├── SKILL.md           per-request rewrite (layer 1)
│       └── references/        block texts (A to K) and before/after examples
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## Contributing and license

Issues and PRs are welcome. When the guide changes, edit only `skills/fable-prompt/references/prompt-blocks.md`; both skills read from it.

MIT © Junhan2. The guide text itself is copyright Anthropic.
