<div align="center" markdown="1">

# oh-my-fable

**Keep the working rules from Anthropic's prompting guides (Opus 5.5, Fable 5.1) always on in Claude Code. Install and forget: terminal, headless, or subagent, every session gets the rules that fit it.**

Based on Opus 5.5 (Claude Code's current default model) and Fable 5.1, and it works the same on Sonnet 5.5 (which also defaults to `medium` effort in Claude Code), Opus 5 and Sonnet 5.

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
/fable the login button does nothing, fix it
```
🤖 **What Claude actually receives** (filled in from the conversation)
```
Goal: clicking the login button calls /api/login and, on success, navigates to /dashboard
Context: src/components/LoginButton.tsx, console error "TypeError: onSubmit is not a function", started after yesterday's auth change commit
Scope: this button and its handler only. Do not touch the signup form or other errors; report them as follow-ups
Done: reproduce the click and confirm navigation to /dashboard, 0 console errors, list of changed files attached
```

**Install it, and the rest is automatic.**

- **Detects how you work, per session** · interactive in the terminal or IDE; unattended under `claude -p`, the Agent SDK, or an agent harness, where it adds the "the user is not watching" paragraph and the "don't stop on a progress report" paragraph. Mixing both needs no switching.
- **Covers subagents** · subagents started with the Agent tool (including Explore and Plan, which never read rules files) get a short version of the rules.
- **Creates no files** · CLAUDE.md and rules files stay untouched; the hook injects the rules per session. Updating is just updating the plugin, uninstalling leaves nothing behind.
- **No questions** · setup is optional. The only thing you confirm is the plugin install. Recommended once: `/fable-setup rules-file`, which keeps the base rules in a rules file (Claude Code's hooks doc prefers files over hook text for rules that never change).

One hook and four skills apply the fixes from Anthropic's official [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1), [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5), and [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5), the guide the Opus 5.5 guide names as its own starting point. The wording stays almost word-for-word from the source.

> **Which model is this for?** Both: **Opus 5.5** (Claude Code's current default model) and **Fable 5.1**. The finish-the-task, scope-limit, and progress-update rules come from official guides that say the same thing for both models, and the "don't stop on a progress report" paragraph, which only applies in unattended sessions, comes from the Opus 5.5 guide. Targeted edits, batched tool calls, and the formatting rule are fixes found only in the Fable 5.1 guide, but they do no harm on other models. The four-field request shape (goal, context, scope, done) cuts back-and-forth and off-target results no matter the model. Works the same on Sonnet 5.5 (default effort `medium` in Claude Code, like Opus 5.5), Opus 5 and Sonnet 5; when a session starts at `xhigh` or `max` effort, the hook also adds block N from the Sonnet 5.5 guide.

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
| **Always-on rules** | automatically once installed, no files | At every session start the hook injects the official guides' always-on rules (autonomy, scope limits, deliver what was asked, targeted edits, progress updates, formatting, batched tool calls) verbatim in English. Headless and SDK sessions automatically get the "the user is not watching" paragraph and the "don't stop on a progress report" paragraph (from the Opus 5.5 guide), sessions at `xhigh`/`max` effort get the "stop once the checks pass" paragraph (block N, from the Sonnet 5.5 guide), and subagents started with the Agent tool get a short version. No rules file, no CLAUDE.md edit |
| `/fable` | when a request is short or vague | shows a request with goal, context, scope, and done criteria filled in, then runs it. Add `just the prompt` to only see the rewrite |
| **Request card** | automatic in the terminal (Claude Code 2.1.287 or newer) | draws the improved request that `/fable` shows as a card in the transcript (a colored title bar, one block per field). It only draws: what Claude reads stays the same. Turn it off with `Improved request card` in `/config` ([FAQ](#faq)) |
| `/fable-status` | when you wonder what is in effect | one table: plugin version, where the rules live, detected mode, effort (value and source), whether the rules file is current, CLAUDE.md conflicts. Writes nothing |
| `/fable-audit` | when you want to know what your rules are missing | checks your CLAUDE.md, rules files, and agent prompts against the guide's 16 sections: what is missing, what pushes against a section, what the plugin already covers, and lists the Opus 5/5.5 and Sonnet 5.5 guides' model-specific notes separately, unscored. Read-only; it changes nothing. For the opposite job, finding dated, stale or contradictory text to remove, use Claude Code's `/doctor prompt-audit` |
| `/fable-setup` | optional, recommended once | keep the rules in a rules file (recommended; also the one for agent teams) or a CLAUDE.md section, pin one mode, show where effort comes from, audit your CLAUDE.md for conflicting rules |

Fable 5.1 got much better at finishing long tasks on its own, and its habits shifted with it. It narrates less while working, may call one tool per turn, tends to rewrite whole files for small edits, and at low effort answers from memory instead of searching. Opus 5.5 has a habit of ending its turn right after a progress update in the middle of a long unattended run, leaving the task stalled there (official guide, "Unattended agentic runs"). The official guides are a symptom-to-fix list for these shifts; this plugin applies the fixes for you.

## Install: one sentence

Say this to Claude Code:

```
install https://github.com/Junhan2/oh-my-fable
```

Claude installs it and that is all. No questions, no config file. The rules apply automatically the next time you open Claude Code. To use them in this session right now, type `/reload-plugins` (loads the plugin you just installed) and then `/clear` (injects the rules), one per line.

<details>
<summary>Manual install</summary>

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```
Open a new session, or `/reload-plugins` then `/clear`. Nothing to configure. `/fable-setup` only when you want to change the defaults.

> **Requirements** Claude Code 2.1.258 or newer (2.5.0 was installed on 2.1.258, 2.1.286 and 2.1.292, and the rules loaded on each). Older versions are not supported: an old Claude Code (checked on 2.1.69) can neither install nor load this plugin, so run `claude update`. **Windows needs Git for Windows (Git Bash)**: the hook runs through bash. A hook error right after install means this. The request card draws on 2.1.287 or newer (2.1.290 or newer recommended); a lower version where mods are off (checked on 2.1.258) keeps showing the plain code block.
>
> **Auto-update** Claude Code keeps auto-update off for third-party marketplaces. To receive new versions automatically, once: `/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update. Or run `claude plugin update oh-my-fable@oh-my-fable` now and then.

</details>

**60-second path: what about my environment?**

| Environment | What to do |
|---|---|
| Terminal · desktop app · IDE extension | install only. Detected as interactive |
| `claude -p` · Agent SDK · agent harnesses (Buzz etc.) | install only. Detected as unattended, adding both unattended paragraphs ("not watching", "don't stop on a progress report"). Exception: `claude -p --bare` skips hooks, plugins and CLAUDE.md, so paste `hooks/always-on.md` into your system prompt |
| Headless-only environments where the plugin cannot be installed (separate `CLAUDE_CONFIG_DIR`, CI) | copy `hooks/rules-file-unattended.md` to that environment's `rules/oh-my-fable.md` ([FAQ](#faq)) |
| Cowork · claude.ai/code | the terminal install is not used there. Enable the plugin in your claude.ai account settings |

## Usage: as usual

Just ask as you normally do; the always-on rules are already active. When a request is short or vague, prefix it:

```
/fable fix this
```

It shows a request with goal, context, scope, and done criteria filled in, then runs it. Add `just the prompt` to preview only.

## Beginner flow

| Step | Who | What |
|---|---|---|
| 1 | **You** | `install https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | registers the marketplace, installs the plugin, says "applies from the next session; for now type `/reload-plugins` then `/clear`" |
| 3 | You | work as usual. `/fable fix this` for vague requests, `/fable-status` when curious |

<details>
<summary>Optional: move the rules somewhere else (`/fable-setup`)</summary>

**Three places for the rules** (question 1)

| | Rules file + hook (recommended) | Hook only (zero-setup default) | CLAUDE.md section |
|---|---|---|---|
| Where | base rules in `~/.claude/rules/oh-my-fable.md` (auto-loaded), the unattended paragraphs and block N added by the hook per session | inside the plugin (`hooks/always-on.md`) | `<!-- oh-my-fable:start v2 -->` section in your CLAUDE.md |
| File edits | one rules file, CLAUDE.md untouched | none | edits CLAUDE.md, needs approval (not in auto mode) |
| Interactive/unattended auto-detect | yes | yes | no (static) |
| Reaches subagents | yes (regular subagents via the file, Explore and Plan via the hook's short version) | yes (the SubagentStart hook sends the short version to every subagent) | yes (Explore and Plan via the hook) |
| Reaches agent teams | yes (per the docs, teammates load rules files) | unverified | yes |
| After a plugin update | a stale rules file is flagged at session start; `/fable-setup refresh` updates it | always current | paste the section again |
| Removal | delete the file + uninstall | uninstall or `{"enabled": false}` | delete the section |

**Why the rules file is recommended.** Claude Code's [hooks doc](https://code.claude.com/docs/en/hooks) says "for instructions that never change, prefer CLAUDE.md" (rules files load the same way), and warns that hook text framed as out-of-band system commands can trigger Claude's prompt-injection defenses. The hook-only default stays because a plugin cannot write files on install; the hook's text opens with a factual lead-in ("The user installed oh-my-fable; these are the user's standing working rules.") for that reason. The trade-off of a rules file is that it is a copy: a stale one is flagged at session start and `/fable-setup refresh` updates it.

Only one is active at a time. If a CLAUDE.md section or a hand-made rules file exists, the hook goes silent by itself (no double injection). Since 1.7 the hook takes care of subagents itself: on Claude Code's `SubagentStart` event it injects a short version (`hooks/subagent.md`: scope limits, targeted edits, batched calls, finish the task, "report blockers instead of asking"). Explore and Plan subagents read neither CLAUDE.md nor rules files, so they get this short version under every delivery.

- **The mode is auto-detected by default.** A session opened in the terminal or IDE runs interactive; one started headless (`claude -p`), through the Agent SDK, or by an agent harness runs unattended, decided per session from the `CLAUDE_CODE_ENTRYPOINT` value Claude Code sets. Mixing interactive and headless use needs no switching. To pin one mode, pick "Interactive" or "Unattended" in question 2. Unattended adds the "the user is not watching" paragraph and the "don't stop on a progress report" paragraph, and can only be set in the global config, never by a config file inside a repository, so a cloned repo cannot switch your agent to unattended. Auto-detection works with both hook-based deliveries; only the CLAUDE.md section is static text, so pick one mode for that.
- **Effort**: this plugin no longer sets it. Opus 5.5 and Sonnet 5.5 default to `medium` in Claude Code (their guides' starting point for agentic work), Fable 5.1 defaults to `high`. To save a value per model, type `/effort <level>` in a session on that model and press Enter; `s` saves for this session only. `/fable-status` shows the current value and where it comes from.

</details>

<details>
<summary>Procedure for the AI (Claude reads this README and executes it)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. Read `installPath` for `oh-my-fable@oh-my-fable` from `~/.claude/plugins/installed_plugins.json`
4. Once the install is verified, tell the user only this: "Installed. The rules apply from the next session. To use them right now, type `/reload-plugins` and press Enter, then `/clear` and press Enter (one per line). Send vague requests as `/fable <request>`."
5. Say nothing else and do not run `/fable-setup` (it is optional; the defaults work without any configuration). Both commands are needed because `/reload-plugins` loads the just-installed plugin (hook and skills) into this session, and the rules are injected only on session start, `/clear`, and compaction. If the install output shows a `userConfig option not yet set` line, leave it alone (the request card is on by default; the FAQ says how to turn it off)

</details>

## How it works: three layers

The guide's fixes fall into three layers, each applied differently.

| Layer | What | How it is applied |
|---|---|---|
| **1. Every request** | goal, context, scope, done criteria, the "assess only" exception, search nudge for time-sensitive questions, long-output note | filled in by `/fable` |
| **2. Always-on** | autonomy, scope and test limits, deliver what was asked, targeted edits, progress updates, formatting rule, batched tool calls, blocking mid-task stops in unattended sessions | injected by the plugin hook at session start |
| **3. Settings** | interactive/unattended mode, effort (saved per model), thinking.display, conversation-history rules, subagents, vision crop | mode is auto-detected; only when you want to change it, `/fable-setup` writes the mode, points you to `/effort` for effort, and reports the rest as a checklist |

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
- **Effort** · Opus 5.5 and Sonnet 5.5 default to `medium`, their guides' own starting point; Fable 5.1 defaults to `high`. Raise it only for hard tasks, in that session (`/effort high` then `s`). `low` may skip searches. `xhigh`/`max` means longer thinking (Opus 5.5 thinks longer than Opus 5 at the same level), and long documents get drafted twice and slow down, so attach the long-output note (block G) and leave room in `max_tokens`.
- **Dense prose** · `Please remove all mannered prose.`
- **Summarising sources** · include one correct example (block J).

## Layer 2 · always-on

The plugin's SessionStart hook loads the blocks below verbatim in English at every session start (file `hooks/always-on.md`). CLAUDE.md is not modified, and the text is English regardless of your language. The first paragraph of block A ("the user is not watching") and block M ("don't stop on a progress report") are added automatically in headless and SDK sessions only and omitted in the terminal or IDE; `/fable-setup unattended` makes it permanent. Block N is added only when the session starts at `xhigh` or `max` effort (under `claude -p` the hook is not told the model, so there only `CLAUDE_CODE_EFFORT_LEVEL` counts). Each injected part opens with a one-line factual lead-in (for example "This session was started headless (entrypoint sdk-cli); the user's standing rules for such sessions follow."), because Claude Code's hooks doc asks for hook text written as facts, not as system commands.

| Block | One-line gist | Note |
|---|---|---|
| **A** autonomy | "The user is not watching. Proceed without asking on reversible actions, stop only for destructive ones. If your last paragraph is a plan, do it now" | the first sentence carries most of the effect. Full block for unattended use, self-check paragraph only for interactive use |
| **M** don't stop mid-task | four ways of ending a turn with work still owed, avoid them: closing with a preview of the next step, offering to continue "if you'd like," listing decisions when none of them actually blocks the work, or stopping to report because a step finished. Keep status notes and recommendations in the same message as your next tool call | refined from the Opus 5.5 guide's "Unattended agentic runs" paragraph. Unattended sessions only (the guide says to leave it out of conversations a person is watching). Confirmation for risky actions still applies |
| **D** scope and tests | do not fix unrequested bugs or extend behaviour; report them as follow-ups. Commit tests only where asked or where the repo already keeps them | still implement everything that was asked, completely |
| **L** deliver what was asked | deliver the requested scope, make routine judgment calls yourself, if the request looks wrong say so in one sentence and continue anyway, finish everything but a blocked part and say what you left out | from the Opus 5 guide's original text; one sentence of it is also in Fable 5.1's "Delivering work" section. Both interactive and unattended |
| **C** targeted edits | when the result is the same, edit surgically instead of rewriting the file | |
| **E** progress updates | one opening line, brief updates, a closing recap that stands on its own | first delete any old "hold everything for the final response" rule |
| **I** formatting rule | lists when the content is multifaceted, minimal formatting when asked, prose in conversation | delete old "no formatting" rules; 5.1 already under-formats |
| **B** batched tool calls | list what you need, then request every independent item in one response | |
| **N** stop once the checks pass | when the requested work is done and its checks pass, stop and report; no self-started review or hardening rounds, no reviewer subagents unless a review was asked for; suggest a deeper review at the end instead | from the Sonnet 5.5 guide. Only for sessions at `xhigh`/`max` effort; in the guide's test (Sonnet 5.5, `max`) it stopped reviewer subagents and cut session cost by about a third with no quality change |

## Layer 3 · settings

- Mode · `~/.claude/oh-my-fable.json` with `{"enabled": true, "mode": "interactive" | "unattended"}`. A project `.claude/oh-my-fable.json` wins over the global file. `/fable-setup` writes it for you.
- Effort · `/effort <level>` then Enter saves it per model to `modelSettings.<model>.effortLevel` in settings.json. The old global `effortLevel` does not apply to Opus 5.5 and Sonnet 5.5. An env var `CLAUDE_CODE_EFFORT_LEVEL` wins over both, so unset it to use per-model values. A `maxEffortLevel` (top-level or per model) caps whatever wins; `/fable-status` shows the capped value. Defaults: Opus 5.5 and Sonnet 5.5 `medium`, other models `high` (Opus 4.7 `xhigh`). Effort names do not map to the same thinking across models, so do not carry a value from one model over to another.
- Direct API integrations · set `thinking.display: "updates"` or progress notes never reach the UI. Keep history append-only (thinking blocks included), send per-turn reminders as turn-scoped system messages, use server-side compaction or block K.
- Subagents · the start tool returns immediately; results come back as later messages. Claude Code subagents inherit the session's effort, so pin one with `effort:` in the agent file's frontmatter.
- Vision · a crop-and-zoom tool gives most of the gain on charts and tables.
- Refusals · handle `stop_reason: "refusal"`. Ask "Are there any bugs?" rather than "Does it compile?".

## Symptom to fix

| Symptom | Fix |
|---|---|
| Stops with "Shall I?" | blocks A and M (automatic in unattended sessions; `/fable-setup unattended` to always include them) |
| An unattended run ends its turn right after a progress update | block M (automatic in unattended sessions) |
| At `xhigh`/`max`, keeps reviewing and hardening after the work is done, or launches reviewer subagents | block N (automatic when the session starts at `xhigh`/`max`), or run routine work at `high` or below |
| Changes things you did not ask for | block D |
| Does narrower or broader work than asked | block L |
| Silent for minutes | delete old rule, then block E; thinking.display over the API |
| Rewrites the whole file for one line | block C |
| Does not search for fresh information | raise effort or block H |
| Dense prose | `Please remove all mannered prose.` |
| No lists where lists belong | replace anti-formatting rules with block I |
| Source text copied into summaries unmarked | block J example |
| Benign code request refused | ask "Are there any bugs?"; link docs for obscure languages |

Full block texts: [`skills/fable/references/prompt-blocks.md`](skills/fable/references/prompt-blocks.md)

## FAQ

**My CLAUDE.md already has similar rules.**
`/fable-setup` lists them. Same meaning: "already covered". Opposite meaning (no formatting, hold findings until the end): it proposes replacement text. You make the edit yourself, because Claude Code blocks an AI from editing its own CLAUDE.md.

**I want the rules somewhere other than CLAUDE.md.**
By default the rules live only inside the plugin and the hook injects them per session, so neither CLAUDE.md nor a rules file is created. The recommended setup is a rules file (`/fable-setup rules-file`): Claude Code's hooks doc prefers files over hook text for rules that never change, and agent teams load it. A CLAUDE.md section is the third option. The comparison table is under "Optional" in [Beginner flow](#beginner-flow).

**Does it work on Opus 5.5?**
Yes. Opus 5.5 is now Claude Code's default model, so from 2.2.0 the plugin is built on both guides together. Finish-the-task, scope limits, and progress updates come from both guides saying the same thing, and the unattended "don't stop on a progress report" paragraph (block M) comes from the Opus 5.5 guide. The formatting rule, targeted edits, and batched tool calls come from the Fable 5.1 guide, so they may matter less on Opus 5.5, but they do no harm. Same for Sonnet 5.5, Opus 5 and Sonnet 5. Sonnet 5.5 also starts at `medium` effort in Claude Code and ignores a top-level `effortLevel` in user settings, which the status line shows.

**Why `/reload-plugins` and then `/clear` to use it right away?**
The two commands do different things per the official docs. `/reload-plugins` "reloads plugins, skills, agents, hooks, plugin MCP servers, and plugin LSP servers" without a restart ([Plugins](https://code.claude.com/docs/en/plugins)). The SessionStart hook that injects the rules fires only on `startup`, `resume`, `/clear`, `compact`, and `fork` ([Hooks](https://code.claude.com/docs/en/hooks#sessionstart)). So reload registers the hook but does not run it; in the install session, `/clear` runs it once. A new session needs neither.

**What is in effect right now?**
`/fable-status`. One table with the plugin version, where the rules live, this session's mode (with the auto-detection basis), effort, the rules file version, and CLAUDE.md conflicts; it changes nothing. The same information appears as a one-line notice when a new session opens (it does not enter Claude's context).

**What is the request card, and how do I turn it off?**
It draws the improved request that `/fable` shows as a card in the transcript. It is a Claude Code [mod](https://code.claude.com/docs/en/plugins/mods/overview) (plugin code that runs inside Claude Code), and redrawing that one block is all it does (`claude plugin validate` lists a single call, `$.ui.resolve`). What Claude reads and what the transcript stores stay the same; while the reply streams you see the code block, and it turns into the card when that block of the reply is complete. In the terminal it draws on Claude Code 2.1.287 or newer and was checked on 2.1.292. Per the Claude Code docs the desktop app draws mods too, but that was not checked here; the VS Code extension panel, `claude -p`, and versions before 2.1.287 keep showing the code block. Claude Code 2.1.290 fixed a stall when a mod draws multi-line text in a non-Latin script, so 2.1.290 or newer is recommended. To turn it off, switch off `Improved request card` in `/config` (it applies at once, no restart needed), or go to `/plugin` → oh-my-fable → Configure options. To install with it off: `claude plugin install oh-my-fable@oh-my-fable --config card=false`.

**How do I remove it?**
`/fable-setup remove` deletes the config, the rules file, and the CLAUDE.md section. Then `claude plugin uninstall oh-my-fable@oh-my-fable`. To pause instead, write `{"enabled": false}` to `~/.claude/oh-my-fable.json`.

**Headless-only environments where the plugin cannot be installed (separate CLAUDE_CONFIG_DIR, CI)?**
Copy `hooks/rules-file-unattended.md` to that environment's `rules/oh-my-fable.md` (or symlink it to a checkout of this repo). The full unattended rules load without the plugin; the hook treats the file as user-managed and stays silent.

**How is `/fable-audit` different from `/doctor prompt-audit`?**
They answer opposite questions. `/fable-audit` finds which prompting-guide sections your rules are missing (gaps to add). Claude Code's `/doctor prompt-audit` (2.1.283 or later) finds what in your rules is dated, stale or contradictory (text to remove). Neither changes anything on its own; run both when tidying a setup.

**Do subagents with `omitClaudeMd: true` get the rules?**
Not from a rules file or CLAUDE.md. Measured on Claude Code 2.1.284: a custom subagent with `omitClaudeMd: true` saw neither `~/.claude/rules/*.md`, the project's `.claude/rules/*.md`, nor CLAUDE.md, while the same agent without the flag saw all three. The hook cannot tell such an agent apart (the SubagentStart input carries only its type), so under hook-only delivery it still gets the short version like every subagent, and under the other deliveries it gets nothing from this plugin. That fits the flag's purpose, a lean context; put a rule that must reach it into its own prompt.

**I use the API or the Agent SDK directly.**
`/fable-setup` needs the question tool, so only `/fable-setup auto` works under the SDK. The simplest route is to paste `hooks/always-on.md` into your system prompt. The layer 3 API items (thinking.display and so on) are settings on your side.

## Layout

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            plugin manifest
│   └── marketplace.json       registers this repo as a marketplace
├── hooks/
│   ├── hooks.json             registers the SessionStart and SubagentStart hooks and the request card mod
│   ├── card/                  the request card mod (register.tsx draws the card · parse.ts reads the improved request block)
│   ├── session-start.sh       the hook (session start: unattended paragraph only when a rules file exists, else everything · subagents: short version · --status)
│   ├── always-on.md           block text (English)
│   ├── rules-file.md          base rules that /fable-setup copies to ~/.claude/rules/oh-my-fable.md
│   ├── rules-file-unattended.md static rules (with both unattended paragraphs) for headless-only environments without the plugin
│   ├── subagent.md            short version injected into subagents
│   ├── effort-high.md         block N, added only when the session starts at xhigh or max effort
│   └── autonomy-unattended.md the two paragraphs added only in unattended mode
├── skills/
│   ├── fable-setup/SKILL.md   audit, mode switch, settings checklist (layers 2 and 3)
│   ├── fable-status/SKILL.md  what is in effect, one table (read-only)
│   ├── fable-audit/
│   │   ├── SKILL.md           scores your rules against the guides (read-only)
│   │   └── references/        per-section checklist and model-specific notes
│   ├── fable/
│   │   ├── SKILL.md           per-request rewrite (layer 1)
│   │   └── references/        block texts (A to N) and before/after examples
│   └── fable-prompt/SKILL.md  old name of /fable, still works through 2.5.x
├── tests/card.test.ts         request card tests (`claude plugin test .`)
├── evals/                     `claude plugin eval` suite: 5 cases, deterministic graders
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## Contributing and license

Issues and PRs are welcome. When the guide changes, update `hooks/always-on.md` (the injected text), `hooks/autonomy-unattended.md` (the unattended paragraphs), `hooks/rules-file.md` (bump the marker version), `hooks/rules-file-unattended.md`, `hooks/effort-high.md`, and `skills/fable/references/prompt-blocks.md` (the full block list) together. To measure what the plugin contributes, run `claude plugin eval . --scaffold --allow-tools Edit Write` (each case also runs without the plugin as a baseline).

MIT © Junhan2. The guide text itself is copyright Anthropic.
