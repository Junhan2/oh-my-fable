---
name: fable-setup
description: Optional one-time setup for Claude Fable 5.1 in Claude Code. The plugin already injects the always-on prompting rules at every session start through a hook, so nothing needs to be edited for the defaults. Use /fable-setup to choose where the rules live (hook, a separate rules file, or a CLAUDE.md section), switch interactive/unattended mode, pick the effort default, and audit CLAUDE.md for conflicting rules. Triggers: "/fable-setup", "fable 세팅", "환경 점검", "무인 모드로", "apply the Fable guide", "set up for Fable 5.1", "unattended mode", "rules file".
---
# fable-setup · choose delivery, mode, effort; audit conflicts

Blocks: `${CLAUDE_PLUGIN_ROOT}/hooks/always-on.md` (+ `autonomy-unattended.md` for unattended mode).
Guide reference: `${CLAUDE_PLUGIN_ROOT}/skills/fable-prompt/references/prompt-blocks.md`.

Three layers: per request → `/fable-prompt`; always-on rules → delivered by this skill's choice (hook by
default); settings → mode, effort, and an admin checklist.

## Arguments (skip the matching question)
`auto` (no questions, keep defaults) · `hook` | `rules-file` | `claude-md` (delivery) ·
`interactive` | `unattended` (mode) · `high` | `medium` (effort).

## Step 1 · Detect (one batch of reads, silent)
`./CLAUDE.md`, `./.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `./.claude/settings.json`,
`~/.claude/oh-my-fable.json`, `./.claude/oh-my-fable.json`, `~/.claude/rules/`, `./.claude/rules/`,
`claude --version`, and the environment variable `CLAUDE_CODE_EFFORT_LEVEL`.

## Step 2 · Questions: short, three at most, one AskUserQuestion each
Keep every question and option to one line. No preamble, no explanation paragraphs.

1. **Where should the rules live?**
   - `Hook (recommended)` · nothing to edit, active on install
   - `Separate rules file` · `~/.claude/rules/oh-my-fable.md`, auto-loaded, editable, CLAUDE.md untouched
   - `CLAUDE.md section` · inside your CLAUDE.md, needs edit approval (not in auto mode)
2. **How do you mostly work?**
   - `Interactive (recommended)` · you watch and steer
   - `Unattended` · headless, CI, agents; adds "the user is not watching"
3. **Effort default?**
   - `high (recommended)` · guide default
   - `medium` · Fable 5 quality at lower cost
   - `keep current` · shown with the current value from Step 1

Ask in the user's language. If a git repo with its own CLAUDE.md is the current directory, add
`(this project only)` variants to question 1 instead of a fourth question.

## Step 3 · Apply
**Config** (always, global `~/.claude/oh-my-fable.json` or project `./.claude/oh-my-fable.json`):
```json
{"enabled": true, "mode": "interactive", "delivery": "hook"}
```
If the write is refused, print the JSON and path; defaults apply without a file.

**Rules text** = `always-on.md`, with `autonomy-unattended.md` inserted after the heading when unattended. English
regardless of the user's language.

- `hook`: nothing else to write.
- `rules-file`: write the rules text to `~/.claude/rules/oh-my-fable.md` (project: `./.claude/rules/oh-my-fable.md`).
  Claude Code loads `rules/*.md` automatically, so CLAUDE.md is not edited. Set `"delivery": "rules-file"` so the
  hook stays silent. If the write is refused, write it to `~/.claude/oh-my-fable/rules.md` instead and show the
  one line the user can add to CLAUDE.md: `@~/.claude/oh-my-fable/rules.md`.
- `claude-md`: insert or replace between `<!-- oh-my-fable:start v1 -->` and `<!-- oh-my-fable:end -->` in the
  chosen CLAUDE.md with the Edit tool; touch nothing else. Set `"delivery": "claude-md"`. If refused, do not retry
  with another tool: say it needs a session outside auto mode, keep `hook`, and show the section for manual paste.

**Effort**: `high` or `medium` → set `effortLevel` in `~/.claude/settings.json` (merge, keep other keys). If a
`modelSettings.<model>.effortLevel` or the env var `CLAUDE_CODE_EFFORT_LEVEL` overrides it, say which one wins
in one line. If the write is refused, show the one-line change instead.

## Step 4 · Audit (report only, one table)
Rule found → verdict → one-line suggestion. Never edit CLAUDE.md here.
Conflicts to flag: narration suppression ("hold findings for the final response", "no closing recap"),
anti-formatting rules ("no bullets", "no headers"), "ask before every step". Same-meaning rules → "already covered".

## Step 5 · Verify and close
Hook: run `bash "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"` with `CLAUDE_PROJECT_DIR` set and confirm
`(Mode: …)` appears. Rules file / CLAUDE.md: confirm the file exists (delimiters exactly once) and the hook prints
nothing. Then close with exactly this, translated:

> Done. Rules: <delivery>, mode: <mode>, effort: <effort>. Takes effect from the next session (or `/reload-plugins`).
> Ask as usual; for short or vague requests use `/fable-prompt <request>`. Add "just the prompt" to preview only.

One status line: DONE, DONE_WITH_CONCERNS, or NEEDS_CONTEXT.
