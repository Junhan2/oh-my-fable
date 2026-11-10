# Symptom to fix

[← oh-my-fable](../README.en.md) · [한국어](symptoms.md) · English · [中文](symptoms.zh.md)

| Symptom | Fix |
|---|---|
| Stops with "Shall I?" | blocks A and M (automatic in unattended sessions; `/fable-setup unattended` to always include them) |
| An unattended run ends its turn right after a progress update | block M (automatic in unattended sessions) |
| At `xhigh`/`max`, keeps reviewing and hardening after the work is done, or launches reviewer subagents | block N (automatic when the session starts at `xhigh`/`max`), or run routine work at `high` or below |
| Stops at a timeout or a failing tool instead of trying another way | block O (automatic in unattended sessions and subagents) |
| The final report is hard to follow for someone who did not watch the work | block P (`/fable` attaches it to report and handoff requests) |
| Writes similar code again instead of merging what exists | block Q, only where the structure may change |
| Asks for approvals it doesn't need, or holds back routine work | name the exact actions in approval rules and write the exception into a "never" rule (`/fable-audit` notes N19 and N20) |
| Changes things you did not ask for | block D |
| Does narrower or broader work than asked | block L |
| Silent for minutes | delete old rule, then block E; thinking.display over the API |
| Rewrites the whole file for one line | block C |
| Does not search for fresh information | raise effort or block H |
| Dense prose | `Please remove all mannered prose.` |
| No lists where lists belong | replace anti-formatting rules with block I |
| Source text copied into summaries unmarked | block J example |
| Benign code request refused | ask "Are there any bugs?"; link docs for obscure languages |

Full block texts: [`skills/fable/references/prompt-blocks.md`](https://github.com/Junhan2/oh-my-fable/blob/main/skills/fable/references/prompt-blocks.md)

---

Other pages: [How it works](how-it-works.en.md) · [Setup and environments](setup.en.md) · [FAQ](faq.en.md) · [Layout and contributing](layout.en.md)
