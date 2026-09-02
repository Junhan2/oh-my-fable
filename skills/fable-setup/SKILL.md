---
name: fable-setup
description: One-time environment setup for Claude Fable 5.1 in Claude Code. Audits CLAUDE.md, settings, and (if present) agent system prompts against Anthropic's "Prompting Claude Fable 5.1" guide, asks at most two questions about how the user works, then installs the always-on rules and reports the settings that only an admin can change. Use when the user says "/fable-setup", "fable 세팅", "환경 맞춰줘", "가이드 적용해줘", "set up for Fable 5.1", "apply the Fable guide", or pastes the Fable prompting guide and asks to apply it. Also teaches /fable-prompt in three lines at the end.
---
# fable-setup · install the always-on layer once

Source: Anthropic "Prompting Claude Fable 5.1". Blocks live in
`${CLAUDE_PLUGIN_ROOT}/skills/fable-prompt/references/prompt-blocks.md` (read it before Step 3).

The guide's advice splits into three layers. This skill handles layers 2 and 3.
1. **Per request** (goal, context, scope, done, effort, conditional nudges) → `/fable-prompt`.
2. **Always-on rules** (autonomy, scope limits, targeted edits, progress updates, formatting) → CLAUDE.md.
3. **Settings** (effort default, thinking display, API history rules) → settings files or an admin.

## Step 1 · Detect the environment (one batch of reads, no questions yet)
Read whichever exist: `./CLAUDE.md`, `./.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`, `~/.claude/settings.json`,
`./.claude/settings.json`, `./.claude/agents/*.md`, `~/.claude/agents/*.md`. Run `claude --version`.
Grep the project for `@anthropic-ai/sdk`, `anthropic` (Python), `claude-agent-sdk` to detect a direct API
or Agent SDK integration.

## Step 2 · Ask at most two questions (skipped in auto mode)
**Auto mode**: when invoked as `/fable-setup auto` (or the user said "알아서", "질문 없이", "no questions"),
ask nothing. Defaults: interactive Claude Code use (light autonomy block) and the **widest scope**, global
`~/.claude/CLAUDE.md` (create it if missing). Project scope is chosen only through the question in
non-auto mode. Also skip the confirmation
in Step 4: write the section, then show what was written and how to undo it (delete the delimited block).
Everything else below still runs.

Use AskUserQuestion. Each option needs a one-line explanation and a recommended pick.
1. **How do you mostly work?** (multi-select)
   - Interactive Claude Code, watching and steering → autonomy block in light form (self-check paragraph only)
   - Unattended sessions, agents, CI, headless `claude -p` → full autonomy block including "the user is not watching"
   - Direct API / Agent SDK integration → also produce the harness checklist (Step 5)
2. **Where should the rules live?** Global `~/.claude/CLAUDE.md` (all projects) or this project's `CLAUDE.md`.
   Recommend global for personal machines, project for shared repos.
Skip a question when Step 1 already answers it (for example no project CLAUDE.md and no git repo → global).

## Step 3 · Audit what is already there
Report a short table: rule found → verdict → action.
- Lines that suppress narration ("hold all findings for the final response", "결과는 마지막에 한꺼번에") → remove; Fable 5.1 already under-reports.
- Anti-formatting rules ("no bullet points", "never use headers", "서식 쓰지 마") → replace with block **I**.
- "Ask before every step" style rules → conflict with autonomy block; keep only for destructive actions.
- Existing scope, targeted-edit, or progress rules → keep, mark as already covered, do not duplicate.
- Model or effort pins in settings → note the current value.

## Step 4 · Write the always-on section (idempotent)
Insert or replace one section in the chosen CLAUDE.md, delimited exactly so re-runs update in place:

```
## Fable 5.1 prompting (oh-my-fable)
<!-- oh-my-fable:start v1 -->
…blocks…
<!-- oh-my-fable:end -->
```

Contents, in order, from `prompt-blocks.md`:
- Block **A** paragraph 1 (only for unattended use) + paragraphs 3 and 4 (always; the self-check and the
  "verify before state-changing commands" rule). Include paragraph 2 (the assessment exception) always.
- Block **D** (scope and tests).
- Block **C** (targeted edits).
- Block **E** (progress updates), and delete any narration-suppressing line found in Step 3.
- Block **I** (formatting rule) replacing any anti-formatting rule.
- Block **B** (batch tool calls) as a one-line rule.
Show the exact diff before writing and get confirmation; editing a config file is a state change.
Do not touch anything outside the delimiters.

## Step 5 · Settings and admin checklist (layer 3)
Print what applies; change only what the user confirms.
- **Effort default**: Claude Code reads `CLAUDE_CODE_EFFORT_LEVEL`. Recommend `high` (guide default).
  Warn that `low` skips searches and `max` slows long documents. Show the current value if set.
- **Progress updates over the API**: `thinking.display: "updates"` (beta header
  `thinking-display-updates-2026-08-18`). Without it, progress notes never reach the UI.
- **Conversation history**: append-only, thinking blocks included; per-turn reminders as turn-scoped
  system messages; compaction via server-side compaction or block **K**.
- **Subagents**: start tool returns immediately; results arrive as later user messages.
- **Vision**: give a crop-and-zoom tool for dense charts.
- **Refusals**: handle `stop_reason: "refusal"`; phrase compile checks as "Are there any bugs?".

## Step 6 · Verify and teach
Re-read the edited CLAUDE.md and confirm the delimited section exists exactly once. Then end with this
three-line usage note, translated to the user's language:

> From now on, type your request as usual. When it is short or vague, `/fable-prompt <request>` fills in
> goal, context, scope, done criteria, and effort, shows the improved request, and runs it.
> Add "프롬프트만" / "just the prompt" to see the rewrite without running it.

Report one status: DONE, DONE_WITH_CONCERNS (list what the admin still has to change), or NEEDS_CONTEXT.
