#!/usr/bin/env bash
# oh-my-fable SessionStart hook: emit the always-on Fable 5.1 rules as session context.
#
# Config (optional). Global: $CLAUDE_CONFIG_DIR/oh-my-fable.json (default ~/.claude)  Project: $CLAUDE_PROJECT_DIR/.claude/oh-my-fable.json
#   {"enabled": true, "mode": "auto" | "interactive" | "unattended", "delivery": "hook" | "rules-file" | "claude-md"}
# mode "auto" (default): unattended when Claude Code was started through the SDK or headless mode
# (CLAUDE_CODE_ENTRYPOINT is sdk-cli, sdk-ts, or sdk-py; `claude -p`, Agent SDK apps, and agent harnesses set
# this), interactive otherwise (terminal, IDE).
# Merge rule: a project file may only turn the plugin OFF ("enabled": false). "mode" and "delivery" are read
# from the global file only, so a cloned repository cannot switch an agent to unattended mode.
# Defaults: enabled, auto, hook.
#
# Delivery (1.6.0): the base rules live in ~/.claude/rules/oh-my-fable.md (written by /fable-setup, auto-loaded by
# Claude Code for the main session and for subagents/teams); this hook only adds the unattended paragraph when the
# session is unattended. Without that file the hook carries everything (main session only). With a CLAUDE.md
# section or a user-managed rules file, the hook prints nothing.
#
# Output is plain text on stdout (Claude Code adds SessionStart stdout to the session context). No python,
# jq, or other runtime is needed, so it behaves the same on macOS, Linux, and Windows Git Bash.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${CLAUDE_PROJECT_DIR:-.}"
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"   # Claude Code moves settings, rules and plugins with CLAUDE_CONFIG_DIR
GLOBAL="$CFG/oh-my-fable.json"
LOCAL="$PROJ/.claude/oh-my-fable.json"

# read a JSON string/bool value for key $2 from file $1, ignoring whitespace; empty if absent
val() { [ -f "$1" ] || return 0; tr -d '[:space:]' < "$1" | grep -o "\"$2\":\"\{0,1\}[A-Za-z-]*" | head -1 | sed 's/.*://; s/"//g'; }

ENABLED=true; MODE=auto; DELIVERY=hook
[ "$(val "$GLOBAL" enabled)" = "false" ] && ENABLED=false
[ "$(val "$LOCAL" enabled)" = "false" ] && ENABLED=false
m="$(val "$GLOBAL" mode)"; case "$m" in interactive|unattended) MODE="$m";; esac
AUTO=""
if [ "$MODE" = auto ]; then
  case "${CLAUDE_CODE_ENTRYPOINT:-}" in sdk-cli|sdk-ts|sdk-py) MODE=unattended;; *) MODE=interactive;; esac
  AUTO=" (auto)"
fi
d="$(val "$GLOBAL" delivery)"; [ -n "$d" ] && DELIVERY="$d"
[ "$ENABLED" = true ] || exit 0
[ "$DELIVERY" = hook ] || exit 0

# CLAUDE.md section (static, user-managed): stay silent.
for f in "$CFG/CLAUDE.md" "$PROJ/CLAUDE.md" "$PROJ/.claude/CLAUDE.md"; do
  [ -f "$f" ] && grep -q 'oh-my-fable:start' "$f" && exit 0
done

# Rules file. Two cases:
#  - written by /fable-setup (carries the marker "oh-my-fable:rules"): it holds the base rules and Claude Code
#    auto-loads it for the main session AND for subagents/teams. The hook then adds only the unattended
#    paragraph when this session is unattended (hybrid delivery, the default since 1.6.0).
#  - any other rules file with that name (user-managed, static): stay silent to avoid duplicates.
RULES=""
for f in "$PROJ/.claude/rules/oh-my-fable.md" "$CFG/rules/oh-my-fable.md"; do
  [ -f "$f" ] && { RULES="$f"; break; }
done
if [ -n "$RULES" ]; then
  grep -q 'oh-my-fable:rules' "$RULES" || exit 0
  if [ "$MODE" = unattended ]; then
    printf '# Fable 5.1 prompting (oh-my-fable), unattended session\n\n%s\n(oh-my-fable: mode %s%s, delivery rules-file+hook. Base rules are in %s. Change with /fable-setup. Per-request layer: /fable-prompt.)\n' "$(cat "$HERE/autonomy-unattended.md")" "$MODE" "$AUTO" "$RULES"
  else
    printf '(oh-my-fable: mode %s%s, delivery rules-file+hook. Base rules are in %s. Change with /fable-setup. Per-request layer: /fable-prompt.)\n' "$MODE" "$AUTO" "$RULES"
  fi
  exit 0
fi

# No rules file: the hook carries everything (works, but does not reach subagents; run /fable-setup to add the rules file).
BODY="$(cat "$HERE/always-on.md")"
if [ "$MODE" = unattended ]; then
  HEAD="$(printf '%s\n' "$BODY" | sed -n '1p')"
  REST="$(printf '%s\n' "$BODY" | sed '1d')"
  BODY="$HEAD"$'\n\n'"$(cat "$HERE/autonomy-unattended.md")""$REST"
fi
printf '%s\n\n(oh-my-fable: mode %s%s, delivery hook only. Run /fable-setup to add the rules file so subagents and teams get the rules too. Per-request layer: /fable-prompt.)\n' "$BODY" "$MODE" "$AUTO"
exit 0
