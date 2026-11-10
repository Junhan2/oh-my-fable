---
name: fable
description: Rewrite a rough, terse, or under-specified request into a prompt that follows Anthropic's Claude prompting guides (Fable 5.2, Fable 5.1, Opus 5.5), then carry it out. Add "just the prompt" or "프롬프트만" to only see the rewrite.
argument-hint: "[request]"
disable-model-invocation: true
---
# fable · guide-aligned request rewrite (per-request layer)

Source: Anthropic docs "Prompting Claude Fable 5.2" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2), "Prompting Claude Fable 5.1" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1), "Prompting Claude Opus 5.5" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5), "Prompting Claude Sonnet 5.5" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5), "Prompting Claude Haiku 5.5" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5) and "Prompting Claude Opus 5" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5), which the Opus 5.5 guide names as its starting point.
Fixed guide blocks: `references/prompt-blocks.md`. Before/after samples: `references/examples.md`.
The blocks this skill attaches (F, G, H, J, P, Q) are copied word for word under **Block texts** below, so no file has to
be opened before the block is printed.

This skill handles the **per-request layer** only: the four fields every request needs, plus the guide
blocks that depend on the request. The always-on rules (autonomy, scope limits, scope of the deliverable,
targeted edits, progress updates, formatting, batching, and early stops in unattended sessions) are injected by this plugin's SessionStart hook, so never repeat them here.

## Mode
- **Default: rewrite, show, then execute in the same turn.** Do not stop after showing the prompt.
- **Show only** when the user says "프롬프트만", "보여만 줘", "just the prompt", "don't run it".
- Never ask the user to write the prompt. Build it from conversation context.

## Step 1 · Resolve referents
Fill "이거", "그거", "this", "that file", "the error" from context in this order: last path mentioned, last
error text, last artifact produced, current git diff, open thread. Write the resolved value as a concrete
path, symbol, or quote. Resolve from what the conversation already holds; a referent that needs a lookup
(a file, the git diff) goes in as a stated assumption, checked once you are carrying out the request.

Ask exactly one question (with options and a recommended pick) only when different readings would lead
to **materially different work**. Routine ambiguity: pick the reading the wording and surrounding code
most directly support and state the assumption inside the prompt.

## Step 2 · Classify
| Kind | Signal | Deliverable |
|---|---|---|
| Change | build/fix/change verbs | working change + verification evidence |
| Assessment | user describes a problem, asks why, thinks out loud | findings only, **no fix** until asked (guide exception) |
| Research | look up, investigate, names of tools or models, anything time-sensitive | sourced answer; search the name as the user wrote it |
| Writing | write, summarise, draft a doc or post | text in the requested shape, no mannered prose |
| Long deliverable | full rewrite, multi-section doc, big table, whole file | as above plus the long-output note (block G) |

## Step 3 · Compose
Write task-specific parts (goal, context, scope, done) in the user's language so they can check them. Keep every guide block in English verbatim; never translate a block.

1. **Goal** · one sentence, outcome-verifiable.
2. **Context** · resolved paths, symbols, error text, related decisions.
3. **Scope** · what is in, what is explicitly out.
4. **Done criteria** · the exact check: a command, a count, a file that must exist, a reproduced workflow. Write
   criteria that can be checked without a human (e.g. a command, a count, a file), not "looks right".
5. **Effort** · do not write an effort line into the request; a line in a prompt changes nothing in Claude Code.
   Effort is a setting (`/effort` saves it per model in `modelSettings`; `CLAUDE_CODE_EFFORT_LEVEL` overrides).
   This session runs at `${CLAUDE_EFFORT}` effort. Mention it only when it
   matters for this request: time-sensitive research at `low` → add block **H**; a long deliverable at `xhigh`
   or `max` → add block **G**.
6. **Conditional blocks** · Assessment → the "report findings, don't fix" sentence. Research/summary →
   the line `+ block J` (J is too long for the block; follow it while you write the answer). Research on Sonnet 5.5 (any effort) → instead of block **H**, its guide's own
   search line, verbatim: `Use the search tool to check specifics that may have changed since your training, such as what is allowed, required or charged, even when you feel confident. For researched work such as a report or a comparison, gather current sources rather than writing from your training knowledge.` Research on Haiku 5.5 (any effort) → instead of block **H**, its guide's own search text, verbatim: `Your training data ends well before today's date. Records, office holders, prices, versions, rules and anything "latest" may have changed since then, so search for those before you answer, even when you feel sure. Facts that can't change need no search. When the answer depends on where the user is, put the user's country or region in the search query.` Writing → block **F** (short form). Code task → phrase checks as
   "Are there any bugs?" not "Does it compile?" (safeguard false positives). A final report or handoff that someone
   who did not watch the work will read (an investigation, an audit, a long multi-step change) → the line
   `+ block P`. The user says the code is yours to shape, or asks you to restructure or clean up a codebase you will
   keep building on → block **Q**, with that cleanup written into the scope field; never when the request asks for
   minimal changes or the code is someone else's (Q pulls against the always-on scope rule, block D).

**Never attach blocks A, B, C, D, E, I, L, M, N, or O.** They are already active through the plugin hook (N only at
`xhigh`/`max`, where the hook adds it; M and O only where the hook adds them). The improved
request stays short: four fields and only the conditional lines from item 6.

## Block texts
Copied word for word from `references/prompt-blocks.md`. Put the text itself in the block, never a `+ block`
label, except for J and P.

**F · Writing density** (short form):

```text
Please remove all mannered prose.
```

**G · Long outputs at xhigh or max effort**, at the end of the block. Replace `[max_tokens]` with
`CLAUDE_CODE_MAX_OUTPUT_TOKENS` when you know this session sets it; otherwise leave out ` of about [max_tokens] tokens`.

```text
Everything produced in one reply, including any reasoning or drafting done before the reply, counts toward a single limit of about [max_tokens] tokens. If that limit is reached before the reply is finished, the person receives a cut-off response and has to start over. Composing an entire output or deliverable in full as reasoning and then again as a reply would double the length of the turn without improving the result, so don't do that.

Instead, when the person has asked for a long or effort-intensive deliverable such as a multi-section document, a large table or dataset, or a complete code file, spend extra effort on understanding the request, checking the inputs the answer depends on, settling the structure and other difficult decisions, and otherwise using the reasoning space to reason and the output space to write an output. Usually it is not needed to draft an output multiple times.
```

**H · Search triggering at low effort** (on Sonnet 5.5 and Haiku 5.5, use their own search text from item 6 instead):

```text
When a query centers on a name you do not confidently recognize, or recognize from a fast-moving area like AI models and developer tools where the landscape shifts within months, the name itself is the thing to verify: search before answering, and include the name as the user wrote it in at least one query alongside any reformulations. This holds even when you have some background on it; partial background is exactly what makes an out-of-date answer sound authoritative, so familiarity is not a reason to skip the search.
```

**J · Quoting retrieved sources.** Write only the line `+ block J` in the block, then write the answer the way this
example does:

```text
<example>
<user>look up how the Riverton Ledger and the Coast Dispatch each covered the Harbor Bridge closure and compare their reporting</user>
<response>
[web_search: Harbor Bridge closure Riverton Ledger]
[web_search: Harbor Bridge closure Coast Dispatch]
Both outlets agree on the basics: the bridge closed on March 3 after inspectors found cracked welds, and the state expects repairs to take about eight months. Where they differ is emphasis. The Ledger treats it as a local-economy story. The Dispatch frames it as a funding failure; its editorial calls the closure "entirely foreseeable." Read together, the Ledger explains who is affected now and the Dispatch explains how it came to this; neither account alone gives the whole picture.
</response>
<rationale>CORRECT: The response is organized around where the two outlets agree and differ, not as a walk through either article. Each outlet's reporting is conveyed in one or two sentences of the assistant's own indirect speech. One short marked phrase from one source; every other claim is reworded. The response is still specific and complete.</rationale>
</example>
```

**P · Final reports and handoffs.** Write only the line `+ block P` in the block, then write the final report the
way this text says:

```text
# Communicating clearly
Write for an intelligent but low-context reader. The person reading has not seen your tool calls, your reasoning or the files you opened, and may be switching in from other work. Messages should generally be self-contained: the reader should understand what you mean without having to dig for other context. Put the key points in the first few sentences. Practice progressive disclosure in your sentence order, and do not use undefined references and ideas in line 1 that won't make sense until the reader reaches line 12.

Use plain words, and write in clear, understandable full sentences. Do not use a term or abbreviation that you made up during the work. Say what the thing is in a way any reader would understand. Write mostly in the style of ASD-STE100 Simplified Technical English: short sentences, one idea per sentence, active voice, and consistently using the same word for the same thing. Use a paragraph of flowing prose where ideas connect, and keep bullets for lists of separate items. Leave out unnecessary details unless the reader asks and practice concision, but do ensure that your messages have the key context. Aim to make your user-facing text as human-readable and clear as possible.
```

**Q · Code ownership** (only under the condition in item 6):

```text
This codebase is yours: what it's for and how it's built are your call, and you'll keep building on it.
```

## Step 4 · Show, then run
Print the prompt in one fenced block titled `개선된 요청` (or `Improved request`), four fields only plus any conditional lines, then execute it as if
the user had sent it. The block opens your reply: print it in your first message, before any tool call, in
place of an opening line (only step 1's question may come first). Words written after a tool call often
reach the user only as a one-line summary, so a block printed later can be lost. Give brief updates while
you work, and close with a recap that stands on its own. End with exactly one status: DONE, DONE_WITH_CONCERNS, BLOCKED, or NEEDS_CONTEXT.

## Do not
- Do not widen the task while improving it. The rewrite clarifies; it does not add features.
- Do not turn an Assessment into a Change.
- Do not attach block Q to make a request sound more capable. It changes what gets edited; the user has to have asked for that.
- Do not add anti-formatting rules; the conditional formatting rule (block I) is already active.
