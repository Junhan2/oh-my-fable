---
name: fable-status
description: Show what oh-my-fable is doing right now, in one table, without changing anything. Plugin version, where the rules live, this session's mode and why, effort, whether the rules file is current, and CLAUDE.md conflicts. Triggers: "/fable-status", "fable 상태", "규칙 적용됐어?", "지금 뭐가 켜져 있어", "is oh-my-fable active", "fable status", "which rules are loaded", "check the fable setup".
---
# fable-status · what is in effect (read-only)

This skill writes nothing. It answers "is it working, and how?" in one table so the user never has to
inspect files or hook output by hand. Do not run `/fable-setup` from here; only point to it when a row says so.

## Step 1 · One batch of reads
- `bash "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh" --status` with `CLAUDE_PROJECT_DIR` set to the current
  project root (the hook computes everything: version, config dir, entrypoint, mode, delivery, rules file
  version, effort, subagent delivery, notices).
- `claude --version`.
- The CLAUDE.md files the hook checks (`~/.claude/CLAUDE.md` or `$CLAUDE_CONFIG_DIR/CLAUDE.md`, `./CLAUDE.md`,
  `./.claude/CLAUDE.md`) for conflicting rules: narration suppression ("hold findings for the final response",
  "no closing recap"), anti-formatting rules ("no bullets", "no headers"), "ask before every step".

## Step 2 · One table, in the user's language
| Row | Value | Note when it matters |
|---|---|---|
| Plugin | version from `--status`, Claude Code version | below 2.1.258: say the hook needs a newer Claude Code |
| Rules | `rules_source` in plain words: "rules file + hook", "hook only", "CLAUDE.md section", "your own rules file (hook silent)", "disabled" | show `base_file` when there is one |
| Subagents | the `subagents` line | |
| Mode | `mode`, and when it says `(auto)` add the reason: entrypoint `sdk-*` → unattended, none → interactive | pinned modes: say "pinned in `oh-my-fable.json`" |
| Effort | `effort` | `default` means nothing is set; the guide recommends `medium` for daily work |
| Rules file | `rules_file_version` vs `plugin_rules_version` | differ → "run `/fable-setup refresh`" |
| CLAUDE.md conflicts | count, then one line per conflict with the file and the suggested replacement | none → "none" |
| Notice | the `notice` line when it is not `(none)` | |

Then close with exactly one line, translated: "Nothing was changed. `/fable-setup` changes settings,
`/fable-prompt <request>` improves a single request."

One status line: DONE (or DONE_WITH_CONCERNS when a row needs action).
