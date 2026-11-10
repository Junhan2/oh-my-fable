# Setup and environments

[← oh-my-fable](../README.en.md) · [한국어](setup.md) · English · [中文](setup.zh.md)

The defaults work. This page is for a special environment or for changing a default.

## By environment

| Environment | What to do |
|---|---|
| Terminal · desktop app · IDE extension | install only. Detected as interactive |
| `claude -p` · Agent SDK · agent harnesses (Buzz etc.) | install only. Detected as unattended, adding the three unattended paragraphs ("not watching", "don't stop on a progress report", "work through ordinary obstacles"). Exception: `claude -p --bare` skips hooks, plugins and CLAUDE.md, and the headless doc says it will become the default for `-p` in a future release; pass the rules with `--append-system-prompt-file hooks/rules-file-unattended.md` (base rules plus the three unattended paragraphs) |
| Headless-only environments where the plugin cannot be installed (separate `CLAUDE_CONFIG_DIR`, CI) | copy `hooks/rules-file-unattended.md` to that environment's `rules/oh-my-fable.md` ([FAQ](faq.en.md)) |
| Cowork | the terminal install is not used there. Enable the plugin in your claude.ai account settings |
| Cloud sessions (claude.ai/code) · routines | plugins enabled on your machine do not run there ([FAQ](faq.en.md)). Commit `hooks/rules-file-unattended.md` to the repository as `.claude/rules/oh-my-fable.md` |

## Versions and updates

- **Requirements** Claude Code 2.1.258 or newer (2.5.0 was installed on 2.1.258, 2.1.286 and 2.1.292, and the rules loaded on each). Older versions are not supported: an old Claude Code (checked on 2.1.69) can neither install nor load this plugin, so run `claude update`. **Windows needs Git for Windows (Git Bash)**: the hook runs through bash. A hook error right after install means this. The request card draws on 2.1.287 or newer (2.1.295 or newer recommended, which carries the fixes for its known issues: not loading in the first session after an upgrade, a stall on multi-line non-Latin text, being unloaded by another large plugin); a lower version where mods are off (checked on 2.1.258) keeps showing the plain code block. For headless sessions 2.1.296 or newer is recommended (it fixes a case where a plugin's SessionStart hook was skipped there).
- **Auto-update** Claude Code keeps auto-update off for third-party marketplaces. To receive new versions automatically, once: `/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update. Or run `claude plugin update oh-my-fable@oh-my-fable` now and then.

## Changing where the rules live

**Three places for the rules** (question 1)

| | Rules file + hook (recommended) | Hook only (zero-setup default) | CLAUDE.md section |
|---|---|---|---|
| Where | base rules in `~/.claude/rules/oh-my-fable.md` (auto-loaded), the unattended paragraphs and block N added by the hook per session | inside the plugin (`hooks/always-on.md`) | `<!-- oh-my-fable:start v3 -->` section in your CLAUDE.md |
| File edits | one rules file, CLAUDE.md untouched | none | edits CLAUDE.md, needs approval (not in auto mode) |
| Interactive/unattended auto-detect | yes | yes | no (static) |
| Reaches subagents | yes (regular subagents via the file, Explore and Plan via the hook's short version) | yes (the SubagentStart hook sends the short version to every subagent) | yes (Explore and Plan via the hook) |
| Reaches agent teams | yes (per the docs, teammates load rules files) | in-process teammates yes (per the hooks doc, SubagentStart runs for each of their messages); split-pane teammates unverified | yes |
| After a plugin update | a stale rules file is flagged at session start; `/fable-setup refresh` updates it | always current | a stale section is flagged at session start; `/fable-setup claude-md` replaces it |
| Removal | delete the file + uninstall | uninstall or `{"enabled": false}` | delete the section |

**Why the rules file is recommended.** Claude Code's [hooks doc](https://code.claude.com/docs/en/hooks) says "for instructions that never change, prefer CLAUDE.md" (rules files load the same way), and warns that hook text framed as out-of-band system commands can trigger Claude's prompt-injection defenses. The hook-only default stays because a plugin cannot write files on install; the hook's text opens with a factual lead-in ("The user installed oh-my-fable; these are the user's standing working rules.") for that reason. The trade-off of a rules file is that it is a copy: a stale one is flagged at session start and `/fable-setup refresh` updates it.

Only one is active at a time. If a CLAUDE.md section or a hand-made rules file exists, the hook goes silent by itself (no double injection). Since 1.7 the hook takes care of subagents itself: on Claude Code's `SubagentStart` event it injects a short version (`hooks/subagent.md`: scope limits, targeted edits, batched calls, finish the task, "report blockers instead of asking"). Explore and Plan subagents read neither CLAUDE.md nor rules files, so they get this short version under every delivery. Forks (the `fork` subagent type) are skipped: they inherit the whole conversation, rules included.

- **The mode is auto-detected by default.** A session opened in the terminal or IDE runs interactive; one started headless (`claude -p`), through the Agent SDK, or by an agent harness runs unattended, decided per session from the `CLAUDE_CODE_ENTRYPOINT` value Claude Code sets. Mixing interactive and headless use needs no switching. To pin one mode, pick "Interactive" or "Unattended" in question 2. Unattended adds the "the user is not watching" paragraph and the "don't stop on a progress report" paragraph, and can only be set in the global config, never by a config file inside a repository, so a cloned repo cannot switch your agent to unattended. Auto-detection works with both hook-based deliveries; only the CLAUDE.md section is static text, so pick one mode for that.
- **Effort**: this plugin no longer sets it. Opus 5.5, Sonnet 5.5 and Haiku 5.5 default to `medium` in Claude Code (their guides' starting point for agentic work), and so does Fable 5.2 (its guide suggests `high` for hard or long unattended work); Fable 5.1 defaults to `high`. To save a value per model, type `/effort <level>` in a session on that model and press Enter; `s` saves for this session only. `/fable-status` shows the current value and where it comes from.

---

Other pages: [How it works](how-it-works.en.md) · [Symptom to fix](symptoms.en.md) · [FAQ](faq.en.md) · [Layout and contributing](layout.en.md)
