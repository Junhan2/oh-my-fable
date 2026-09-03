#!/usr/bin/env bash
# oh-my-fable hook. Two events, one script:
#   SessionStart  · the always-on Fable 5.1 rules for the main session (plus a one-line status for the user)
#   SubagentStart · a short version of the rules for subagents spawned with the Agent tool
#   --status      · print what is in effect (used by /fable-status); writes nothing
#
# Config (optional). Global: $CLAUDE_CONFIG_DIR/oh-my-fable.json (default ~/.claude)  Project: $CLAUDE_PROJECT_DIR/.claude/oh-my-fable.json
#   {"enabled": true, "mode": "auto" | "interactive" | "unattended", "delivery": "hook" | "rules-file" | "claude-md"}
# mode "auto" (default): unattended when Claude Code was started through the SDK or headless mode
# (CLAUDE_CODE_ENTRYPOINT is sdk-cli, sdk-ts, or sdk-py; `claude -p`, Agent SDK apps, and agent harnesses set
# this), interactive otherwise (terminal, IDE). The SessionStart hook input carries no permission mode and not always the model,
# so the entrypoint is the only per-session signal.
# Merge rule: a project file may only turn the plugin OFF ("enabled": false). "mode" and "delivery" are read
# from the global file only, so a cloned repository cannot switch an agent to unattended mode.
# Defaults: enabled, auto, hook.
#
# Where the base rules come from, in this order:
#   1. a CLAUDE.md section between oh-my-fable:start / oh-my-fable:end (static, user-managed): hook stays silent
#   2. rules/oh-my-fable.md written by /fable-setup (marker oh-my-fable:rules vN): Claude Code auto-loads it for the
#      main session, regular subagents and teams; the hook adds only the unattended paragraph per session and
#      warns once per session when the plugin ships a newer version of that file
#   3. any other rules/oh-my-fable.md (user-managed): hook stays silent
#   4. nothing else: the hook carries everything (hook only)
# Subagents: Explore and Plan never load CLAUDE.md or rules files, so they get the short rules from this hook
# whenever the plugin is enabled. Other subagents get the short rules only in hook-only delivery (otherwise the
# rules file or CLAUDE.md section already reaches them).
#
# Output: plain text when run by hand (no hook JSON on stdin); JSON with additionalContext / systemMessage when
# Claude Code runs it. No python, jq, or other runtime is needed (macOS, Linux, Windows Git Bash).
set -u
export LC_ALL=C
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${CLAUDE_PROJECT_DIR:-.}"
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"   # Claude Code moves settings, rules and plugins with CLAUDE_CONFIG_DIR
GLOBAL="$CFG/oh-my-fable.json"
LOCAL="$PROJ/.claude/oh-my-fable.json"
STATUS=false; [ "${1:-}" = "--status" ] && STATUS=true

# hook input (JSON on stdin); empty when run by hand or with --status
IN=""
if [ "$STATUS" = false ] && [ ! -t 0 ]; then IN="$(cat 2>/dev/null || true)"; fi
jget() { printf '%s' "$IN" | tr -d '[:space:]' | grep -o "\"$1\":\"[^\"]*\"" | head -1 | sed 's/^[^:]*://; s/"//g'; }
EVENT="$(jget hook_event_name)"; SOURCE="$(jget source)"; AGENT="$(jget agent_type)"

# read a JSON string/bool value for key $2 from file $1, ignoring whitespace; empty if absent
val() { [ -f "$1" ] || return 0; tr -d '[:space:]' < "$1" | grep -o "\"$2\":\"\{0,1\}[A-Za-z-]*" | head -1 | sed 's/.*://; s/"//g'; }
# JSON string escaping for the text files (backslash, quote, tab, newline)
jesc() { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/	/\\t/g' | awk 'NR>1{printf "\\n"} {printf "%s", $0}'; }
VERSION="$(grep -o '"version": *"[^"]*"' "$HERE/../.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*: *"//; s/"//')"

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

# Where do the base rules come from? STATE: disabled | claude-md | rules-file | user-rules | hook-only
STATE=hook-only; BASE=""; RULES_V=""; PLUGIN_V="$(grep -o 'oh-my-fable:rules v[0-9]*' "$HERE/rules-file.md" | head -1 | sed 's/.*v//')"
for f in "$CFG/CLAUDE.md" "$PROJ/CLAUDE.md" "$PROJ/.claude/CLAUDE.md"; do
  [ -f "$f" ] && grep -q 'oh-my-fable:start' "$f" && { STATE=claude-md; BASE="$f"; break; }
done
if [ "$STATE" = hook-only ]; then
  for f in "$PROJ/.claude/rules/oh-my-fable.md" "$CFG/rules/oh-my-fable.md"; do
    [ -f "$f" ] || continue
    BASE="$f"
    RULES_V="$(grep -o 'oh-my-fable:rules v[0-9]*' "$f" | head -1 | sed 's/.*v//')"
    if [ -n "$RULES_V" ]; then STATE=rules-file; else STATE=user-rules; fi
    break
  done
fi
[ "$STATE" = hook-only ] && [ "$DELIVERY" = claude-md ] && STATE=claude-md   # config says CLAUDE.md, section not found yet
[ "$ENABLED" = true ] || STATE=disabled

# effort in effect: hook env from Claude Code, else the user's env override (it beats settings.json), else
# settings.json. There a per-model value (modelSettings.<model>.effortLevel) beats the global effortLevel, and the
# SessionStart input does not always name the model, so when a per-model value could apply and the model is unknown
# the hook says nothing rather than something wrong.
MODEL="$(jget model)"
EFFORT="${CLAUDE_EFFORT:-${CLAUDE_CODE_EFFORT_LEVEL:-}}"
if [ -z "$EFFORT" ] && [ -f "$CFG/settings.json" ]; then
  SJ="$(tr -d '[:space:]' < "$CFG/settings.json")"
  PER_MODEL=""; [ -n "$MODEL" ] && PER_MODEL="$(printf '%s' "$SJ" | grep -o "\"$MODEL\":{[^}]*}" | grep -o '"effortLevel":"[a-z]*"' | head -1 | sed 's/.*://; s/"//g')"
  if [ -n "$PER_MODEL" ]; then EFFORT="$PER_MODEL"
  elif printf '%s' "$SJ" | grep -q '"modelSettings":{.*"effortLevel"'; then EFFORT=""   # per-model values exist, model unknown
  else EFFORT="$(val "$CFG/settings.json" effortLevel)"; fi
fi
EFFORT_SHOWN="${EFFORT:+ · effort $EFFORT}"; [ -n "$EFFORT" ] || EFFORT="(per model; see /effort)"

case "$STATE" in
  claude-md)  HOW="CLAUDE.md section${BASE:+ ($BASE)}; hook silent";;
  rules-file) HOW="rules file + hook ($BASE, v$RULES_V)";;
  user-rules) HOW="user-managed rules file ($BASE); hook silent";;
  hook-only)  HOW="hook only";;
  disabled)   HOW="disabled by config";;
esac
STATUS_LINE="oh-my-fable ${VERSION:-?} · mode $MODE$AUTO · rules: $HOW$EFFORT_SHOWN"
UPGRADE=""
[ "$STATE" = rules-file ] && [ -n "$PLUGIN_V" ] && [ "$RULES_V" != "$PLUGIN_V" ] && \
  UPGRADE="oh-my-fable: your rules file is v$RULES_V, the plugin ships v$PLUGIN_V. Run /fable-setup refresh to update it."

if [ "$STATUS" = true ]; then
  case "$STATE" in
    disabled|user-rules) SUB="nothing from the hook";;
    hook-only) SUB="short rules to every subagent (SubagentStart hook)";;
    *) SUB="base file reaches regular subagents; Explore and Plan get the short rules from the hook";;
  esac
  printf 'plugin_version: %s\nconfig_dir: %s\nproject_dir: %s\nentrypoint: %s\nenabled: %s\nmode: %s%s\ndelivery_config: %s\nrules_source: %s\nbase_file: %s\nrules_file_version: %s\nplugin_rules_version: %s\neffort: %s\nsubagents: %s\nnotice: %s\n' \
    "${VERSION:-?}" "$CFG" "$PROJ" "${CLAUDE_CODE_ENTRYPOINT:-(none, interactive)}" "$ENABLED" "$MODE" "$AUTO" "$DELIVERY" "$STATE" "${BASE:-(none)}" "${RULES_V:-(n/a)}" "${PLUGIN_V:-?}" "$EFFORT" "$SUB" "${UPGRADE:-(none)}"
  exit 0
fi

[ "$STATE" = disabled ] && exit 0

# ---------- SubagentStart ----------
if [ "$EVENT" = SubagentStart ]; then
  case "$STATE" in
    user-rules) exit 0;;
    hook-only) ;;
    *) case "$AGENT" in Explore|Plan) ;; *) exit 0;; esac;;
  esac
  printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"%s"}}\n' "$(jesc < "$HERE/subagent.md")"
  exit 0
fi

# ---------- SessionStart (or run by hand) ----------
CTX=""
case "$STATE" in
  claude-md|user-rules) ;;
  rules-file)
    [ "$MODE" = unattended ] && CTX="$(printf '# Fable 5.1 prompting (oh-my-fable), unattended session\n\n%s\n' "$(cat "$HERE/autonomy-unattended.md")")";;
  hook-only)
    BODY="$(cat "$HERE/always-on.md")"
    if [ "$MODE" = unattended ]; then
      HEAD="$(printf '%s\n' "$BODY" | sed -n '1p')"
      REST="$(printf '%s\n' "$BODY" | sed '1d')"
      BODY="$HEAD"$'\n\n'"$(cat "$HERE/autonomy-unattended.md")""$REST"
    fi
    CTX="$BODY";;
esac

if [ -z "$EVENT" ]; then
  # run by hand (/fable-setup verification, curious users): plain text, status last
  [ -n "$CTX" ] && printf '%s\n\n' "$CTX"
  printf '(%s)\n' "$STATUS_LINE"
  [ -n "$UPGRADE" ] && printf '%s\n' "$UPGRADE"
  exit 0
fi

# run by Claude Code: rules go to Claude's context, the status line goes to the user (new sessions only)
MSG=""
[ "$SOURCE" = startup ] && MSG="$STATUS_LINE"
[ -n "$UPGRADE" ] && MSG="${MSG:+$MSG. }$UPGRADE"
[ -z "$CTX" ] && [ -z "$MSG" ] && exit 0
OUT="{"
[ -n "$CTX" ] && OUT="$OUT\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"$(printf '%s' "$CTX" | jesc)\"}"
[ -n "$CTX" ] && [ -n "$MSG" ] && OUT="$OUT,"
[ -n "$MSG" ] && OUT="$OUT\"systemMessage\":\"$(printf '%s' "$MSG" | jesc)\""
printf '%s}\n' "$OUT"
exit 0
