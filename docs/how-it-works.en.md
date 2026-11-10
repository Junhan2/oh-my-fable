# How it works

[← oh-my-fable](../README.en.md) · [한국어](how-it-works.md) · English · [中文](how-it-works.zh.md)

Fable 5.1 got much better at finishing long tasks on its own, and its habits shifted with it. It narrates less while working, may call one tool per turn, tends to rewrite whole files for small edits, and at low effort answers from memory instead of searching.

Opus 5.5 has a habit of ending its turn right after a progress update in the middle of a long unattended run, leaving the task stalled there (official guide, "Unattended agentic runs"). Fable 5.2 follows what a prompt says more closely: it applies approval rules and old cautions as written, sometimes ends a turn at an ordinary obstacle such as a timeout, and at `xhigh`/`max` can start subagents to review its own work (official guide, "Prompting Claude Fable 5.2").

The official guides are a symptom-to-fix list for these shifts; this plugin applies the fixes for you.

## Features at a glance

- **Always-on rules** · automatically once installed, no files

  At every session start the hook injects the official guides' always-on rules (autonomy, scope limits, deliver what was asked, targeted edits, progress updates, formatting, batched tool calls) verbatim in English. Headless and SDK sessions automatically get the "the user is not watching" paragraph and the "don't stop on a progress report" paragraph (from the Opus 5.5 guide) and the lines on working through ordinary obstacles (block O, from the Fable 5.2 guide), sessions at `xhigh`/`max` effort get the "stop once the checks pass" paragraph (block N, from the Sonnet 5.5 guide), and subagents started with the Agent tool get a short version. No rules file, no CLAUDE.md edit.

- `/fable` · when a request is short or vague

  shows a request with goal, context, scope, and done criteria filled in, then runs it. Add `just the prompt` to only see the rewrite.

- **Request card** · automatic in the terminal (Claude Code 2.1.287 or newer) and the desktop app

  draws the improved request that `/fable` shows as a card in the transcript (a colored title bar, one block per field). It only draws: what Claude reads stays the same. Turn it off with `Improved request card` in `/config` ([FAQ](faq.en.md))

- `/fable-status` · when you wonder what is in effect

  one table: plugin version, where the rules live, detected mode, effort (value and source), whether the rules file is current, CLAUDE.md conflicts. Writes nothing.

- `/fable-audit` · when you want to know what your rules are missing

  checks your CLAUDE.md, rules files, and agent prompts against the guide's 16 sections: what is missing, what pushes against a section, what the plugin already covers, and lists the Fable 5.2, Opus 5/5.5, Sonnet 5.5 and Haiku 5.5 guides' model-specific notes separately, unscored. Read-only; it changes nothing. For the opposite job, finding dated, stale or contradictory text to remove, use Claude Code's `/doctor prompt-audit`.

- `/fable-setup` · optional, recommended once

  keep the rules in a rules file (recommended; also the one for agent teams) or a CLAUDE.md section, pin one mode, show where effort comes from, audit your CLAUDE.md for conflicting rules.

## Three layers

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
- **When fresh information matters** · keep effort at high or above, or add "search the name as I wrote it at least once" (block H; on Sonnet 5.5 and Haiku 5.5, `/fable` uses each guide's own search text instead).
- **Effort** · Opus 5.5, Sonnet 5.5 and Haiku 5.5 default to `medium`, their guides' own starting point; Fable 5.1 defaults to `high`. Fable 5.2 also starts at `medium` in Claude Code; its guide suggests `high` for hard coding, research and long unattended runs, and `xhigh` only where you measured a gain. Raise it only for hard tasks, in that session (`/effort high` then `s`). `low` may skip searches. `xhigh`/`max` means longer thinking (Opus 5.5 thinks longer than Opus 5 at the same level), and long documents get drafted twice and slow down, so attach the long-output note (block G) and leave room in `max_tokens`.
- **Dense prose** · `Please remove all mannered prose.`
- **Summarising sources** · include one correct example (block J).
- **A report someone will read cold** · the Fable 5.2 guide's "Communicating clearly" text (block P): write for a reader who has not seen the tool calls or the files.
- **Your own codebase, structure included** · `This codebase is yours: what it's for and how it's built are your call, and you'll keep building on it.` (block Q, Fable 5.2 guide). Only when you want repeated code merged and the structure improved as it works; it also makes more changes you did not ask for, so read the diff.

## Layer 2 · always-on

The plugin's SessionStart hook loads the blocks below verbatim in English at every session start (file `hooks/always-on.md`). CLAUDE.md is not modified, and the text is English regardless of your language. The first paragraph of block A ("the user is not watching"), block M ("don't stop on a progress report") and block O ("work through ordinary obstacles, leave deliberate blockers alone") are added automatically in headless and SDK sessions only and omitted in the terminal or IDE; `/fable-setup unattended` makes it permanent.

Block N is added only when the session runs at `xhigh` or `max` effort: at session start, after `/clear` (the hook is then not told the model, so it reads the model from your settings), and after a model switch that moves the session to such a level (a paragraph already added stays).

Under `claude -p` the hook is not told the model, so there only `CLAUDE_CODE_EFFORT_LEVEL` counts. Each injected part opens with a one-line factual lead-in (for example "This session was started headless (entrypoint sdk-cli); the user's standing rules for such sessions follow."), because Claude Code's hooks doc asks for hook text written as facts, not as system commands.

| Block | One-line gist | Note |
|---|---|---|
| **A** autonomy | "The user is not watching. Proceed without asking on reversible actions, stop only for destructive ones. If your last paragraph is a plan, do it now" | the first sentence carries most of the effect. Full block for unattended use, self-check paragraph only for interactive use |
| **M** don't stop mid-task | four ways of ending a turn with work still owed, avoid them: closing with a preview of the next step, offering to continue "if you'd like," listing decisions when none of them actually blocks the work, or stopping to report because a step finished. Keep status notes and recommendations in the same message as your next tool call | refined from the Opus 5.5 guide's "Unattended agentic runs" paragraph. Unattended sessions only (the guide says to leave it out of conversations a person is watching). Confirmation for risky actions still applies |
| **D** scope and tests | do not fix unrequested bugs or extend behaviour; report them as follow-ups. Commit tests only where asked or where the repo already keeps them | still implement everything that was asked, completely |
| **L** deliver what was asked | deliver the requested scope, make routine judgment calls yourself, if the request looks wrong say so in one sentence and continue anyway, finish everything but a blocked part and say what you left out | from the Opus 5 guide's original text; one sentence of it is also in Fable 5.1's "Delivering work" section. Both interactive and unattended |
| **C** targeted edits | when the result is the same, edit surgically instead of rewriting the file | |
| **E** progress updates | one opening line, brief updates, a closing recap that stands on its own | first delete any old "hold everything for the final response" rule |
| **+** read as written | a rewritten prompt, a table, or a question for the user goes in reply text, before the first tool call or in the last message | the plugin's own line, not a guide quote. Reason: on current models a note written between tool calls can reach the user only as a one-line summary (thinking doc, "Progress updates between tool calls") |
| **I** formatting rule | lists when the content is multifaceted, minimal formatting when asked, prose in conversation | delete old "no formatting" rules; 5.1 already under-formats |
| **B** batched tool calls | list what you need, then request every independent item in one response | |
| **N** stop once the checks pass | when the requested work is done and its checks pass, stop and report; no self-started review or hardening rounds, no reviewer subagents unless a review was asked for; suggest a deeper review at the end instead | from the Sonnet 5.5 guide. Only for sessions at `xhigh`/`max` effort; in the guide's test (Sonnet 5.5, `max`) it stopped reviewer subagents and cut session cost by about a third with no quality change. The Fable 5.2 guide reports the same habit on Fable 5.2 at these levels |
| **O** work through ordinary obstacles | diagnose errors, timeouts, locked files, empty results and failing tools, then continue another way; leave alone what someone deliberately blocked (a file marked not to be touched, withheld access, a safety guardrail), say so, and look for another safe way | from the Fable 5.2 guide "Finish the whole task". Unattended sessions and subagents only; in an interactive Fable 5.2 session Claude Code 2.1.321 carries its own text to the same effect |

## Layer 3 · settings

- Mode · `~/.claude/oh-my-fable.json` with `{"enabled": true, "mode": "interactive" | "unattended"}`. A project `.claude/oh-my-fable.json` wins over the global file. `/fable-setup` writes it for you.
- Effort · `/effort <level>` then Enter saves it per model to `modelSettings.<model>.effortLevel` in settings.json. The old global `effortLevel` does not apply to Fable 5.2, Opus 5.5, Sonnet 5.5 and Haiku 5.5. An env var `CLAUDE_CODE_EFFORT_LEVEL` wins over both, so unset it to use per-model values. A `maxEffortLevel` (top-level or per model) caps whatever wins; `/fable-status` shows the capped value. Defaults: Fable 5.2, Opus 5.5, Sonnet 5.5 and Haiku 5.5 `medium`, other models `high` (Opus 4.7 `xhigh`). Effort names do not map to the same thinking across models, so do not carry a value from one model over to another.
- Direct API integrations · set `thinking.display: "updates"` or progress notes never reach the UI. Keep history append-only (thinking blocks included), send per-turn reminders as turn-scoped system messages, use server-side compaction or block K.
- Subagents · the start tool returns immediately; results come back as later messages. Claude Code subagents inherit the session's effort unless Claude passes a level for that one call (Agent tool, 2.1.292 or newer); pin one with `effort:` in the agent file's frontmatter. The hook is not told a subagent's effort, so a subagent started at `xhigh` or `max` does not get block N.
- Vision · a crop-and-zoom tool gives most of the gain on charts and tables.
- Refusals · handle `stop_reason: "refusal"`. Ask "Are there any bugs?" rather than "Does it compile?".

## Model differences

**Which model is this for?** **Opus 5.5** (Claude Code's current default model) and the Fable models, **Fable 5.2** and **Fable 5.1**. The finish-the-task, scope-limit, and progress-update rules come from official guides that say the same thing for both models, and the "don't stop on a progress report" paragraph, which only applies in unattended sessions, comes from the Opus 5.5 guide.

Targeted edits, batched tool calls, and the formatting rule are fixes found only in the Fable 5.1 guide, but they do no harm on other models. The four-field request shape (goal, context, scope, done) cuts back-and-forth and off-target results no matter the model.

Works the same on Sonnet 5.5 and Haiku 5.5 (default effort `medium` in Claude Code, like Opus 5.5), Opus 5 and Sonnet 5; when a session starts at `xhigh` or `max` effort, the hook also adds block N from the Sonnet 5.5 guide.

The Fable 5.2 guide is a separate page that adds to the 5.1 guide: from it come the obstacle lines for unattended sessions and subagents (block O) and two blocks `/fable` attaches by request, P for final reports and Q for code ownership.

---

Other pages: [Setup and environments](setup.en.md) · [Symptom to fix](symptoms.en.md) · [FAQ](faq.en.md) · [Layout and contributing](contributing.en.md)
