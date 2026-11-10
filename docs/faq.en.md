# FAQ

[← oh-my-fable](../README.en.md) · [한국어](faq.md) · English · [中文](faq.zh.md)

[Install and remove](#install-and-remove) · [Check that it is on](#check-that-it-is-on) · [What you see on screen](#what-you-see-on-screen) · [Rules and settings](#rules-and-settings) · [Models](#models) · [Other environments](#other-environments)

## Install and remove

### Why `/reload-plugins` and then `/clear` to use it right away?

The two commands do different things per the official docs. `/reload-plugins` "reloads plugins, skills, agents, hooks, plugin MCP servers, and plugin LSP servers" without a restart ([Plugins](https://code.claude.com/docs/en/plugins)).

The SessionStart hook that injects the rules fires only on `startup`, `resume`, `/clear`, `compact`, and `fork` ([Hooks](https://code.claude.com/docs/en/hooks#sessionstart)).

So reload registers the hook but does not run it; in the install session, `/clear` runs it once. A new session needs neither.

### How do I remove it?

`/fable-setup remove` deletes the config, the rules file, and the CLAUDE.md section. Then `claude plugin uninstall oh-my-fable@oh-my-fable`. To pause instead, write `{"enabled": false}` to `~/.claude/oh-my-fable.json`.

## Check that it is on

### What is in effect right now?

`/fable-status`. One table with the plugin version, where the rules live, this session's mode (with the auto-detection basis), effort, the rules file version, and CLAUDE.md conflicts; it changes nothing.

The same information appears as a one-line notice when a new session opens (it does not enter Claude's context).

### `/plugin` lists oh-my-fable under "Not used recently".

That header appears after 14 days and 10 sessions without a tracked use, and the docs' list of what counts as use does not include hooks (plugins measure doc), so it can appear when you have not typed `/fable` or another of its commands lately. The rules hook still runs in every session; `/fable-status` shows it.

## What you see on screen

### What is the request card, and how do I turn it off?

It draws the improved request that `/fable` shows as a card in the transcript. It is a Claude Code [mod](https://code.claude.com/docs/en/plugins/mods/overview) (plugin code that runs inside Claude Code), and redrawing that one block is all it does (`claude plugin validate` lists a single call, `$.ui.resolve`).

What Claude reads and what the transcript stores stay the same; while the reply streams you see the code block, and it turns into the card when that block of the reply is complete.

In the terminal it draws on Claude Code 2.1.287 or newer and was checked on 2.1.292. The desktop app draws it too (checked on an app that embeds Claude Code 2.1.289); the VS Code extension panel, `claude -p`, and versions before 2.1.287 keep showing the code block.

Claude Code 2.1.290 fixed a stall when a mod draws multi-line text in a non-Latin script, and 2.1.295 fixed the last known card issue, so 2.1.295 or newer is recommended.

To turn it off, switch off `Improved request card` in `/config` (it applies at once, no restart needed), or go to `/plugin` → oh-my-fable → Configure options.

To install with it off: `claude plugin install oh-my-fable@oh-my-fable --config card=false`.

### How do I turn off the line shown at every session start?

Turn off `Status line at session start` for oh-my-fable in `/config`. The welcome line on the first session after install, the one line after an update, and notices that need action still show.

## Rules and settings

### My CLAUDE.md already has similar rules.

`/fable-setup` lists them. Same meaning: "already covered". Opposite meaning (no formatting, hold findings until the end): it proposes replacement text. You make the edit yourself, because Claude Code blocks an AI from editing its own CLAUDE.md.

### I want the rules somewhere other than CLAUDE.md.

By default the rules live only inside the plugin and the hook injects them per session, so neither CLAUDE.md nor a rules file is created. The recommended setup is a rules file (`/fable-setup rules-file`): Claude Code's hooks doc prefers files over hook text for rules that never change, and agent teams load it.

A CLAUDE.md section is the third option. The comparison table is under [Changing where the rules live](setup.en.md#changing-where-the-rules-live).

### How is `/fable-audit` different from `/doctor prompt-audit`?

They answer opposite questions. `/fable-audit` finds which prompting-guide sections your rules are missing (gaps to add). Claude Code's `/doctor prompt-audit` (2.1.283 or later) finds what in your rules is dated, stale or contradictory (text to remove).

Neither changes anything on its own; run both when tidying a setup.

## Models

### Does it work on Opus 5.5?

Yes. Opus 5.5 is now Claude Code's default model, so from 2.2.0 the plugin is built on both guides together. Finish-the-task, scope limits, and progress updates come from both guides saying the same thing, and the unattended "don't stop on a progress report" paragraph (block M) comes from the Opus 5.5 guide.

The formatting rule, targeted edits, and batched tool calls come from the Fable 5.1 guide, so they may matter less on Opus 5.5, but they do no harm. Same for Sonnet 5.5, Haiku 5.5, Opus 5 and Sonnet 5. Sonnet 5.5 and Haiku 5.5 also start at `medium` effort in Claude Code and ignore a top-level `effortLevel` in user settings, which the status line shows.

On Haiku 5.5, `/fable` uses that guide's own search text instead of block H. Fable 5.2 starts at `medium` too and ignores the same key; from its guide the plugin adds block O in unattended sessions and subagents, and `/fable` attaches blocks P and Q by request.

## Other environments

### Headless-only environments where the plugin cannot be installed (separate CLAUDE_CONFIG_DIR, CI)?

Copy `hooks/rules-file-unattended.md` to that environment's `rules/oh-my-fable.md` (or symlink it to a checkout of this repo; keep the link in that user-level `rules/` folder, because a link inside a project's `.claude/rules/` that points outside the project waits for an approval, per the memory doc). The full unattended rules load without the plugin; the hook treats the file as user-managed and stays silent.

### Cloud sessions and routines?

Plugins enabled on your machine do not run in cloud sessions (claude.ai/code) or routines; only what is committed to the repository travels with the clone, `.claude/rules/` included (cloud environments doc).

Commit `hooks/rules-file-unattended.md` as `.claude/rules/oh-my-fable.md`: routines run without approval prompts, so the unattended variant fits. `/fable` and the request card are not available there.

### Do subagents with `omitClaudeMd: true` get the rules?

Not from a rules file or CLAUDE.md. Measured on Claude Code 2.1.284: a custom subagent with `omitClaudeMd: true` saw neither `~/.claude/rules/*.md`, the project's `.claude/rules/*.md`, nor CLAUDE.md, while the same agent without the flag saw all three.

The hook cannot tell such an agent apart (the SubagentStart input carries only its type), so under hook-only delivery it still gets the short version like every subagent, and under the other deliveries it gets nothing from this plugin.

That fits the flag's purpose, a lean context; put a rule that must reach it into its own prompt.

### I use the API or the Agent SDK directly.

`/fable-setup` needs the question tool, so only `/fable-setup auto` works under the SDK. The simplest route is to paste `hooks/always-on.md` into your system prompt. The layer 3 API items (thinking.display and so on) are settings on your side.

---

Other pages: [How it works](how-it-works.en.md) · [Setup and environments](setup.en.md) · [Symptom to fix](symptoms.en.md) · [Layout and contributing](layout.en.md)
