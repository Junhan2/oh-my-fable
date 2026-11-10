# Changelog

What changed in each version, newest first. The first session after an update also says it in one line.

To update: `claude plugin update oh-my-fable@oh-my-fable`, then start a new session.

## 2.8.0

Brings the plugin up to Anthropic's Fable 5.2 documents.

**Added**
- Block O, from the Fable 5.2 guide: work through ordinary obstacles (errors, timeouts, locked files, empty results, failing tools) and leave alone what someone deliberately blocked. It is added to unattended sessions and to the short rules subagents get. The base rules did not change.
- `/fable` can attach two more blocks: P for final reports and handoffs, Q for code ownership. Q is attached only when the request asks for the structure to be improved.
- `/fable-audit` lists Fable 5.2 notes N18 to N25: obstacles, approval rules, caution that has built up, standing delegation lines, hard style limits, final reports, code ownership, lines carried over from earlier models.
- A welcome line on the first session after install, and one line saying what changed on the first session after an update.
- A notice at session start when a CLAUDE.md rules section is older than the text the plugin ships.
- Plugin option `Status line at session start` (`/config`): turn off the line shown at every new session.
- Two eval cases for block O.
- A recording of `/fable` at the top of the READMEs, and a section with measured results with and without the plugin on four models.

**Fixed**
- Fable 5.2 starts at `medium` effort in Claude Code and ignores a top-level `effortLevel` in user settings, and the `fable` alias means Fable 5.2. The hook read it as Fable 5.1 at `high`, so the status line was wrong and block N could be added to a session that was not at `xhigh`.

**If you use a copy of the rules**
- Rules file written by `/fable-setup` (`rules/oh-my-fable.md` with the `oh-my-fable:rules v3` marker): nothing to do.
- CLAUDE.md section that includes the unattended paragraphs: run `/fable-setup claude-md` to replace it. The hook reminds you at session start.
- A copy of `hooks/rules-file-unattended.md` in a repository, CI, or a headless-only config folder: copy the file again. Its first line now carries `v3 u2`; an older copy has no numbers and lacks block O. The plugin does not run in those places, so it cannot remind you.

## 2.7.4
- Block M wording; the effort note was dropped.

## 2.7.3
- `/fable` prints its conditional blocks inline.

## 2.7.1 and 2.7.2
- `/fable-setup` never replaces a rules file with an older one, and never suggests it.

## 2.7.0
- Haiku 5.5 support; gaps in the effort rule closed.

## 2.6.0 and 2.6.1
- The `/fable-prompt` alias was removed; the card reads Chinese field names; the `/fable` block is printed before any tool call.

## 2.5.0 to 2.5.3
- The improved request that `/fable` prints is drawn as a card, in the terminal and in the desktop app.

## 2.4.0
- `/fable-prompt` was renamed to `/fable`.

## 2.3.0
- Sonnet 5.5 support; block N (stop once the checks pass) for sessions at `xhigh` or `max` effort.

## 2.2.0
- Rules adapted to Opus 5.5; the plugin stopped writing `effortLevel`.

## 2.1.0
- `/fable-audit`, a read-only check of your rules against the guide.

## 2.0.0 and 2.0.1
- The hook delivers the rules by default and `/fable-setup` became optional. 2.0.1 fixed the effort shown when a per-model value applies.

## 1.7.0
- Rules for subagents (SubagentStart hook), `/fable-status`, and the notice for a rules file older than the plugin.
