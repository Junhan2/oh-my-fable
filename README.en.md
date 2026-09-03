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

**Type a sloppy one-liner. Claude receives a proper request and runs it.**

👤 **What you type**
```
/fable-prompt the login button does nothing, fix it
```
🤖 **What Claude actually receives** (filled in from the conversation)
```
Goal: clicking the login button calls /api/login and, on success, navigates to /dashboard
Context: src/components/LoginButton.tsx, console error "TypeError: onSubmit is not a function", started after yesterday's auth change commit
Scope: this button and its handler only. Do not touch the signup form or other errors; report them as follow-ups
Done: reproduce the click and confirm navigation to /dashboard, 0 console errors, list of changed files attached
```

Two skills that apply the fixes from Anthropic's official [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1). The prompt blocks are used verbatim.

> **Fable only?** No. The four-field request shape (goal, context, scope, done) and the scope, targeted-edit, and progress rules help with any model, including Opus and Sonnet. Only a few lines are Fable 5.1 specific (the formatting rule, the autonomy block, the effort recommendations), and they do no harm elsewhere.

## Contents

- [What it does](#what-it-does)
- [Install: one sentence](#install-one-sentence)
- [Usage: as usual](#usage-as-usual)
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
| **Always-on rules** | automatically once installed | At every session start, loads the Fable 5.1 guide's always-on rules (autonomy, scope limits, targeted edits, progress updates, formatting, batched tool calls) verbatim in English. The default is a hook, so no file is touched |
| `/fable-prompt` | when a request is short or vague | shows a request with goal, context, scope, done criteria, and effort filled in, then runs it. Add `just the prompt` to only see the rewrite |
| `/fable-setup` | once right after install (Claude runs it for you) | three short questions set where the rules live (hook / separate rules file / CLAUDE.md), how you work (interactive / unattended), and the effort default (high / medium), then lists conflicts with your existing rules |

Fable 5.1 got much better at finishing long tasks on its own, and its habits shifted with it. It narrates less while working, may call one tool per turn, tends to rewrite whole files for small edits, and at low effort answers from memory instead of searching. The official guide is a symptom-to-fix list for those shifts; this plugin applies the fixes for you.

## Install: one sentence

Say this to Claude Code:

```
install https://github.com/Junhan2/oh-my-fable
```

Claude installs the plugin, asks one question (three choices), and applies your answers. The rules apply automatically the next time you open Claude Code. Nothing to type yourself. To use them in this session right now, type `/reload-plugins` (loads the plugin you just installed) and then `/clear` (injects the rules), one per line.

<details>
<summary>Manual install</summary>

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```
Open a new session, or `/reload-plugins` then `/clear`. Then `/fable-setup` (defaults without questions: `/fable-setup auto`).

> **Requirements** Claude Code 2.1.258 or newer. **Windows needs Git for Windows (Git Bash)**: the hook runs through bash. A hook error right after install means this.

</details>

## Usage: as usual

Just ask as you normally do; the always-on rules are already active. When a request is short or vague, prefix it:

```
/fable-prompt fix this
```

It shows a request with goal, context, scope, done criteria, and effort filled in, then runs it. Add `just the prompt` to preview only.

## Beginner flow

| Step | Who | What |
|---|---|---|
| 1 | **You** | `install https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | registers the marketplace, installs the plugin, verifies |
| 3 | Claude | one question: where the rules live · how you work (auto-detect recommended) · effort (medium recommended) (one-line options, recommendation marked). Plus scope inside a project, and whether to fix conflicts if any |
| 4 | Claude | writes the config (and, if chosen, the rules file or CLAUDE.md section), shows conflicts with existing rules as a table |
| 5 | Claude | says "applies from the next session; for now type `/reload-plugins` then `/clear`" |
| 6 | You | work as usual. `/fable-prompt fix this` for vague requests |

**Three places for the rules** (question 1)

| | Hook (default) | Separate rules file | CLAUDE.md section |
|---|---|---|---|
| Where | inside the plugin (`hooks/always-on.md`) | `~/.claude/rules/oh-my-fable.md` (auto-loaded) | `<!-- oh-my-fable:start v1 -->` section in your CLAUDE.md |
| File edits | none | one new file, CLAUDE.md untouched | edits CLAUDE.md, needs approval (not in auto mode) |
| Hand-editing | mode only (config file) | free | free |
| Reaches subagents and teams | no (main session only) | yes | yes |
| After a plugin update | always current | run `/fable-setup` again to refresh | same |
| Removal | uninstall or `{"enabled": false}` | delete the file | delete the section |

Only one is active at a time. If you pick a file option, or a CLAUDE.md section already exists, the hook goes silent by itself (no double injection after upgrading from an older version). If you use subagents or agent teams a lot, pick the rules file.

- **The mode is auto-detected by default.** A session opened in the terminal or IDE runs interactive; one started headless (`claude -p`), through the Agent SDK, or by an agent harness runs unattended, decided per session from the `CLAUDE_CODE_ENTRYPOINT` value Claude Code sets. Mixing interactive and headless use needs no switching. To pin one mode, pick "Interactive" or "Unattended" in question 2. Unattended adds the "the user is not watching" paragraph and can only be set in the global config, never by a config file inside a repository, so a cloned repo cannot switch your agent to unattended. Auto-detection works only with hook delivery; a rules file or CLAUDE.md section is static text, so pick one mode for those.
- **Effort**: `medium` recommended (Fable 5 quality at lower cost; raise hard tasks with `/effort high` in that session). Anthropic's guide default is `high`, pick it if quality comes first. Written to `effortLevel` in settings.json; an approval prompt may appear.

<details>
<summary>Procedure for the AI (Claude reads this README and executes it)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. Read `installPath` for `oh-my-fable@oh-my-fable` from `~/.claude/plugins/installed_plugins.json`
4. Read `<installPath>/skills/fable-setup/SKILL.md` and follow it **in this session right away** (`${CLAUDE_PLUGIN_ROOT}` is `<installPath>`). Bundle the questions as that file says
5. Then tell the user only this: "Installed and configured. The rules apply from the next session. To use them right now, type `/reload-plugins` and press Enter, then `/clear` and press Enter (one per line). Send vague requests as `/fable-prompt <request>`."
6. Say nothing else. Both are needed because `/reload-plugins` loads the just-installed plugin (hook and skills) into this session, and the rules are injected only on session start, `/clear`, and compaction

</details>

## How it works: three layers

The guide's fixes fall into three layers, each applied differently.

| Layer | What | How it is applied |
|---|---|---|
| **1. Every request** | goal, context, scope, done criteria, effort, the "assess only" exception, search nudge for time-sensitive questions, long-output note | filled in by `/fable-prompt` |
| **2. Always-on** | autonomy, scope and test limits, targeted edits, progress updates, formatting rule, batched tool calls | injected by the plugin hook at session start |
| **3. Settings** | interactive/unattended mode, effort default, thinking.display, conversation-history rules, subagents, vision crop | `/fable-setup` writes mode and effort and reports the rest as a checklist |

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
- **Effort** · `medium` recommended (guide default is `high`). Hard tasks only: `/effort high`. `low` may skip searches. Long documents at `xhigh`/`max` get drafted twice and slow down, so attach the long-output note (block G) and leave room in `max_tokens`.
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
- Effort · `effortLevel` (global) or `modelSettings.<model>.effortLevel` (per model) in settings.json. An env var `CLAUDE_CODE_EFFORT_LEVEL` wins over both, so unset it to use per-model values. Recommended `medium`, guide default `high`. Effort names do not map to the same thinking across models, so do not carry Fable 5 values over unchanged.
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

**I want the rules somewhere other than CLAUDE.md.**
Pick it in the first `/fable-setup` question: hook (no file), a separate rules file (`~/.claude/rules/oh-my-fable.md`, auto-loaded), or a CLAUDE.md section. The comparison table is under [Beginner flow](#beginner-flow).

**Does it work with models other than Fable 5.1?**
Yes. The four-field request shape and the working rules (scope limits, targeted edits, progress updates, batched tool calls) help regardless of model. The formatting rule, the autonomy block, and the effort recommendations were measured on Fable 5.1, so they may matter less elsewhere, but they do no harm.

**Why `/reload-plugins` and then `/clear` to use it right away?**
The two commands do different things per the official docs. `/reload-plugins` "reloads plugins, skills, agents, hooks, plugin MCP servers, and plugin LSP servers" without a restart ([Plugins](https://code.claude.com/docs/en/plugins)). The SessionStart hook that injects the rules fires only on `startup`, `resume`, `/clear`, `compact`, and `fork` ([Hooks](https://code.claude.com/docs/en/hooks#sessionstart)). So reload registers the hook but does not run it; in the install session, `/clear` runs it once. A new session needs neither.

**How do I remove it?**
`/fable-setup remove` deletes the config, the rules file, and the CLAUDE.md section. Then `claude plugin uninstall oh-my-fable@oh-my-fable`. To pause instead, write `{"enabled": false}` to `~/.claude/oh-my-fable.json`.

**I use the API or the Agent SDK directly.**
`/fable-setup` needs the question tool, so only `/fable-setup auto` works under the SDK. The simplest route is to paste `hooks/always-on.md` into your system prompt. The layer 3 API items (thinking.display and so on) are settings on your side.

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

Issues and PRs are welcome. When the guide changes, update both `hooks/always-on.md` (the injected text) and `skills/fable-prompt/references/prompt-blocks.md` (the full block list).

MIT © Junhan2. The guide text itself is copyright Anthropic.
