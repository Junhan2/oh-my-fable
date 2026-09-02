# oh-my-fable

[한국어](README.md) · English · [中文](README.zh.md)

A short guide plus two skills for getting the best out of Claude Fable 5.1 in Claude Code.
Everything is grounded in Anthropic's official [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1); the prompt blocks are used verbatim.

## Beginner flow (start to finish)

Written for someone opening Claude Code for the first time. You type only the three bold steps.

| Step | Who | What |
|---|---|---|
| 1 | **You** | Tell Claude Code: `install https://github.com/Junhan2/oh-my-fable` |
| 2 | Claude | Reads this README, then registers the marketplace, installs the plugin, and verifies the install by itself |
| 3 | Claude | Says: "Type these two lines: `/reload-plugins`, then `/fable-setup auto`" |
| 4 | **You** | Type `/reload-plugins`. The plugin you just installed becomes active without a restart |
| 5 | **You** | Type `/fable-setup auto` |
| 6 | Claude | Reads your environment (CLAUDE.md location, settings, agent files), shows a table of old rules that conflict, writes the always-on section into CLAUDE.md, then shows what it wrote and how to undo it. No questions |
| 7 | Claude | Ends with a three-line usage note: "When a request is short or vague, use `/fable-prompt <request>`. Add `just the prompt` to see the rewrite without running it" |
| 8 | You | Work as usual. For vague requests: `/fable-prompt fix this` |

- Prefer to be asked? Drop `auto` in step 5 and run `/fable-setup`. It asks two questions: how you mostly work (interactive / unattended / API integration), and where the rules should live (global `~/.claude/CLAUDE.md` for every project, or this project's `CLAUDE.md` only).
- `auto` uses the widest scope, global `~/.claude/CLAUDE.md` (created if missing). To limit it to one project, run without `auto` and pick the project in the second question.
- Undo: delete everything from `<!-- oh-my-fable:start -->` to `<!-- oh-my-fable:end -->` in CLAUDE.md.
- Why step 4 exists: a newly installed plugin loads after `/reload-plugins` (Claude Code 2.1.258) or a restart. It is a built-in command, so Claude cannot run it for you.

<details>
<summary>Procedure for the AI (Claude reads this README and executes it)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. Confirm `oh-my-fable@oh-my-fable` appears in `claude plugin list`
4. Tell the user exactly two lines: first `/reload-plugins`, then `/fable-setup auto`
5. Say nothing else. `/fable-setup` gives the usage note at its end

</details>

## Manual install (30 seconds)

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```

Then, once, inside Claude Code:

```
/fable-setup
```

It reads your environment, asks two questions (how you work, where rules live), and writes the always-on rules into CLAUDE.md. From then on, when a request is short or vague:

```
/fable-prompt fix this
```

It shows a request with goal, context, scope, done criteria, and effort filled in, then runs it. Add `just the prompt` to only see the rewrite.

## Why (30 seconds)

Fable 5.1 got much better at finishing long tasks on its own, and its habits shifted with it. It narrates less while working, may call one tool per turn, tends to rewrite whole files for small edits, and at low effort answers from memory instead of searching. The official guide is a symptom-to-fix list for those shifts. The fixes fall into three layers, and each layer is applied differently.

## Three layers

| Layer | What | How it is applied |
|---|---|---|
| **1. Every request** | goal, context, scope, done criteria, effort, the "assess only" exception, search nudge for time-sensitive questions, long-output note | filled in by `/fable-prompt` |
| **2. Set once** | autonomy, scope and test limits, targeted edits, progress updates, formatting rule, batched tool calls | written to CLAUDE.md by `/fable-setup` |
| **3. Settings** | effort default, thinking.display, conversation-history rules, subagents, vision crop | reported as a checklist by `/fable-setup`; changed by an admin |

## Layer 1 · every request

A good request has four fields.

| Field | Bad | Good |
|---|---|---|
| Goal | a report please | one-page summary for the exec meeting, conclusion on top |
| Context | that thing from before | `2026-08-sales.xlsx`, sheet "raw" |
| Scope | (none) | the table only. Do not edit the source. Note outliers, do not fix them |
| Done | (none) | totals match the "summary" sheet. Report the match as numbers |

Add depending on the request:
- **When you only describe a problem**: "assess only, do not fix". This is the guide's explicit exception.
- **When fresh information matters**: keep effort at high or above, or add "search the name as I wrote it at least once" (block H).
- **Effort**: default `high`. Routine edits `medium`. `low` may skip searches. Long documents at `xhigh`/`max` get drafted twice and slow down, so attach the long-output note (block G) and leave room in `max_tokens`.
- **Dense prose**: `Please remove all mannered prose.`
- **Summarising sources**: include one correct example (block J).

## Layer 2 · set once (CLAUDE.md)

`/fable-setup` writes the following as a `## Fable 5.1 prompting (oh-my-fable)` section. Running it again updates the same section in place.

| Block | One-line gist | Note |
|---|---|---|
| A autonomy | "The user is not watching. Proceed without asking on reversible actions, stop only for destructive ones. If your last paragraph is a plan, do it now" | the first sentence carries most of the effect. Full block for unattended use, self-check paragraph only for interactive use |
| D scope and tests | do not fix unrequested bugs or extend behaviour; report them as follow-ups. Commit tests only where asked or where the repo already keeps them | still implement everything that was asked, completely |
| C targeted edits | when the result is the same, edit surgically instead of rewriting the file | |
| E progress updates | one opening line, brief updates, a closing recap that stands on its own | first delete any old "hold everything for the final response" rule |
| I formatting rule | lists when the content is multifaceted, minimal formatting when asked, prose in conversation | delete old "no formatting" rules; 5.1 already under-formats |
| B batched tool calls | list what you need, then request every independent item in one response | |

## Layer 3 · settings (admin)

- `CLAUDE_CODE_EFFORT_LEVEL`: recommend `high`. Effort names do not map to the same thinking across models, so do not carry Fable 5 values over unchanged.
- Direct API integrations: set `thinking.display: "updates"` or progress notes never reach the UI. Keep history append-only (thinking blocks included), send per-turn reminders as turn-scoped system messages, and use server-side compaction or block K.
- Subagents: the start tool returns immediately; results come back as later messages.
- Vision: a crop-and-zoom tool gives most of the gain on charts and tables.
- Handle `stop_reason: "refusal"`. Ask "Are there any bugs?" rather than "Does it compile?".

## Symptom to fix

| Symptom | Fix |
|---|---|
| Stops with "Shall I?" | block A (`/fable-setup`) |
| Changes things you did not ask for | block D |
| Silent for minutes | delete old rule, then block E; thinking.display over the API |
| Rewrites the whole file for one line | block C |
| Does not search for fresh information | raise effort or block H |
| Dense prose | `Please remove all mannered prose.` |
| No lists where lists belong | replace anti-formatting rules with block I |
| Source text copied into summaries unmarked | block J example |
| Benign code request refused | ask "Are there any bugs?"; link docs for obscure languages |

Block texts: [`skills/fable-prompt/references/prompt-blocks.md`](skills/fable-prompt/references/prompt-blocks.md)

## Layout

```
oh-my-fable/
├── .claude-plugin/        plugin.json, marketplace.json
├── skills/
│   ├── fable-setup/       one-time setup (layers 2 and 3)
│   └── fable-prompt/      per-request rewrite (layer 1) + references/ block texts and examples
└── README.md              this guide
```

MIT. The guide text itself is copyright Anthropic.
