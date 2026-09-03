#!/usr/bin/env bash
# oh-my-fable SessionStart hook: emit the always-on Fable 5.1 rules as session context.
#
# Config (optional). Global: $HOME/.claude/oh-my-fable.json  Project: $CLAUDE_PROJECT_DIR/.claude/oh-my-fable.json
#   {"enabled": true, "mode": "auto" | "interactive" | "unattended", "delivery": "hook" | "rules-file" | "claude-md"}
# mode "auto" (default): unattended when Claude Code was started through the SDK or headless mode
# (CLAUDE_CODE_ENTRYPOINT is sdk-cli, sdk-ts, or sdk-py; `claude -p`, Agent SDK apps, and agent harnesses set
# this), interactive otherwise (terminal, IDE).
# Merge rule: a project file may only turn the plugin OFF ("enabled": false). "mode" and "delivery" are read
# from the global file only, so a cloned repository cannot switch an agent to unattended mode.
# Defaults: enabled, auto, hook.
#
# Duplicate guard: if the rules already live in a file (a CLAUDE.md section between the oh-my-fable markers,
# or ~/.claude/rules/oh-my-fable.md, or ./.claude/rules/oh-my-fable.md), this hook prints nothing.
#
# Output is plain text on stdout (Claude Code adds SessionStart stdout to the session context). No python,
# jq, or other runtime is needed, so it behaves the same on macOS, Linux, and Windows Git Bash.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${CLAUDE_PROJECT_DIR:-.}"
GLOBAL="$HOME/.claude/oh-my-fable.json"
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

# duplicate guard: rules already delivered by a file
for f in "$HOME/.claude/CLAUDE.md" "$PROJ/CLAUDE.md" "$PROJ/.claude/CLAUDE.md"; do
  [ -f "$f" ] && grep -q 'oh-my-fable:start' "$f" && exit 0
done
for f in "$HOME/.claude/rules/oh-my-fable.md" "$PROJ/.claude/rules/oh-my-fable.md"; do
  [ -f "$f" ] && exit 0
done

BODY="$(cat "$HERE/always-on.md")"
if [ "$MODE" = unattended ]; then
  HEAD="$(printf '%s\n' "$BODY" | sed -n '1p')"
  REST="$(printf '%s\n' "$BODY" | sed '1d')"
  BODY="$HEAD"$'\n\n'"$(cat "$HERE/autonomy-unattended.md")""$REST"
fi
printf '%s\n\n(oh-my-fable: mode %s%s, delivery hook. Change with /fable-setup. Per-request layer: /fable-prompt.)\n' "$BODY" "$MODE" "$AUTO"
exit 0
