#!/usr/bin/env bash
# oh-my-fable hook. Three events, one script:
#   SessionStart    · the always-on working rules for the main session (plus a one-line status for the user)
#   SubagentStart   · a short version of the rules for subagents spawned with the Agent tool (forks skipped)
#   PostModelSwitch · block N when a mid-session model switch moves the session to xhigh or max effort
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
#      main session, regular subagents and teams; the hook adds only the unattended paragraphs per session and
#      warns once per session when the plugin ships a newer version of that file (or, when the file is newer than
#      this plugin copy, says to start a new session instead of refreshing)
#   3. any other rules/oh-my-fable.md (user-managed): hook stays silent
#   4. nothing else: the hook carries everything (hook only)
# Effort: when the level resolved at SessionStart is xhigh or max, the hook also adds effort-high.md (block N, from
# the Sonnet 5.5 guide: stop after the checks pass, no self-started review rounds) in states 2 and 4.
# Subagents: Explore and Plan never load CLAUDE.md or rules files, so they get the short rules from this hook
# whenever the plugin is enabled. Other subagents get the short rules only in hook-only delivery (otherwise the
# rules file or CLAUDE.md section already reaches them).
# A custom subagent whose definition sets omitClaudeMd: true (Claude Code 2.1.271+) loads no rules files either:
# measured 2026-09-29 on 2.1.284, such an agent saw neither ~/.claude/rules/*.md, the project's .claude/rules/*.md,
# nor CLAUDE.md, while the same agent without the flag saw all three. SubagentStart input carries only agent_type,
# not the agent's definition, so the hook cannot tell these agents apart: under hook-only delivery they get the short
# rules like every subagent; under the other deliveries they get nothing from this plugin. That fits the flag's
# purpose (a lean context); a rule that must reach such an agent belongs in its delegation prompt or its own prompt.
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
# a fork inherits the whole conversation, these rules included (sub-agents doc): nothing to add, so stop before any work
[ "$EVENT" = SubagentStart ] && [ "$AGENT" = fork ] && exit 0

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

# effort, shown in the startup status line and used for the xhigh/max paragraph. Claude Code sets CLAUDE_EFFORT (and
# the effort input field) only inside tool-use contexts, never for SessionStart (hooks doc, common input fields;
# measured on 2.1.280), so a CLAUDE_EFFORT seen at SessionStart was inherited from a parent session's Bash tool and
# describes that session: ignored. With --status (run by the Bash tool inside the session) CLAUDE_EFFORT is the live
# level and wins. Otherwise: the env override, then the user settings file, where modelSettings.<canonical
# model>.effortLevel beats the top-level effortLevel, then the model's default (model-config doc). A maxEffortLevel
# (modelSettings.<model>.maxEffortLevel, else top-level) caps whatever was resolved, the default included (settings
# reference). Only the user settings file is read; levels and caps from project or managed settings are not seen.
# `claude -p` sends SessionStart no model field (measured 2026-09-29 on 2.1.284), so headless runs resolve effort
# only from CLAUDE_CODE_EFFORT_LEVEL; without it the status line shows none and block N is not added. After /clear or
# a compaction the model can be omitted too (hooks doc); the session keeps the model it ran, normally the one /model
# saved to the user settings' `model` field (model-config doc), so there it is read from that field.
# Per model: the default effort and whether a user-scope top-level effortLevel is ignored ("Opus 5.5 and models
# released after it", model-config doc). When a model ships, extend this table, and the alias map in
# model_from_settings when an alias moves to it.
model_traits() {   # sets DEFAULT_EFFORT and IGNORES_TOP for model $1
  IGNORES_TOP=false
  case "$1" in
    claude-opus-5-5*|claude-sonnet-5-5*|claude-haiku-5-5*) DEFAULT_EFFORT=medium; IGNORES_TOP=true;;
    claude-opus-4-7*) DEFAULT_EFFORT=xhigh;;
    *) DEFAULT_EFFORT=high;;
  esac
}
canon() { printf '%s' "$1" | sed 's/\[1m\]$//; s/-[0-9]\{8\}$//'; }   # canonical id: no [1m], no date suffix
# The settings' model in Claude Code's order (ANTHROPIC_MODEL, settings, ANTHROPIC_DEFAULT_MODEL). An alias maps to
# what it means on the Anthropic API today (model-config alias table); with a third-party provider aliases mean older
# models, so only the ANTHROPIC_DEFAULT_<FAMILY>_MODEL overrides count. best, opusplan and default stay unknown.
model_from_settings() {
  local m over def
  m="${ANTHROPIC_MODEL:-}"
  [ -n "$m" ] || m="$(printf '%s' "$SJ" | top_val model)"
  [ -n "$m" ] || m="${ANTHROPIC_DEFAULT_MODEL:-}"
  m="$(canon "$m")"
  case "$m" in
    opus)   over="${ANTHROPIC_DEFAULT_OPUS_MODEL:-}";   def=claude-opus-5-5;;
    sonnet) over="${ANTHROPIC_DEFAULT_SONNET_MODEL:-}"; def=claude-sonnet-5-5;;
    haiku)  over="${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}";  def=claude-haiku-5-5;;
    fable)  over="${ANTHROPIC_DEFAULT_FABLE_MODEL:-}";  def=claude-fable-5-1;;
    claude-*) printf '%s' "$m"; return 0;;
    *) return 0;;
  esac
  if [ -n "$over" ]; then canon "$over"; return 0; fi
  [ -n "${CLAUDE_CODE_USE_BEDROCK:-}${CLAUDE_CODE_USE_VERTEX:-}${CLAUDE_CODE_USE_FOUNDRY:-}${CLAUDE_CODE_USE_ANTHROPIC_AWS:-}${CLAUDE_CODE_USE_MANTLE:-}" ] || echo "$def"
}
level_rank() { case "$1" in low) echo 1;; medium) echo 2;; high) echo 3;; xhigh) echo 4;; max) echo 5;; *) echo 0;; esac; }
key_val() { grep -o "\"$1\":\"[^\"]*\"" | head -1 | sed 's/^[^:]*://; s/"//g'; }   # first "key":"value" on stdin
top_val() { sed "s/\"[^\"]*\":{[^{}]*\"$1\":\"[^\"]*\"[^{}]*}//g" | key_val "$1"; }   # the same, outside per-model objects
EFFORT=""; SRC=""; HIGH_EFFORT=false; MODEL_NOTE=""
SJ=""; [ "$EVENT" != SubagentStart ] && [ -f "$CFG/settings.json" ] && SJ="$(tr -d '[:space:]' < "$CFG/settings.json")"
# resolve_effort: sets EFFORT, SRC and HIGH_EFFORT for $MODEL (may be empty); MODEL_NOTE follows a source read for it
resolve_effort() {
  EFFORT=""; SRC=""; HIGH_EFFORT=false
  MOBJ=""; [ -n "$MODEL" ] && MOBJ="$(printf '%s' "$SJ" | grep -o "\"$MODEL\":{[^}]*}")"
  if [ "$STATUS" = true ] && [ -n "${CLAUDE_EFFORT:-}" ]; then EFFORT="$CLAUDE_EFFORT"; SRC=live
  elif [ -n "${CLAUDE_CODE_EFFORT_LEVEL:-}" ]; then EFFORT="$CLAUDE_CODE_EFFORT_LEVEL"; SRC=env
  elif [ -n "$MODEL" ]; then
    model_traits "$MODEL"
    PER_MODEL="$(printf '%s' "$MOBJ" | key_val effortLevel)"
    TOP=""; IGNORED=""; [ -n "$PER_MODEL" ] || TOP="$(printf '%s' "$SJ" | top_val effortLevel)"
    if [ -n "$TOP" ] && [ "$IGNORES_TOP" = true ]; then IGNORED=", top-level effortLevel $TOP ignored"; TOP=""; fi
    if [ -n "$PER_MODEL" ]; then EFFORT="$PER_MODEL"; SRC=saved
    elif [ -n "$TOP" ]; then EFFORT="$TOP"; SRC=settings
    else EFFORT="$DEFAULT_EFFORT"; SRC="model default$IGNORED"; fi
    SRC="$SRC$MODEL_NOTE"
  fi
  CAP="$(printf '%s' "$MOBJ" | key_val maxEffortLevel)"; [ -n "$CAP" ] || CAP="$(printf '%s' "$SJ" | top_val maxEffortLevel)"
  if [ -n "$EFFORT" ] && [ "$(level_rank "$CAP")" -gt 0 ] && [ "$(level_rank "$EFFORT")" -gt "$(level_rank "$CAP")" ]; then
    SRC="$SRC, $EFFORT → $CAP by maxEffortLevel"; EFFORT="$CAP"
  fi
  case "$EFFORT" in xhigh|max) HIGH_EFFORT=true;; esac
}
P2=$'\n\n'
# block N with its one-line lead-in, for the effort resolved last
high_paragraph() { printf '%s' "This session runs at $EFFORT effort ($SRC); the user's standing rule for that level follows.$P2$(cat "$HERE/effort-high.md")"; }
if [ "$STATUS" = true ] || [ -z "$EVENT" ] || [ "$EVENT" = SessionStart ]; then
  MODEL="$(canon "$(jget model)")"
  if [ -z "$MODEL" ] && [ "$EVENT" = SessionStart ] && [ "$SOURCE" != startup ]; then
    MODEL="$(model_from_settings)"; [ -n "$MODEL" ] && MODEL_NOTE=", model $MODEL from settings"
  fi
  resolve_effort
fi
EFFORT_SHOWN="${EFFORT:+ · effort $EFFORT ($SRC)}"; [ -n "$EFFORT" ] || EFFORT="(not known at session start; /effort shows it)"

case "$STATE" in
  claude-md)  HOW="CLAUDE.md section; hook silent";;
  rules-file) HOW="rules file v$RULES_V + hook";;
  user-rules) HOW="user-managed rules file; hook silent";;
  hook-only)  HOW="hook only";;
  disabled)   HOW="disabled by config";;
esac
STATUS_LINE="oh-my-fable ${VERSION:-?} · mode $MODE$AUTO · rules: $HOW$EFFORT_SHOWN"
# a rules file newer than this plugin copy: the session started before an update, or this folder's plugin is older
NOTICE=""
if [ "$STATE" = rules-file ] && [ -n "$PLUGIN_V" ]; then
  if [ "$RULES_V" -lt "$PLUGIN_V" ]; then
    NOTICE="oh-my-fable: your rules file is v$RULES_V, the plugin ships v$PLUGIN_V. Run /fable-setup refresh to update it."
  elif [ "$RULES_V" -gt "$PLUGIN_V" ]; then
    NOTICE="oh-my-fable: your rules file is v$RULES_V, newer than the v$PLUGIN_V this plugin ships, so this session runs an older plugin. Start a new session (update the plugin first if it is not updated yet). Don't run /fable-setup refresh: it would downgrade the file."
  fi
fi

if [ "$STATUS" = true ]; then
  case "$STATE" in
    disabled|user-rules) SUB="nothing from the hook";;
    hook-only) SUB="short rules to every subagent (SubagentStart hook)";;
    *) SUB="base file reaches regular subagents; Explore and Plan get the short rules from the hook";;
  esac
  printf 'plugin_version: %s\nconfig_dir: %s\nproject_dir: %s\nentrypoint: %s\nenabled: %s\nmode: %s%s\ndelivery_config: %s\nrules_source: %s\nbase_file: %s\nrules_file_version: %s\nplugin_rules_version: %s\neffort: %s\neffort_source: %s\nsubagents: %s\nnotice: %s\n' \
    "${VERSION:-?}" "$CFG" "$PROJ" "${CLAUDE_CODE_ENTRYPOINT:-(none, interactive)}" "$ENABLED" "$MODE" "$AUTO" "$DELIVERY" "$STATE" "${BASE:-(none)}" "${RULES_V:-(n/a)}" "${PLUGIN_V:-?}" "$EFFORT" "${SRC:-(n/a)}" "$SUB" "${NOTICE:-(none)}"
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

# ---------- PostModelSwitch ----------
# The session's model changed (2.1.251+; hooks doc). Add block N when the new model runs at xhigh or max. A paragraph
# injected earlier cannot be taken back, and a switch between two such models repeats it, which is harmless. A resume
# restores the model and replays the earlier context, so it adds nothing.
if [ "$EVENT" = PostModelSwitch ]; then
  case "$STATE" in rules-file|hook-only) ;; *) exit 0;; esac
  [ "$SOURCE" = resume ] && exit 0
  MODEL="$(canon "$(jget to_model)")"; resolve_effort
  [ "$HIGH_EFFORT" = true ] || exit 0
  printf '{"hookSpecificOutput":{"hookEventName":"PostModelSwitch","additionalContext":"%s"}}\n' "$(high_paragraph | jesc)"
  exit 0
fi

# ---------- SessionStart (or run by hand) ----------
# Each injected part opens with a one-line factual lead-in: the hooks doc asks for additionalContext written as
# factual statements, because text framed as out-of-band system commands can trigger prompt-injection defenses.
# The rule paragraphs themselves are unchanged.
if [ "$AUTO" = "" ]; then UNATTENDED_LEAD="The user set oh-my-fable to unattended mode for every session; the user's standing rules for such sessions follow."
else UNATTENDED_LEAD="This session was started headless (entrypoint ${CLAUDE_CODE_ENTRYPOINT:-unknown}); the user's standing rules for such sessions follow."; fi
UNATTENDED="$UNATTENDED_LEAD$P2$(cat "$HERE/autonomy-unattended.md")"
HIGH="$(high_paragraph)"
CTX=""
case "$STATE" in
  claude-md|user-rules) ;;
  rules-file)   # the base rules come from the rules file; add only what depends on this session
    EXTRA=""
    [ "$MODE" = unattended ] && EXTRA="$UNATTENDED"
    [ "$HIGH_EFFORT" = true ] && EXTRA="${EXTRA:+$EXTRA$P2}$HIGH"
    [ -n "$EXTRA" ] && CTX="# Working rules (oh-my-fable), this session$P2$EXTRA";;
  hook-only)
    BODY="$(cat "$HERE/always-on.md")"
    HEAD="$(printf '%s\n' "$BODY" | sed -n '1p')"
    REST="$(printf '%s\n' "$BODY" | sed '1d')"
    CTX="The user installed oh-my-fable; these are the user's standing working rules.$P2$HEAD"
    [ "$MODE" = unattended ] && CTX="$CTX$P2$UNATTENDED"
    CTX="$CTX"$'\n'"$REST"
    [ "$HIGH_EFFORT" = true ] && CTX="$CTX$P2$HIGH";;
esac

if [ -z "$EVENT" ]; then
  # run by hand (/fable-setup verification, curious users): plain text, status last
  [ -n "$CTX" ] && printf '%s\n\n' "$CTX"
  printf '(%s)\n' "$STATUS_LINE"
  [ -n "$NOTICE" ] && printf '%s\n' "$NOTICE"
  exit 0
fi

# run by Claude Code: rules go to Claude's context, the status line goes to the user (new sessions only)
MSG=""
[ "$SOURCE" = startup ] && MSG="$STATUS_LINE"
[ -n "$NOTICE" ] && MSG="${MSG:+$MSG. }$NOTICE"
[ -z "$CTX" ] && [ -z "$MSG" ] && exit 0
OUT="{"
[ -n "$CTX" ] && OUT="$OUT\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"$(printf '%s' "$CTX" | jesc)\"}"
[ -n "$CTX" ] && [ -n "$MSG" ] && OUT="$OUT,"
[ -n "$MSG" ] && OUT="$OUT\"systemMessage\":\"$(printf '%s' "$MSG" | jesc)\""
printf '%s}\n' "$OUT"
exit 0
