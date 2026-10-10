#!/usr/bin/env bash
# Fails when the text the hook injects nears Claude Code's 10,000-character cap on additionalContext. Past the cap
# Claude gets a file path and a 2,000-character preview instead, and nothing can raise it (hooks doc, JSON output).
# It counts bytes, which are never fewer than characters, so the result does not depend on the caller's locale.
# Run before a release: bash tests/context-size.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIMIT=9000
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/cfg" "$TMP/proj"
fail=0

# check LABEL BYTES: one line per measured text, and a failure when it is over the limit
check() {
  printf '%-48s %5s bytes\n' "$1" "$2"
  [ "$2" -le "$LIMIT" ] || { echo "  over $LIMIT: $1"; fail=1; }
}
# hook-only delivery (no rules file in the empty config folder), run by hand so the output is the plain context
# followed by a blank line and the status line in parentheses
context() {
  CLAUDE_CONFIG_DIR="$TMP/cfg" CLAUDE_PROJECT_DIR="$TMP/proj" CLAUDE_CODE_ENTRYPOINT="$1" CLAUDE_CODE_EFFORT_LEVEL="$2" \
    bash "$ROOT/hooks/session-start.sh" </dev/null | sed '/^(oh-my-fable /,$d' | wc -c | tr -d ' '
}
check "session start, interactive, high effort" "$(context cli high)"
check "session start, interactive, max effort" "$(context cli max)"
check "session start, unattended, max effort" "$(context sdk-cli max)"
check "subagent start (hooks/subagent.md)" "$(wc -c < "$ROOT/hooks/subagent.md" | tr -d ' ')"
exit "$fail"
