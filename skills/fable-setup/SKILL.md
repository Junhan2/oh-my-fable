---
name: fable-setup
description: Optional. The plugin works with no setup (hook delivery, auto-detected mode, subagents covered). Use /fable-setup only to change the defaults - keep the rules in a rules file (agent teams) or a CLAUDE.md section, pin interactive/unattended mode, write the effort default - or to audit CLAUDE.md for conflicting rules. To see what is in effect, use /fable-status instead. Triggers: "/fable-setup", "fable 세팅", "환경 점검", "무인 모드로", "apply the Fable guide", "set up for Fable 5.1", "unattended mode", "rules file".
---
# fable-setup · choose delivery, mode, effort; audit conflicts

Blocks: `${CLAUDE_PLUGIN_ROOT}/hooks/always-on.md` (+ `autonomy-unattended.md` for unattended mode).
Guide reference: `${CLAUDE_PLUGIN_ROOT}/skills/fable-prompt/references/prompt-blocks.md`.

Three layers: per request → `/fable-prompt`; always-on rules → hook by default, this skill can move them to a
file; settings → mode, effort, and an admin checklist. Nothing here is required: the defaults work without any file.

## Arguments (skip the matching question)
`auto` (no questions, keep defaults) · `hook` (= hook only, the default) | `rules-file` (rules file + hook) | `claude-md` (delivery; `hook-only` is accepted as an alias of `hook`) ·
`auto` | `interactive` | `unattended` (mode) · `medium` | `high` (effort) · `refresh` (re-copy the rules file only, no
questions, see Step 7) · `remove` (undo everything, see Step 6). To see what is in effect without changing anything, use
`/fable-status`.

## Step 1 · Detect (one batch of reads, silent)
`./CLAUDE.md`, `./.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `./.claude/settings.json`,
`~/.claude/oh-my-fable.json`, `./.claude/oh-my-fable.json`, `~/.claude/rules/`, `./.claude/rules/`,
`claude --version`, and the environment variable `CLAUDE_CODE_EFFORT_LEVEL`.

## Step 2 · Questions: one AskUserQuestion call with up to three questions
Bundle questions 1 to 3 into a single AskUserQuestion call (it supports several questions at once), each with
one-line options and the recommended one marked. No preamble, no explanation paragraphs. The goal is zero manual
steps for the user, so prefer asking over leaving something for them to do by hand.

1. **Where should the rules live?**
   - `Hook only (default, recommended)` · nothing written; the hook carries everything for the main session and sends the short version to every subagent. Always current after a plugin update, nothing to clean up on uninstall
   - `Rules file + hook` · base rules in `~/.claude/rules/oh-my-fable.md` (auto-loaded; per the docs agent teammates load it, the hook does not reach them in a verified way); the hook adds the unattended paragraph per session and the short version for Explore/Plan subagents. Pick this for agent teams
   - `CLAUDE.md section` · inside your CLAUDE.md, static, needs edit approval (not in auto mode)
2. **How do you mostly work?**
   - `Auto (recommended)` · detects per session: unattended for headless/SDK/agent runs, interactive in the terminal or IDE
   - `Interactive` · always as if you watch and steer
   - `Unattended` · always adds "the user is not watching", even in the terminal
3. **Effort default?**
   - `medium (recommended)` · Fable 5 quality at lower cost; raise per task with `/effort high`
   - `high` · Anthropic's guide default
   - `keep current` · shown with the current value from Step 1

Ask afterwards, only when relevant, one more call:
4. **Scope?** (only when the current directory is a git repo with its own CLAUDE.md)
   - `All projects (recommended)` · global files under `~/.claude`
   - `This project only` · files under `./.claude`
5. **Fix the conflicting rules for you?** (only when Step 4 finds conflicts; ask after showing the table)
   - `Yes, apply the suggested edits` · edits CLAUDE.md, needs approval outside auto mode
   - `No, just show me` · you edit by hand

Ask in the user's language.

## Step 3 · Apply
**Config** (always, global `~/.claude/oh-my-fable.json` or project `./.claude/oh-my-fable.json`):
```json
{"enabled": true, "mode": "auto", "delivery": "hook"}
```
If the write is refused, print the JSON and path; defaults apply without a file.

**Rules text** = `always-on.md`, with `autonomy-unattended.md` inserted after the heading when unattended. English
regardless of the user's language. The rules file carries the base rules only; the unattended paragraph is always
added by the hook per session, so `auto` mode works with the default delivery. Only the CLAUDE.md section is static.

- `hook` (hook only, default): write nothing besides the config; make sure no `rules/oh-my-fable.md` with the marker is left
  behind (delete one written earlier by this skill; never touch a file without the marker). Main session and every subagent
  get the rules from the hook.
- `rules-file` (rules file + hook): copy `${CLAUDE_PLUGIN_ROOT}/hooks/rules-file.md` verbatim to
  `~/.claude/rules/oh-my-fable.md` (project scope: `./.claude/rules/oh-my-fable.md`). It starts with the marker
  `<!-- oh-my-fable:rules v1` which tells the hook to add only the unattended paragraph per session. Claude Code
  loads `rules/*.md` for the main session and for subagents and teams, so CLAUDE.md is not edited. Keep
  `"delivery": "hook"` in the config. If the write is refused (auto permission mode may block instruction files),
  say so in one line: the hook then carries everything for the main session, and the user can create the file by
  hand from the shown path. When the plugin ships a newer file, the hook says so at session start; `/fable-setup refresh` updates the copy.
- `claude-md`: insert or replace between `<!-- oh-my-fable:start v1 -->` and `<!-- oh-my-fable:end -->` in the
  chosen CLAUDE.md with the Edit tool; touch nothing else. Set `"delivery": "claude-md"`. If refused, do not retry
  with another tool: say it needs a session outside auto mode, keep `hook`, and show the section for manual paste.

**Effort**: `high` or `medium` → set `effortLevel` in `~/.claude/settings.json` (merge, keep other keys; valid
values are low, medium, high, xhigh). An approval prompt may appear; that is expected. If a
`modelSettings.<model>.effortLevel` or the env var `CLAUDE_CODE_EFFORT_LEVEL` overrides it, say which one wins
in one line. If the write is refused, show the one-line change instead.

**Copies are snapshots.** A rules file or CLAUDE.md section is the text at install time. The rules file carries a
version marker (`oh-my-fable:rules vN`); when the plugin ships a newer one, the hook shows a one-line notice at
session start and `/fable-setup refresh` updates the copy. The hook delivery always uses the current text.

## Step 4 · Audit (one table, then question 5)
Rule found → verdict → one-line suggestion. Edit CLAUDE.md only if the user chose "Yes" in question 5; if
the edit is refused, show the exact replacement text once and move on.
Conflicts to flag: narration suppression ("hold findings for the final response", "no closing recap"),
anti-formatting rules ("no bullets", "no headers"), "ask before every step". Same-meaning rules → "already covered".

## Step 5 · Verify and close
Hook: run `bash "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"` with `CLAUDE_PROJECT_DIR` set and confirm the
last line starts with `(oh-my-fable` and names the expected rules source (`--status` prints the same as a key list). Rules file + hook: confirm the file exists with the marker and the hook prints only the mode line (or the
unattended paragraph). CLAUDE.md: confirm the markers appear exactly once and the hook prints nothing. Then close with exactly this, translated:

> Done. Rules: <delivery>, mode: <mode>, effort: <effort>. They apply automatically from the next Claude Code
> session. To use them in this session right now: if the plugin was installed in this session, type
> `/reload-plugins` first, then `/clear` (one per line; the rules are injected on session start, /clear, and
> compaction). Ask as usual; for short or vague requests use `/fable-prompt <request>`. Add "just the prompt"
> to preview only.

One status line: DONE, DONE_WITH_CONCERNS, or NEEDS_CONTEXT.

## Step 6 · `/fable-setup remove`
Undo everything this skill may have written, then tell the user to run `claude plugin uninstall oh-my-fable@oh-my-fable`:
- delete `~/.claude/oh-my-fable.json` and `./.claude/oh-my-fable.json`
- delete `~/.claude/rules/oh-my-fable.md` and `./.claude/rules/oh-my-fable.md`
- remove the `<!-- oh-my-fable:start` … `<!-- oh-my-fable:end -->` section (and its heading line) from any CLAUDE.md
- `effortLevel` in settings.json is left as is; say so in one line

## Step 7 · `/fable-setup refresh`
No questions. Find the rules file the hook uses (`./.claude/rules/oh-my-fable.md`, else `~/.claude/rules/oh-my-fable.md`
or the one under `CLAUDE_CONFIG_DIR`). If it carries the marker `oh-my-fable:rules`, overwrite it with
`${CLAUDE_PLUGIN_ROOT}/hooks/rules-file.md` verbatim and report the old and new version numbers. If it has no marker
it is the user's own file: do not touch it, say so, and stop. If there is no file, say that nothing needs refreshing
(hook-only delivery is always current).
