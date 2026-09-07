---
name: fable-audit
description: Read-only. Scores your CLAUDE.md, rules files, and agent system prompts against the 16 sections of Anthropic's Fable 5.1 prompting guide - what is missing, what conflicts, what the plugin already covers. Changes nothing; it prints suggested wording and stops. Use /fable-setup to apply changes, /fable-status to see what is in effect. Triggers: "/fable-audit", "가이드 대조", "프롬프트 점검", "규칙 점검", "audit my prompts", "check against the Fable guide", "which guide sections am I missing", "prompt compliance", "system prompt review".
---
# fable-audit · score prompts against the Fable 5.1 guide

Checklist: `${CLAUDE_PLUGIN_ROOT}/skills/fable-audit/references/guide-sections.md` (16 sections, verdict rules,
conflict signals, suggested wording). Read it before judging anything; do not audit from memory.

**This skill never writes.** No Edit, no Write, no settings change, not even a "small obvious fix". A user's rule
that contradicts the guide is often deliberate. Print the finding and the suggested wording; the user decides,
and `/fable-setup` applies. If asked mid-run to fix something, say that `/fable-audit` is read-only and name the
command that does it.

## Arguments
No argument audits this machine's active prompt surface. Otherwise:
`<path>` one file or directory (an agent's system prompt, a project's rules folder) · `global` (`~/.claude` only) ·
`project` (the current directory only) · `plugin` (the plugin's own rule texts, for maintainers) ·
`section <n|slug>` (one section, in depth: fetch that section's anchor URL from the checklist header for the
live wording, then every place it is or isn't satisfied).

## Step 1 · Collect (one batch of reads, silent)
Default set:
- `./CLAUDE.md`, `./.claude/CLAUDE.md`, `~/.claude/CLAUDE.md` (honour `CLAUDE_CONFIG_DIR`)
- every `*.md` in `~/.claude/rules/` and `./.claude/rules/`
- `~/.claude/settings.json`, `./.claude/settings.json`, and `CLAUDE_CODE_EFFORT_LEVEL` (sections 1 and 14)
- the plugin's active rule text: `${CLAUDE_PLUGIN_ROOT}/hooks/always-on.md`, plus
  `autonomy-unattended.md` and `subagent.md`. Read `~/.claude/oh-my-fable.json` first; if the plugin is disabled
  or absent, skip these and say so in the header line, because then nothing is covered for free.
- when a path argument names a directory of agent prompts, each file in it is one audited surface

List the files you actually read, with a count. Never claim a section is missing from files you did not open;
scope every negative to the paths in that list.

## Step 2 · Judge each of the 16 sections
For each section apply the verdict rules in the checklist file:

`✅` present · `🟡` partial (say exactly what is missing) · `❌` absent · `⚠️` a rule contradicts the guide ·
`⚪` not applicable to this surface (harness- or setting-owned, or the work never hits it)

Two rules that decide most of the value of this audit:
- **Quote the evidence.** Every ✅, 🟡 and ⚠️ names the file and quotes the clause it rests on. A verdict with no
  quote is a guess; mark it 🟡 and say you could not confirm it.
- **Same meaning counts.** The guide's wording is not required. A rule that achieves the section's effect in the
  user's own words is ✅. Only a rule that pushes the *opposite* way is ⚠️.

Sections 8 and 9 are scored in halves and by item; see the checklist.

## Step 3 · Report (one table, then three short lists)
```
Fable 5.1 guide audit · <surface> · N files
[table: # | section | verdict | where it is, or what is missing]
Score: X/Y prompt-scope sections (✅ counts 1, 🟡 counts 0.5). Setting: <effort finding>.
```
Y is the count of prompt-scope sections that apply to this surface — never 16 flat, and say which ones you
excluded and why. Then:

1. **Conflicts (⚠️) first**, most consequential first. For each: the clause, why it now works against the model,
   and the narrowest edit that keeps what the rule was protecting. Never propose deleting a rule outright when
   narrowing it preserves the original intent (the checklist calls this out for section 15).
2. **Gaps worth closing**, ranked by how often the surface hits them, not by section order. For each, the exact
   line to add and the file it belongs in. Prefer one agent's system prompt over a global rule when only that
   agent is affected.
3. **Already covered by the plugin**, one line, so the user doesn't re-add what the hook delivers.

Ask in the user's language; keep the section names in English so they match the guide's anchors.

## Step 4 · Close
One line naming what to do next: `/fable-setup` for delivery, mode and effort; hand edits for a user's own
CLAUDE.md; `/fable-status` to confirm what is live. Then one status line: DONE, DONE_WITH_CONCERNS (say which
files could not be read), or NEEDS_CONTEXT (say which path you need).

## Notes
- The checklist is a snapshot of the guide as of 2026-09-07. If the live guide has more or differently named
  sections, say so in the header line rather than silently auditing an old list.
- Auditing a Claude Code machine is the common case, so sections 4, 14 and 16 usually resolve to ⚪ or a setting
  finding. That is a correct result, not a thin one.
