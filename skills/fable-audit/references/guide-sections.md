# Fable 5.1 guide · section checklist

Source: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1
(16 H2 sections, verified 2026-09-07). Anchors are the doc's own `#slug` ids.

`Scope` says where a section can be satisfied:
- `prompt` — a rules file, CLAUDE.md, or a system prompt can carry it. These are the audit's denominator.
- `setting` — a Claude Code setting or an environment variable decides it. Reported, not scored.
- `harness` — the client or API integration decides it (API callers only). Reported as N/A for Claude Code
  unless the project contains code that calls the Messages API directly.

`Plugin` says whether oh-my-fable's own rules already cover it, so an audit of a machine running this plugin
can tell "you wrote it yourself" from "the plugin gives it to you".

---

## 1. consider-all-effort-levels
- Scope: setting
- Asks: start at `high`, then measure `low`/`medium`/`xhigh`/`max` against your own tasks. Effort names do not
  carry over from Fable 5.
- Check: `effortLevel` in `~/.claude/settings.json` and `./.claude/settings.json`,
  `modelSettings.<model>.effortLevel`, and the env var `CLAUDE_CODE_EFFORT_LEVEL`. Report which one wins.
- Verdict rules: a pinned `xhigh`/`max` with no note of why → ⚠️ (see section 14 for the cost). No value set → ✅
  (the default is `high`, which is the guide's starting point).
- Plugin: `/fable-setup` writes this; not part of the rules text.

## 2. ask-for-user-facing-progress-updates
- Scope: prompt
- Asks: one line saying when the model should write user-facing text and what each update contains.
- Satisfied by: a rule naming all three of (a) say what you are about to do before starting, (b) brief updates
  while working, (c) a closing recap that stands on its own.
- Conflict signals: "hold all findings for the final response", "no closing recap", "do not narrate",
  "only reply when finished". The guide says remove these *before* adding anything.
- Plugin: covered (`always-on.md`, progress paragraph).

## 3. batch-independent-tool-calls-in-agent-loops
- Scope: prompt
- Asks: a nudge to list what is needed next privately, then request everything independent in one response.
- Satisfied by: any rule requiring parallel/batched independent tool calls in one message.
- Conflict signals: "one tool call at a time", "ask before each command".
- Plugin: covered (`always-on.md`, last line).

## 4. keep-the-conversation-history-append-only
- Scope: harness
- Asks: append assistant turns byte-for-byte, never edit earlier turns, send per-turn reminders as turn-scoped
  system messages (`clear_at: "next_user_message"`).
- Check: only relevant when the project calls the Messages API itself. Grep for `messages.create`, `anthropic.`,
  `@anthropic-ai/sdk`. If none, report N/A rather than a gap.
- Plugin: not applicable (Claude Code owns the history).

## 5. writing-density
- Scope: prompt
- Asks: define the anti-pattern (mannered prose) rather than asking for "clear writing".
- Satisfied by: a rule banning metaphor or flourish standing in for direct statement, e.g. "don't reach for a
  figure of speech when a literal phrasing exists".
- Partial (🟡): a style rule that only bans surface tokens (em dashes, specific words) without the
  mannered-prose definition.
- Plugin: not covered. Suggested line:
  > Don't use metaphor or rhetorical flourish in place of direct statement. If a literal phrasing exists, use it.

## 6. formatting-in-chat
- Scope: prompt
- Asks: replace blanket anti-formatting rules with a rule that says *when* formatting is appropriate.
- Satisfied by: a conditional formatting rule (lists when asked for or when content is multifaceted; plain prose
  in conversational exchanges; honour an explicit request for minimal formatting).
- Conflict signals (⚠️, this is the common one): unconditional "no bullets", "no headers", "never use bold",
  "no markdown". Fable 5.1 already under-formats; these rules now push it further.
- Plugin: covered (`always-on.md`, formatting paragraph).

## 7. quoting-retrieved-sources
- Scope: prompt
- Asks: one complete worked example in the system prompt — the request, the correct response, and a sentence
  saying why it is correct — showing retrieved passages marked as quotations.
- Satisfied by: an explicit quoting/attribution rule for retrieved or fetched text. A bare "cite sources" line
  without an example is 🟡.
- Applies to: research, summarizing, RAG, and reporting agents. For an agent that never retrieves, report ⚪.
- Plugin: not covered.

## 8. finish-the-whole-task
- Scope: prompt
- Two blocks; the guide says apply both. Score each half.
  - (a) autonomy: "the user is not watching", don't ask permission for work the original request already
    covered, carry out the next steps you stated instead of describing them.
  - (b) delivering work: the request's scope is the deliverable; finish every part that is not blocked and say
    plainly what was left out and why.
- 🟡 when only one half is present. ❌ when neither.
- Plugin: (a) covered in unattended mode only (`autonomy-unattended.md`), plus the "check your last paragraph"
  line in `always-on.md`. (b) not covered by the plugin — this is the most common real gap.

## 9. tell-the-model-what-to-preserve-in-compaction-summaries
- Scope: prompt
- Asks: name what a compaction summary must retain. The guide's list: (1) the task and its acceptance criteria,
  (2) approaches already tried and rejected, (3) decisions made and why, (4) where the work currently stands,
  (5) open questions and promised next steps, (6) exact error text and identifiers. Plus a weighting rule:
  keep the user's own words close to verbatim, compress your own explanations.
- 🟡 when a preservation list exists but misses items. Name the missing numbers.
- Plugin: not covered.

## 10. keep-changes-and-tests-to-what-the-task-asks-for
- Scope: prompt
- Asks: don't fix nearby code, extend unmentioned behavior, or commit test files the change doesn't warrant;
  report them as follow-ups instead.
- Plugin: covered (`always-on.md`, the long paragraph).

## 11. search-triggering-at-low-effort
- Scope: prompt
- Asks: at `low` effort, say that recognizing a name is not the same as knowing its current state, and that such
  names should be searched as the user wrote them.
- Only score this when effort is `low` somewhere (section 1's finding, or an agent config pinned to low).
  Otherwise ⚪ with a one-line note.
- Plugin: not covered. A library-docs rule (e.g. Context7) covers libraries only, not product names or current
  state; that is 🟡, not ✅.

## 12. reduce-safeguard-false-positives
- Scope: prompt (partly habit)
- Asks: prefer "are there any bugs in this program?" over "does this compile?"; give context for lesser-known
  languages; keep base64 blobs out of tool output.
- 🟡 when only one of the three appears.
- Plugin: not covered.

## 13. prefer-targeted-edits-over-whole-file-rewrites
- Scope: prompt
- Asks: edit surgically rather than rewriting a whole file when it does not change the result.
- Plugin: covered (`always-on.md`, token-minimizing line).

## 14. leave-room-for-long-outputs-at-xhigh-and-max-effort
- Scope: setting (API callers also: `max_tokens`)
- Asks: run long-deliverable requests at `high`; move up only where a quality gain was measured. At `xhigh`/`max`
  leave `max_tokens` room for thinking plus the reply.
- Report together with section 1: a pinned `xhigh`/`max` is the usual cause of "long document work got slow".
- Plugin: not applicable.

## 15. let-the-lead-agent-keep-working-while-subagents-run
- Scope: prompt
- Asks: don't force the lead to idle while a subagent runs.
- Conflict signals (⚠️): "the lead waits", "does not implement in parallel with its own team", "wait for all
  results before continuing". Claude Code's Agent tool is already background-by-default, so a rule like this is
  usually the only thing blocking the behavior.
- Note when reporting a conflict: the safe half of such a rule is file ownership (the lead must not edit a file
  a running worker owns) and shutdown discipline. Say that, so the fix narrows the rule instead of deleting it.
- Plugin: not covered.

## 16. give-vision-work-tools-to-crop-and-zoom
- Scope: harness
- Asks: give the model a crop/zoom tool for dense visual inputs.
- Check: whether an image crop or zoom tool is available in the session. If yes ✅, if the work involves no
  images ⚪.
- Plugin: not applicable.
