#!/usr/bin/env bash
# oh-my-fable SessionStart hook: emit the always-on Fable 5.1 rules as additionalContext.
# Config (optional, project file wins over global):
#   $CLAUDE_PROJECT_DIR/.claude/oh-my-fable.json  or  $HOME/.claude/oh-my-fable.json
#   {"enabled": true, "mode": "interactive" | "unattended", "delivery": "hook" | "claude-md"}
# Defaults: enabled, interactive, hook. With delivery "claude-md" the rules live in CLAUDE.md
# (written by /fable-setup with the user's approval) and this hook stays silent to avoid duplicates.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG=""
for c in "${CLAUDE_PROJECT_DIR:-.}/.claude/oh-my-fable.json" "$HOME/.claude/oh-my-fable.json"; do
  [ -f "$c" ] && { CFG="$c"; break; }
done
ENABLED=true; MODE=interactive
if [ -n "$CFG" ]; then
  grep -Eq '"enabled"[[:space:]]*:[[:space:]]*false' "$CFG" && ENABLED=false
  grep -Eq '"mode"[[:space:]]*:[[:space:]]*"unattended"' "$CFG" && MODE=unattended
  grep -Eq '"delivery"[[:space:]]*:[[:space:]]*"claude-md"' "$CFG" && ENABLED=false
fi
[ "$ENABLED" = true ] || exit 0

BODY="$(cat "$HERE/always-on.md")"
if [ "$MODE" = unattended ]; then
  # Insert the "not watching" paragraph right after the heading.
  HEAD="$(printf '%s\n' "$BODY" | sed -n '1p')"
  REST="$(printf '%s\n' "$BODY" | sed '1d')"
  BODY="$HEAD"$'\n\n'"$(cat "$HERE/autonomy-unattended.md")""$REST"
fi
BODY="$BODY"$'\n\n'"(Mode: $MODE. Change with /fable-setup or ~/.claude/oh-my-fable.json. Per-request layer: /fable-prompt.)"

if command -v python3 >/dev/null 2>&1; then
  python3 - "$BODY" <<'PY'
import json, sys
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": sys.argv[1]}}))
PY
elif command -v jq >/dev/null 2>&1; then
  jq -n --arg b "$BODY" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$b}}'
else
  printf '%s\n' "$BODY"
fi
exit 0
