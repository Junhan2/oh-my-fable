---
name: fable-setup
description: Optional one-time check for Claude Fable 5.1 in Claude Code. The plugin already injects the always-on prompting rules at every session start through a hook, so nothing needs to be edited for the defaults. Use /fable-setup to audit CLAUDE.md and settings for rules that conflict with the Fable 5.1 guide, switch between interactive and unattended mode, or review effort and API settings. Triggers: "/fable-setup", "fable 세팅", "환경 점검", "무인 모드로", "apply the Fable guide", "set up for Fable 5.1", "unattended mode". Also teaches /fable-prompt in three lines at the end.
---
# fable-setup · audit, mode switch, settings checklist

Source: Anthropic "Prompting Claude Fable 5.1". Blocks live in
`${CLAUDE_PLUGIN_ROOT}/skills/fable-prompt/references/prompt-blocks.md`. The always-on rules are injected
by `${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh` at every session start; read
`${CLAUDE_PLUGIN_ROOT}/hooks/always-on.md` to see exactly what is active.

The guide's advice splits into three layers:
1. **Per request** (goal, context, scope, done, effort, conditional nudges) → `/fable-prompt`.
2. **Always-on rules** (autonomy, scope limits, targeted edits, progress updates, formatting, batching) → injected
   by the hook by default; optionally written into CLAUDE.md instead (user's choice, needs a non-auto session
   because Claude Code's permission classifier blocks an agent from editing its own instruction file).
3. **Settings** (mode, effort default, API options) → a small JSON config file plus an admin checklist.

## Mode
- `/fable-setup` (default): run all steps, ask at most two questions (Step 2).
- `/fable-setup auto`, or "알아서", "no questions": skip the questions, keep `hook` delivery and `interactive`
  unless the environment is clearly unattended (headless `claude -p`, CI, an agent harness), report, done.
- `/fable-setup unattended` / `/fable-setup interactive`: set that mode directly.
- `/fable-setup claude-md` / `/fable-setup hook`: choose the delivery directly (see Step 4).

## Step 1 · Detect (one batch of reads)
Read whichever exist: `./CLAUDE.md`, `./.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`, `~/.claude/settings.json`,
`./.claude/settings.json`, `~/.claude/oh-my-fable.json`, `./.claude/oh-my-fable.json`, `./.claude/agents/*.md`,
`~/.claude/agents/*.md`. Run `claude --version`. Grep the project for `@anthropic-ai/sdk`, `anthropic`,
`claude-agent-sdk` to detect a direct API or Agent SDK integration.

## Step 2 · Up to two questions (unless auto or explicit arguments)
AskUserQuestion, options with a one-line explanation and a recommended pick.

1. **How do you mostly use this?**
   - Interactive: I watch and steer → `interactive` (default). Autonomy block without the "not watching" sentence.
   - Unattended: headless runs, agents, CI, long autonomous sessions → `unattended`. Full autonomy block.
2. **Where should the always-on rules live?**
   - Hook (default, recommended): the plugin injects them at session start. Nothing to edit, works in every
     permission mode, removed by uninstalling.
   - CLAUDE.md: a delimited section written into `~/.claude/CLAUDE.md` (or the project's `CLAUDE.md` when the
     current directory is a git repo with one). Visible and editable next to your other rules. **Requires a
     session that is not in auto permission mode**, because Claude Code's classifier blocks an agent from
     editing its own instruction file; the user approves the edit when prompted.
   Skip this question when the argument `claude-md` or `hook` was given.

## Step 3 · Audit (report only, in the user's language)
Table: rule found → verdict → suggestion. Do not edit CLAUDE.md. Suggest exact replacement text the user can
paste, and offer to apply it only if they ask.
- Lines that suppress narration ("hold all findings for the final response", "no closing recap",
  "결과는 마지막에 한꺼번에") → conflict with block E; suggest scoping them to short answers.
- Anti-formatting rules ("no bullet points", "never use headers", "서식 쓰지 마") → conflict with block I.
- "Ask before every step" rules → conflict with the autonomy block; keep only for destructive actions.
- Existing scope, targeted-edit, progress rules → already covered, fine.
- Model and effort pins in settings → note current values.

## Step 4 · Apply the choice
**Hook delivery** (default): write the config only.
Global `~/.claude/oh-my-fable.json`, or project `./.claude/oh-my-fable.json` (wins over global):
```json
{"enabled": true, "mode": "interactive", "delivery": "hook"}
```
Only `enabled`, `mode`, `delivery` are read. If the write is refused, print the JSON and the path; the defaults
(enabled, interactive, hook) apply anyway without any file. Mode changes take effect at the next session start
or `/reload-plugins`.

**CLAUDE.md delivery**: build the section from `${CLAUDE_PLUGIN_ROOT}/hooks/always-on.md` (prepend
`${CLAUDE_PLUGIN_ROOT}/hooks/autonomy-unattended.md` after the heading when mode is unattended). Everything
in it is English regardless of the user's language. Show the exact text, then insert or replace it in the
chosen CLAUDE.md between these delimiters so re-runs update in place and never touch anything else:
```
<!-- oh-my-fable:start v1 -->
…section…
<!-- oh-my-fable:end -->
```
Use the Edit tool (or Write for a new file). If the edit is refused by the permission classifier, do not retry
with another tool: say that CLAUDE.md delivery needs a session outside auto mode, keep the hook delivery
active (do not write `"delivery": "claude-md"`), and tell the user how to finish by hand if they still want
it: paste the shown section into CLAUDE.md, then set `"delivery": "claude-md"` in the config.
When the edit succeeds, write the config with `"delivery": "claude-md"` so the hook stays silent and the rules
are not injected twice.

## Step 5 · Settings checklist (layer 3; report, change only on request)
- **Effort**: Claude Code reads `CLAUDE_CODE_EFFORT_LEVEL` and `settings.json` `effortLevel` /
  `modelSettings.<model>.effortLevel`. Recommend `high` (guide default). Warn that `low` skips searches and
  `max` slows long documents. Show current values and which one actually wins.
- **Direct API integrations only**: `thinking.display: "updates"` (beta header
  `thinking-display-updates-2026-08-18`); append-only history with thinking blocks; turn-scoped system
  messages for per-turn reminders; server-side compaction or block **K**; subagent start tool returns
  immediately; crop-and-zoom tool for vision; handle `stop_reason: "refusal"`.

## Step 6 · Verify and teach
Hook delivery: run `bash "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"` with `CLAUDE_PROJECT_DIR` set to the
current directory and confirm the output contains `(Mode: <chosen mode>`. CLAUDE.md delivery: confirm the
delimiters appear exactly once in the file and the hook script now prints nothing. Then end with this note in the user's language:

> The always-on rules are active in every session; nothing else to install. When a request is short or vague,
> `/fable-prompt <request>` fills in goal, context, scope, done criteria, and effort, shows the improved
> request, and runs it. Add "프롬프트만" / "just the prompt" to see the rewrite without running it.

Report one status: DONE, DONE_WITH_CONCERNS (list what the admin still has to change), or NEEDS_CONTEXT.
