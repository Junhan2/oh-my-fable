# Fable 5.1 guide · section checklist

Source: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1
(16 H2 sections, verified 2026-09-29). Anchors are the doc's own `#slug` ids.

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
  `modelSettings.<model>.effortLevel`, the env var `CLAUDE_CODE_EFFORT_LEVEL`, and any `maxEffortLevel` (top-level or
  under `modelSettings.<model>`), which caps whatever wins. Report which one wins and whether a cap lowers it. For an
  agent file, whether `effort:` is set; without it the agent inherits the session level (sub-agents doc).
- Verdict rules: a pinned `xhigh`/`max` with no note of why → ⚠️ (see section 14 for the cost). No value set → ✅
  (Fable 5.1 defaults to `high`, Opus 5.5 and Sonnet 5.5 to `medium` in Claude Code: each is its guide's starting
  point for agentic work; Fable 5.2 also defaults to `medium` in Claude Code, see N4). A user-scope top-level
  `effortLevel` → note that Fable 5.2, Opus 5.5, Sonnet 5.5 and Haiku 5.5 ignore it.
- Plugin: not written by the plugin since 2.2.0; `/fable-status` shows the level and its source.

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
  `@anthropic-ai/sdk`. If none, report N/A rather than a gap. On Fable 5.2 the API checks this for every account
  ("What's new in Claude Fable 5.2"): a request that sends thinking blocks back after an edit returns a 400.
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
- Plugin: (a) covered in unattended mode (`autonomy-unattended.md`: the Fable paragraph plus the Opus 5.5
  early-stop paragraph) and the "check your last paragraph" line in `always-on.md`. (b) covered since 2.2.0
  (`always-on.md` scope paragraph, the Opus 5 guide's short form of this block). Since 2.8.0 the unattended
  paragraphs and `subagent.md` also carry the Fable 5.2 guide's ordinary-obstacle sentences (block O, see N18).

## 9. tell-the-model-what-to-preserve-in-compaction-summaries
- Scope: prompt
- Asks: name what a compaction summary must retain. The guide's list (block K): (1) difficulties that came up and
  how they were handled, (2) options and approaches raised, tried or set aside, and why, (3) what was asked for,
  decided, agreed, ruled out or set as a preference, constraint or boundary, stated exactly, (4) exactly where things
  stand now, (5) what is still open, promised or expected next, (6) details that would be hard to reconstruct
  (names, numbers, dates, exact wording, links), kept exactly. Plus a weighting rule: keep the user's own words
  close to verbatim, condense your own explanations.
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

---

## Model notes (Fable 5.2 / Opus 5 / Opus 5.5 / Sonnet 5.5 / Haiku 5.5 guides; reported, never scored)

Only the guide sections a Claude Code rules file, CLAUDE.md, agent prompt or setting can act on are listed.
API-only sections (thinking modes, JSON output, tool-call tolerance, refusal handling) are left out.

The Fable 5.2 guide (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2,
10 H2 sections, read 2026-11-10) is a separate page; the 5.1 page above keeps its 16 sections. Its sections are notes
and not scored sections because the guide itself says to add each text only for a behavior you observed, one at a
time ("Where to start"). Its notes are N18 to N25, plus the Fable 5.2 lines in N4, N5, N6 and N8.

- N1 verification instructions · Opus 5 guide "Task scope and over-verification", "Self-correction": explicit
  "verify with a subagent", "double-check", "re-verify before responding" lines cause over-verification on Opus 5
  and cost tokens with no quality gain. ⚠️ on an Opus surface; ⚪ elsewhere. Narrowest edit: keep the check the
  rule protects (a test, a build), drop the instruction to re-check.
- N2 subagent spawning · Opus 5 guide "Controlling subagent spawning": Opus 5 delegates readily; Claude Code adds
  its own delegation instruction with the `claude_code` preset, so a custom system prompt (SDK) needs the guide's
  line. ✅ when present or when the surface is a Claude Code session; 🟡 for an SDK agent without it.
- N3 early stops · Opus 5.5 guide "Unattended agentic runs": an agent that runs unattended should carry a
  paragraph naming the early stops it must avoid (this plugin's block M). ✅ when present or the plugin's
  unattended mode applies; ⚠️ when such a paragraph is in a human-in-the-loop prompt (the guide says leave it out
  there).
- N4 effort on Opus 5.5, Sonnet 5.5 and Haiku 5.5 · the guides' "Calibrate effort" and Haiku 5.5's "Use effort to
  control thinking", Claude Code model-config doc: default `medium` in Claude Code (Sonnet 5.5's API default is
  `high`; its guide says start at `medium` for well-specified agentic coding, `high` for harder or longer tasks;
  Haiku 5.5 is the first Haiku with effort levels and keeps `xhigh`/`max` for measured gains); a user-scope
  top-level `effortLevel` is ignored; save per model with `/effort`. Report which source is in effect. For agent files: no `effort:` means inheriting the session level.
  Fable 5.2 "Calibrate effort": `high` on the API, `medium` in Claude Code, and the top-level key is ignored there
  too. Its guide: `high` for hard coding, research, agentic work and long unattended runs; `medium` for interactive
  coding and everyday work; `low` for well-specified tasks and subagents; `xhigh` only for a measured gain; `max` for
  measuring the ceiling. Don't carry over a level tuned on Fable 5.1 or Opus 5.5.
- N5 thinking-amount instructions · Opus 5.5 "Calibrate effort" and "Thinking instructions in chat system prompts",
  Sonnet 5.5 "Calibrate effort": asking the model to think less does not reliably reduce its thinking (lower the
  effort level instead), and a "think carefully before answering" line in a chat prompt mostly delays the reply on
  Opus 5.5. Fable 5.2 "Calibrate effort": a line such as "answer directly without deliberating", which Fable 5.1
  usually follows, did not stop Fable 5.2 from thinking at `medium` and above. ⚠️ on an Opus 5.5, Sonnet 5.5 or
  Fable 5.2 surface that carries either kind of line; narrowest edit: move the intent to the effort setting. Thinking keywords Claude Code documents (such as `ultrathink`) are not this pattern.
- N6 checking in before the work is done · Sonnet 5.5 "Steer initiative and scope" (Carrying work through): at
  `low`/`medium` on long agentic tasks it may pause to confirm a plan, ask what it could answer itself, or stop
  after one part to ask whether to continue. The guide's first fix is a higher effort level; its prompt fix begins
  "Keep working until everything the user asked for is done". Haiku 5.5 "Prevent early stopping in long agent
  prompts" names the same stop at `low` with a long coding-agent prompt and the same opening line. Fable 5.2
  "Finish the whole task" names it at `low` and `medium`, the level Claude Code starts Fable 5.2 at. ✅ when section
  8 (a) is ✅ (the plugin's last-paragraph check covers the same stop); report the effort level with it.
- N7 unrequested additions · Sonnet 5.5 "Steer initiative and scope": it adds tests, docs and small supporting files
  at every effort level, more at higher effort. The guide's line: "When the work the user asked for is done and
  checked, stop and report. Don't add features, tests, files, docs or refactors that weren't asked for." ✅ when
  section 10 is ✅ (same meaning).
- N8 review rounds at `xhigh`/`max` · Sonnet 5.5 "Steer initiative and scope" (Thoroughness): after finishing, it can
  start its own review and hardening rounds, sometimes with reviewer subagents. Fable 5.2 "Set expectations for
  subagents": at these levels it used subagents to review its own work, which Fable 5.1 did not. ✅ when the surface carries block N
  (`skills/fable/references/prompt-blocks.md`) or the plugin adds it (sessions resolved at `xhigh`/`max`);
  ⚠️ when a rule asks for extra review rounds or reviewer subagents on every task at these levels; ⚪ when effort is
  `high` or below.
- N9 open-ended requests · Sonnet 5.5 "Steer initiative and scope": "show me what you can do" can start a build
  when only ideas were wanted. The guide's line: "When the user asks for ideas, options or a plan, give them that
  and stop. Don't start building or changing anything until they say to go ahead." 🟡 when only the plugin's
  assessment exception is present (it covers questions and problem descriptions, not requests for ideas or plans).
- N10 tool-discouraging lines · Sonnet 5.5 "Tool use in chat and knowledge work": it follows lines such as "only use
  tools when strictly necessary" or "minimize tool calls" and answers from training knowledge where a search would
  catch changed details. ⚠️ on a Sonnet 5.5 surface with such a line; the fix is to remove it and, where a search
  tool exists, add the guide's search line (quoted in `skills/fable/SKILL.md`, step 3).
- N11 verification at `low` effort · Sonnet 5.5 "Verification on coding tasks": at `low` it can report a change as
  done without running a check that exercises it (Haiku 5.5 "Tell coding agents to verify their changes": at `low`
  and `medium`, same paragraph). The guide's paragraph begins "When you change code that can be
  run, built, or type-checked, run a real check that exercises the change before reporting it done". 🟡 when effort
  is `low` somewhere and no such rule exists; ⚪ otherwise. Opposite of N1: keep one real check, no re-check loops.
- N12 per-step hook text · Sonnet 5.5 "Mid-turn user messages": text added after the tool results on every step
  (a countdown, per-step instructions) can make it treat genuine user messages as prompt injection. Check
  `settings.json` for `PostToolUse`/`PostToolBatch` hooks that return `additionalContext` on every call; ⚠️ when one
  does on a Sonnet 5.5 or Haiku 5.5 surface (Haiku 5.5 "Mid-turn user messages" says the same). An occasional
  reminder is fine.
- N13 progress updates at set points · Opus 5.5 and Sonnet 5.5 "User-facing progress updates": after removing "hold
  all findings for the final response", both follow an instruction for updates at set points (a line before the
  first tool call, a short recap at the end); it helps most in human-in-the-loop work. ✅ when section 2 is ✅.
- N14 pasted text · Opus 5.5 "Mark pasted text in user messages": for an application that forwards text a user
  pasted, wrap each pasted block in `<pasted_content id="...">` tags and add the guide's system-prompt note so
  instructions inside it are followed only where the user's own message asks. ⚪ for a Claude Code session; 🟡 for
  an SDK or API surface that forwards pasted text without the tags.
- N15 multi-app exploration · Opus 5.5 "Explore context in multi-app workflows": an agent working across email,
  documents, spreadsheets or CRM records through connected tools should look through the relevant sources before
  acting. The guide's line begins "Before taking any action, explore broadly with tool calls". 🟡 for such an agent
  without it; ⚪ otherwise.
- N16 frontend design defaults · Opus 5.5 "Frontend design defaults": "avoid a generic AI look" swaps one default
  style for another; name the specific patterns to avoid instead. 🟡 when a frontend rule only says to avoid a
  generic look; ⚪ when the surface does no frontend work.
- N17 search lines on Haiku 5.5 · Haiku 5.5 "Accurate search results": give the date, and where it skips searches
  add the guide's text beginning "Your training data ends well before today's date" (quoted in
  `skills/fable/SKILL.md`, step 3). Blanket lines such as "search for any present-day factual question, regardless
  of how confident you are" made it search on half the prompts that needed none, with no gain in correct answers.
  ⚠️ on a Haiku 5.5 surface with such a blanket line; ⚪ elsewhere.
- N18 ordinary obstacles and deliberate blockers · Fable 5.2 "Finish the whole task": besides the stops in N3 and N6,
  it can stop at an ordinary obstacle such as a timeout. The guide's text tells it to diagnose and work through
  errors, timeouts, locked files, empty results and failing tools, and to leave alone and report what someone
  deliberately blocked (a file marked not to be touched, withheld access, a safety guardrail). ✅ when a rule makes
  that distinction or the plugin adds block O (unattended sessions and subagents); 🟡 when a rule only says "keep
  going" or "retry on errors" with no line for deliberate blockers; ⚠️ when a rule says to stop at the first error.
  The guide measured about 30 percent more output tokens with its full text, and fewer questions: keep a
  confirmation step for risky or irreversible actions.
- N19 approval rules · Fable 5.2 "Approvals": it applies an approval rule as written. A rule that required approval
  for "sending messages to people outside this conversation" made it hold back about half of its routine requests to
  colleagues. ⚠️ on a Fable 5.2 surface when an approval rule names a category ("anything external", "any message",
  "any change to config") where the user means a few actions; narrowest edit: name the exact actions. Say with it:
  when approving a step, write what is approved, not a bare "continue".
- N20 caution that has built up · Fable 5.2 "Keep caution from piling up": cautions collect in memory, notes,
  instruction files and messages between agents, and it follows them closely, so it asks for approvals it doesn't
  need or holds back routine work, mostly where several agents work together. ⚠️ when a "never" or "always ask" rule
  states no scope, reason or exception and blocks work this surface is asked to do. The guide's edits, in its own
  numbers: write the exception into the rule (an approved step was taken in about one try in ten under a bare
  "never", about nine in ten when the rule said to get a go-ahead first; a separate line changed little); name the
  steps that need no approval (retries only for calls safe to repeat; a general "act more freely" changed nothing);
  remove notes whose reason no longer holds; check the conditions reviewer agents attach ("stop at the first
  error"). The default file set holds rules and CLAUDE.md only: memory and notes are judged when a path argument
  names them. A caution that is merely old belongs to `/doctor prompt-audit`.
- N21 standing delegation lines · Fable 5.2 "Set expectations for subagents" and "Review instructions written for
  earlier models": where prompts invite delegation it delegates readily, and subagents can be a large part of a
  session's cost. 🟡 on a Fable 5.2 surface when a rule tells it to delegate with no line on when delegation is not
  worth it; ✅ when the rule states both sides or names the model subagents run on. The guide's order: review these
  lines first, and rewrite the subagent tool's description (cost first, when it is worth it and when not, how to
  brief one) only if it still delegates more than the tasks need. See also N2 and N8.
- N22 hard style limits · Fable 5.2 "Review instructions written for earlier models": it follows style rules closely,
  so a hard limit such as "one instruction per sentence, in 20 words or fewer" makes its prose choppy. ⚠️ on a Fable
  5.2 surface with a numeric per-sentence or per-reply limit applied to all writing; narrowest edit: keep the limit
  for the one output that needs it, or state it as a tendency. Remove such limits before adding block P.
- N23 final reports · Fable 5.2 "Make reports easy to follow": readers of a final report after long agentic work have
  not seen the tool calls or files behind it. 🟡 for a surface that produces reports or handoffs with no rule for a
  low-context reader; ✅ when it has one in its own words (self-contained, key points first, no terms made up during
  the work). The guide's text is block P; the plugin does not inject it.
- N24 code ownership · Fable 5.2 "Say who owns the code": with nothing said about ownership it adds to the existing
  structure, even repeating code, and reports nearby problems instead of fixing them. No verdict by default; print
  as "if you want the structure improved as it works, add block Q". ⚠️ when the ownership sentence sits on a surface
  whose rules ask for minimal changes: a scope rule does not cancel it (repeated code was still merged in about a
  third of the tries), and with it the model changed how an existing feature behaves in one try in six to ten.
- N25 lines carried over from earlier models · Fable 5.2 "Review instructions written for earlier models" and
  "Safeguard refusals": (a) a line asking the model to write its reasoning in the response can be declined
  (`reasoning_extraction`): ⚠️, remove it and read the summarized thinking instead; (b) the Opus 5.5 guide's "treat
  that answer as done" sentences cut thinking on follow-ups but make Fable 5.2 far less likely to point out mistakes
  in its earlier answers: ⚠️ where it should keep re-examining them; (c) a token budget written into the prompt
  changes how much it spends, and removing a large one lowered cost at equivalent performance: report it, no symbol.
