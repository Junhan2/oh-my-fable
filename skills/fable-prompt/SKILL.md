---
name: fable-prompt
description: Rewrite a rough, terse, or under-specified request into a prompt that follows Anthropic's "Prompting Claude Fable 5.1" guide, then carry it out. Use when the user explicitly asks ("/fable-prompt …", "프롬프트 개선해서", "가이드에 맞게 요청해", "제대로 시켜줘", "improve this prompt", "prompt it properly"), or when a TASK request (build, fix, change, analyze, write, research) arrives as a bare one-liner with unresolved referents or no goal, scope, or done-criteria ("뭐 이거 뭐 어떻게 해줘", "이거 좀 고쳐", "fix this"). Do NOT use for conversational questions, single-fact lookups, or requests that already state goal, scope, and verification.
---
# fable-prompt · guide-aligned request rewrite (per-request layer)

Source: Anthropic docs "Prompting Claude Fable 5.1" (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1).
Fixed guide blocks: `references/prompt-blocks.md`. Before/after samples: `references/examples.md`.

This skill handles the **per-request layer** only: the four fields every request needs, plus the guide
blocks that depend on the request. The always-on rules (autonomy, scope limits, targeted edits, progress
updates, formatting, batching) are injected by this plugin's SessionStart hook, so never repeat them here.

## Mode
- **Default: rewrite, show, then execute in the same turn.** Do not stop after showing the prompt.
- **Show only** when the user says "프롬프트만", "보여만 줘", "just the prompt", "don't run it".
- Never ask the user to write the prompt. Build it from conversation context.

## Step 1 · Resolve referents
Fill "이거", "그거", "this", "that file", "the error" from context in this order: last path mentioned, last
error text, last artifact produced, current git diff, open thread. Write the resolved value as a concrete
path, symbol, or quote.

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
4. **Done criteria** · the exact check: a command, a count, a file that must exist, a reproduced workflow.
5. **Effort** · one line. Default `high`. `medium` for routine edits. `low` only for quick lookups, and
   then add block **H** (search nudge) if the topic is time-sensitive. `xhigh`/`max` only when the user asked
   for maximum quality; then add block **G** with the real `max_tokens`.
6. **Conditional blocks** · Assessment → the "report findings, don't fix" sentence. Research/summary →
   block **J** (quoting example). Writing → block **F** (short form). Code task → phrase checks as
   "Are there any bugs?" not "Does it compile?" (safeguard false positives).

**Never attach blocks A, B, C, D, E, or I.** They are already active through the plugin hook. The improved
request stays short: four fields, effort, and only the conditional lines from item 6.

## Step 4 · Show, then run
Print the prompt in one fenced block titled `개선된 요청` (or `Improved request`), then execute it as if
the user had sent it. Open with one line on what you are doing, give brief updates, and close with a
recap that stands on its own. End with exactly one status: DONE, DONE_WITH_CONCERNS, BLOCKED, or NEEDS_CONTEXT.

## Do not
- Do not widen the task while improving it. The rewrite clarifies; it does not add features.
- Do not turn an Assessment into a Change.
- Do not paraphrase block A's first paragraph; its opening sentence carries most of the effect.
- Do not add anti-formatting rules; Fable 5.1 already under-formats.
