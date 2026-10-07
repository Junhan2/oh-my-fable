<div align="center" markdown="1">

# oh-my-fable

**Anthropic 프롬프팅 가이드(Opus 5.5, Fable 5.1)의 작업 규칙을 Claude Code에 상시 적용하는 법. 설치만 하면 알아서: 터미널이든 헤드리스든 서브에이전트든, 세션마다 맞는 규칙이 들어갑니다.**

Opus 5.5(지금 Claude Code의 기본 모델)와 Fable 5.1 기준이며, Sonnet 5.5(Claude Code 기본 effort가 Opus 5.5처럼 `medium`)·Opus 5·Sonnet 5에서도 그대로 씁니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-2e7d32.svg)](https://github.com/Junhan2/oh-my-fable)
[![GitHub stars](https://img.shields.io/github/stars/Junhan2/oh-my-fable?style=flat)](https://github.com/Junhan2/oh-my-fable/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/Junhan2/oh-my-fable)](https://github.com/Junhan2/oh-my-fable/commits/main)

한국어 · [English](README.en.md) · [中文](README.zh.md)

</div>

---

**대충 한 줄로 시켜도, 제대로 된 요청으로 바뀌어 실행됩니다.**

👤 **당신이 치는 것**
```
/fable 로그인 버튼 눌러도 아무 반응 없어 고쳐줘
```
🤖 **Claude가 실제로 받는 요청** (대화 맥락에서 자동으로 채워짐)
```
목표: 로그인 버튼을 누르면 /api/login 이 호출되고, 성공하면 /dashboard 로 이동하게 한다
맥락: src/components/LoginButton.tsx, 콘솔 오류 "TypeError: onSubmit is not a function", 어제 인증 방식을 바꾼 커밋 이후 발생
범위: 이 버튼과 그 핸들러만. 옆의 회원가입 폼이나 다른 오류는 고치지 말고 후속 과제로 보고
완료 기준: 실제 클릭을 재현해 /dashboard 이동 확인, 콘솔 오류 0, 변경 파일 목록 첨부
```

**설치만 하면, 나머지는 자동입니다.**

- **사용 형태를 세션마다 알아서 판정** · 터미널·IDE면 대화형, `claude -p`·Agent SDK·에이전트 하네스면 무인으로 감지해 "사용자가 지켜보고 있지 않다" 문단과 "중간 보고로 멈추지 말라" 문단을 그때만 넣습니다. 섞어 써도 바꿀 것이 없습니다.
- **서브에이전트까지 자동** · Agent 도구로 띄운 서브에이전트(규칙 파일을 안 읽는 Explore·Plan 포함)에 짧은 판을 따로 넣습니다.
- **파일을 만들지 않습니다** · CLAUDE.md도 규칙 파일도 건드리지 않고, 훅이 세션마다 넣습니다. 그래서 갱신은 플러그인만 올리면 되고 제거하면 흔적이 없습니다.
- **질문 없음** · 설정은 선택 사항입니다. 확인할 것은 설치 승인 하나뿐입니다. 한 번은 `/fable-setup rules-file`을 권합니다. 기본 규칙을 규칙 파일로 두는 방식이고, Claude Code 훅 문서도 바뀌지 않는 규칙은 훅 텍스트보다 파일에 두라고 합니다.

Anthropic 공식 문서 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1), [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5), 그리고 Opus 5.5 가이드가 출발점으로 지정한 [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)의 처방을 훅 하나와 스킬 네 개에 담았습니다. 문구는 원문을 거의 그대로 씁니다.

> **어느 모델용인가요?** **Opus 5.5**(지금 Claude Code의 기본 모델)와 **Fable 5.1** 둘 다입니다. 끝까지 하기·범위 제한·진행 보고 규칙은 두 모델의 공식 가이드가 같은 말을 하고, 무인 세션에만 붙는 "중간 보고로 멈추지 말라" 문단은 Opus 5.5 가이드에서 왔습니다. 부분 편집·도구 일괄 호출·서식 규칙은 Fable 5.1 가이드에만 있는 처방이지만 다른 모델에 있어도 해가 되지 않습니다. 네 칸 요청 틀(목표·맥락·범위·완료 기준)은 모델이 무엇이든 되묻기와 빗나간 결과를 줄입니다. Sonnet 5.5(Claude Code 기본 effort `medium`, Opus 5.5와 같음), Opus 5, Sonnet 5에서도 그대로 씁니다. 세션이 `xhigh`나 `max` effort로 시작하면 훅이 Sonnet 5.5 가이드의 블록 N도 넣습니다.

## 목차

- [무엇을 하나](#무엇을-하나)
- [설치: 한마디](#설치-한마디)
- [사용법: 평소처럼](#사용법-평소처럼)
- [초보자 흐름](#초보자-흐름)
- [작동 원리: 세 층](#작동-원리-세-층)
- [1층 · 매번 요청에](#1층--매번-요청에)
- [2층 · 상시 규칙](#2층--상시-규칙)
- [3층 · 설정값](#3층--설정값)
- [증상별 처방](#증상별-처방)
- [FAQ](#faq)
- [구성](#구성)
- [기여와 라이선스](#기여와-라이선스)

## 무엇을 하나

| 구성 | 언제 | 하는 일 |
|---|---|---|
| **상시 규칙** | 설치하면 자동, 파일 없음 | 세션이 시작될 때마다 훅이 공식 가이드의 상시 규칙(자율 진행, 범위 제한, 시킨 범위 그대로 끝내기, 부분 편집, 진행 보고, 서식, 도구 일괄 호출)을 영어 원문 그대로 넣습니다. 헤드리스·SDK 세션이면 "사용자가 지켜보고 있지 않다" 문단과 "중간 보고로 멈추지 말라" 문단(Opus 5.5 가이드)을 자동으로 더하고, `xhigh`/`max` effort 세션에는 "확인이 통과하면 멈춰라" 문단(블록 N, Sonnet 5.5 가이드)을 더하며, Agent 도구로 띄운 서브에이전트에는 짧은 판을 따로 넣습니다. 규칙 파일도 CLAUDE.md도 만들지 않습니다 |
| `/fable` | 요청이 짧거나 막연할 때 | 목표·맥락·범위·완료 기준을 채운 요청을 보여 주고 바로 실행합니다. `프롬프트만`을 붙이면 보여 주기만 합니다 |
| **요청 카드** | 터미널(Claude Code 2.1.287 이상)과 데스크톱 앱에서 자동 | `/fable`이 보여 주는 개선된 요청을 대화 속 카드(색 띠 제목, 항목별 정리)로 그립니다. 화면에 그리는 일만 하며 Claude가 읽는 내용은 그대로입니다. 끄려면 `/config`의 `Improved request card` ([FAQ](#faq)) |
| `/fable-status` | 지금 뭐가 켜져 있는지 궁금할 때 | 플러그인 버전, 규칙 위치, 감지된 모드, effort(값과 출처), 규칙 파일이 최신인지, CLAUDE.md 충돌 수를 표 하나로 보여 줍니다. 아무것도 쓰지 않습니다 |
| `/fable-audit` | 내 규칙에 가이드의 무엇이 빠졌는지 볼 때 | CLAUDE.md·규칙 파일·에이전트 프롬프트를 가이드 16개 절과 대조해 빠진 것·가이드와 반대로 가는 것·플러그인이 이미 덮는 것을 표로 보여 주고, Opus 5/5.5·Sonnet 5.5 가이드의 모델별 주의점은 점수 없이 따로 알려 줍니다. 읽기만 하고 아무것도 고치지 않습니다. 반대 방향의 일, 즉 낡았거나 틀렸거나 서로 부딪혀 지울 문구를 찾는 일은 Claude Code의 `/doctor prompt-audit`가 맡습니다 |
| `/fable-setup` | 선택 사항, 한 번은 권장 | 규칙을 규칙 파일로(권장, 에이전트 팀도 이 방식) 또는 CLAUDE.md 구간으로 옮기기, 모드를 한쪽으로 고정, effort가 어디서 오는지 안내, 기존 CLAUDE.md 규칙과의 충돌 점검 |

Fable 5.1은 긴 작업을 혼자 끝까지 해내는 능력이 커진 대신 버릇이 바뀌었습니다. 작업 중 말수가 줄고, 한 번에 도구 하나씩만 부르고, 작은 수정에도 파일을 통째로 다시 쓰고, low effort에서는 검색 대신 기억으로 답합니다. Opus 5.5는 긴 무인 작업 중간에 진행 보고만 하고 턴을 끝내 작업이 거기서 멈추는 버릇이 있습니다(공식 가이드 "Unattended agentic runs"). 공식 가이드는 이런 변화에 대한 증상별 처방이고, 이 플러그인은 그 처방을 자동으로 적용합니다.

## 설치: 한마디

Claude Code에 이렇게만 말하세요.

```
https://github.com/Junhan2/oh-my-fable 설치해줘
```

Claude가 설치하면 끝입니다. 질문도, 설정 파일도 없습니다. 다음에 Claude Code를 열면 자동으로 적용됩니다. 지금 이 세션에서 바로 쓰고 싶으면 `/reload-plugins`(방금 설치한 플러그인 로드) 다음 `/clear`(규칙 주입) 를 한 줄씩.

<details>
<summary>수동 설치</summary>

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```
새 세션을 열거나 `/reload-plugins` 후 `/clear`. 설정할 것은 없습니다. 기본값을 바꾸고 싶을 때만 `/fable-setup`.

> **요구 사항** Claude Code 2.1.258 이상(2.5.0은 2.1.258·2.1.286·2.1.292에서 설치와 규칙 주입을 확인). 더 낮은 버전은 지원하지 않습니다: 오래된 Claude Code(2.1.69에서 확인)는 이 플러그인을 설치하거나 읽지 못하니 `claude update`로 올리세요. **Windows는 Git for Windows(Git Bash) 필수**: 훅이 bash로 실행됩니다. 설치 뒤 훅 오류가 뜨면 이 문제입니다. 요청 카드는 2.1.287 이상에서 그려지고(2.1.290 이상 권장), mod가 꺼져 있는 낮은 버전(2.1.258에서 확인)에서는 지금처럼 코드 블록으로 보입니다.
>
> **자동 갱신** 서드파티 마켓플레이스는 Claude Code가 자동 갱신을 기본으로 꺼 둡니다. 새 버전을 자동으로 받으려면 한 번만: `/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update. 아니면 가끔 `claude plugin update oh-my-fable@oh-my-fable`.

</details>

**60초 경로: 내 환경에서는?**

| 환경 | 할 일 |
|---|---|
| 터미널 · 데스크톱 앱 · IDE 확장 | 설치만. 대화형으로 자동 감지 |
| `claude -p` · Agent SDK · 에이전트 하네스(Buzz 등) | 설치만. 무인으로 자동 감지해 무인 문단 두 개("지켜보고 있지 않다", "중간 보고로 멈추지 말라") 추가. 단 `claude -p --bare`는 훅·플러그인·CLAUDE.md를 전부 건너뛰므로 `hooks/always-on.md`를 시스템 프롬프트에 직접 붙이세요 |
| 플러그인을 못 까는 헤드리스 전용 환경 (별도 `CLAUDE_CONFIG_DIR`, CI) | `hooks/rules-file-unattended.md`를 그 환경의 `rules/oh-my-fable.md`로 복사 ([FAQ](#faq)) |
| Cowork · claude.ai/code | 터미널 설치본은 쓰이지 않습니다. claude.ai 계정 설정에서 플러그인을 켜세요 |

## 사용법: 평소처럼

그냥 평소처럼 요청하면 됩니다. 상시 규칙은 이미 켜져 있습니다. 요청이 짧거나 막연하면 앞에 `/fable`을 붙이세요.

```
/fable 이거 좀 고쳐줘
```

목표·맥락·범위·완료 기준을 채운 요청을 보여 주고 바로 실행합니다. 보기만 하려면 뒤에 `프롬프트만`.

## 초보자 흐름

| 순서 | 누가 | 무엇 |
|---|---|---|
| 1 | **사용자** | `https://github.com/Junhan2/oh-my-fable 설치해줘` |
| 2 | Claude | 마켓플레이스 등록, 플러그인 설치, "다음 세션부터 자동 적용. 지금 쓰려면 `/reload-plugins` 다음 `/clear`" 안내 |
| 3 | 사용자 | 이후 평소처럼. 막연한 요청은 `/fable 이거 좀 고쳐줘`, 궁금하면 `/fable-status` |

<details>
<summary>선택 사항: 규칙 위치 바꾸기 (`/fable-setup`)</summary>

**규칙 위치 세 가지** (첫 질문)

| | 규칙 파일 + 훅 (권장) | 훅만 (설정이 없을 때의 기본) | CLAUDE.md 구간 |
|---|---|---|---|
| 어디에 | 기본 규칙은 `~/.claude/rules/oh-my-fable.md`(자동 로드), 무인 문단과 블록 N은 훅이 세션마다 | 플러그인 안 (`hooks/always-on.md`) | 내 CLAUDE.md 안 `<!-- oh-my-fable:start v2 -->` 구간 |
| 파일 수정 | 규칙 파일 1개, CLAUDE.md 무관 | 없음 | CLAUDE.md 편집, 승인 필요(auto 모드 불가) |
| 대화형/무인 자동 감지 | 예 | 예 | 아니요(고정) |
| 서브에이전트에도 적용 | 예 (일반 서브에이전트는 파일, Explore·Plan은 훅의 짧은 판) | 예 (SubagentStart 훅이 짧은 판을 모든 서브에이전트에) | 예 (Explore·Plan은 훅의 짧은 판) |
| 에이전트 팀에도 적용 | 예 (문서상 팀원은 규칙 파일을 로드) | 미검증 | 예 |
| 플러그인 갱신 시 | 규칙 파일이 오래되면 세션 시작 때 알려 줌, `/fable-setup refresh` 로 갱신 | 항상 최신 | 구간을 다시 붙여 넣기 |
| 제거 | 파일 삭제 + 플러그인 삭제 | 플러그인 삭제 또는 `{"enabled": false}` | 구간 삭제 |

**규칙 파일을 권하는 이유.** Claude Code [훅 문서](https://code.claude.com/docs/en/hooks)는 "바뀌지 않는 지시는 CLAUDE.md에 두라(for instructions that never change, prefer CLAUDE.md)"고 하고(규칙 파일도 같은 방식으로 로드됩니다), 시스템 명령처럼 쓴 훅 텍스트는 Claude의 프롬프트 주입 방어를 건드릴 수 있다고 경고합니다. 그래도 기본값이 훅인 이유는 플러그인이 설치 때 파일을 쓸 수 없기 때문이고, 같은 이유로 훅 텍스트는 사실을 말하는 한 줄("The user installed oh-my-fable; these are the user's standing working rules.")로 시작합니다. 규칙 파일의 단점은 복사본이라는 점입니다. 오래되면 세션 시작 때 알려 주고 `/fable-setup refresh`로 갱신합니다.

셋 중 하나만 활성화됩니다. CLAUDE.md에 구간이 있거나 사용자가 직접 만든 규칙 파일이 있으면 훅은 스스로 조용해집니다(이중 주입 없음). 서브에이전트는 1.7부터 훅이 직접 챙깁니다: Claude Code의 `SubagentStart` 이벤트에 짧은 판(`hooks/subagent.md`, 범위 제한·부분 편집·일괄 호출·끝까지 하기·"묻지 말고 막힌 점을 보고")을 넣습니다. Explore·Plan 서브에이전트는 CLAUDE.md도 규칙 파일도 읽지 않으므로 어떤 방식에서든 이 짧은 판을 받습니다.

- **사용 방식은 기본이 자동 감지**입니다. 터미널이나 IDE에서 열면 대화형, 헤드리스(`claude -p`)·Agent SDK·에이전트 하네스에서 열면 무인으로 세션마다 알아서 정합니다(Claude Code가 넣어 주는 `CLAUDE_CODE_ENTRYPOINT` 값 기준). 대화형과 무인을 섞어 써도 따로 바꿀 것이 없습니다. 항상 한쪽으로 고정하려면 질문에서 "대화형" 또는 "무인"을 고르세요. 무인은 "사용자가 지켜보고 있지 않다" 문단과 "중간 보고로 멈추지 말라" 문단을 추가하며, 글로벌 설정에서만 켜지고 저장소 안의 설정 파일로는 켤 수 없습니다(클론한 저장소가 에이전트를 무인으로 바꾸는 것을 막기 위해). 자동 감지는 훅이 관여하는 두 방식에서 되고, CLAUDE.md 구간만 고정 텍스트라 한쪽을 골라야 합니다.
- **effort**는 이 플러그인이 쓰지 않습니다. Opus 5.5와 Sonnet 5.5는 Claude Code에서 기본 `medium`(두 가이드가 에이전트 작업의 출발점으로 꼽는 값), Fable 5.1은 기본 `high`입니다. 모델별로 저장하려면 그 모델로 연 세션에서 `/effort <단계>` 후 Enter, 이번 세션만이면 `s`. `/fable-status`가 지금 값과 출처를 보여 줍니다.

</details>

<details>
<summary>AI가 따르는 절차 (Claude가 이 README를 읽고 실행)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. `~/.claude/plugins/installed_plugins.json` 에서 `oh-my-fable@oh-my-fable` 의 `installPath` 를 읽는다
4. 설치가 확인되면 사용자에게 이렇게만 안내한다: "설치가 끝났습니다. 다음 세션부터 자동 적용됩니다. 지금 바로 쓰려면 `/reload-plugins` 를 입력하고 Enter, 그다음 `/clear` 를 입력하고 Enter 하세요(한 줄에 하나씩). 막연한 요청은 `/fable <요청>` 으로 보내세요."
5. 그 밖의 설명은 하지 않고 `/fable-setup` 도 실행하지 않는다(선택 사항이며 기본값은 설정 없이 동작). 둘 다 필요한 이유: `/reload-plugins` 는 방금 설치한 플러그인(훅·스킬)을 이 세션에 로드하고, 규칙 주입은 세션 시작·`/clear`·압축 때만 일어난다. 설치 출력에 `userConfig option not yet set` 줄이 보여도 따로 설정하지 않는다(요청 카드는 기본으로 켜져 있고, 끄는 방법은 FAQ에 있다)

</details>

## 작동 원리: 세 층

가이드의 처방은 적용 방법이 다른 세 층으로 나뉩니다.

| 층 | 무엇 | 어떻게 적용 |
|---|---|---|
| **1. 매번 요청에** | 목표·맥락·범위·완료 기준, 진단만 하라는 예외, 시사성 질문의 검색 요청, 장문 안내문 | `/fable`이 채움 |
| **2. 상시 규칙** | 자율 진행, 범위·테스트 제한, 시킨 범위 그대로 끝내기, 부분 편집, 진행 보고, 서식 규칙, 도구 일괄 호출, 무인 세션의 중간 멈춤 방지 | 플러그인 훅이 세션 시작 때 자동 주입 |
| **3. 설정값** | 대화형/무인 모드, effort(모델별 저장), thinking.display, 대화 이력 규칙, 서브에이전트, 비전 crop | 모드는 자동 감지. 바꾸고 싶을 때만 `/fable-setup`이 모드를 쓰고, effort는 `/effort`로 안내하며, 나머지는 점검표로 알려 줌 |

## 1층 · 매번 요청에

좋은 요청은 네 칸입니다.

| 칸 | 나쁜 예 | 좋은 예 |
|---|---|---|
| 목표 | 보고서 좀 | 임원 회의용 1쪽 요약, 결론이 맨 위에 |
| 맥락 | 아까 그거 | `2026-08-sales.xlsx` 시트 "raw" |
| 범위 | (없음) | 표만. 원본 수정 금지. 이상값은 고치지 말고 메모 |
| 완료 기준 | (없음) | 합계가 시트 "summary" 총액과 일치. 일치 여부를 숫자로 보고 |

요청에 따라 덧붙이는 것:

- **문제를 설명만 할 때** · "진단만 하고 고치지 마". 가이드의 명시적 예외.
- **최신 정보가 필요할 때** · effort를 high 이상으로 두거나 "사용자가 쓴 이름 그대로 한 번은 검색해" (블록 H).
- **effort** · Opus 5.5와 Sonnet 5.5는 `medium`이 기본이자 가이드의 출발점, Fable 5.1은 `high`가 기본. 어려운 작업만 그 세션에서 올리기(`/effort high` 다음 `s`). `low`는 검색을 건너뛸 수 있음. `xhigh`/`max`는 생각이 길어지고(Opus 5.5는 같은 단계에서 Opus 5보다 더 오래 생각함) 긴 문서는 초안을 두 번 써서 느려지니 장문 안내문(블록 G)을 붙이고 `max_tokens`를 넉넉히.
- **글이 빽빽할 때** · `Please remove all mannered prose.`
- **자료 요약** · 올바른 답 예시 1건(블록 J)을 같이 줌.

## 2층 · 상시 규칙

플러그인의 SessionStart 훅이 세션마다 아래 블록을 영어 원문 그대로 불러옵니다(파일 `hooks/always-on.md`). CLAUDE.md는 수정하지 않으며, 사용자 언어와 무관하게 영어입니다. 블록 A의 첫 문단("사용자가 지켜보고 있지 않다")과 블록 M("중간 보고로 멈추지 말라")은 헤드리스·SDK 세션에서만 자동으로 들어가고 터미널·IDE에서는 빠집니다. 항상 넣으려면 `/fable-setup unattended`. 블록 N은 세션이 `xhigh`나 `max` effort로 시작할 때만 들어갑니다(`claude -p`에서는 훅이 모델을 전달받지 못해 `CLAUDE_CODE_EFFORT_LEVEL`만 기준이 됩니다). 훅이 넣는 각 부분은 사실을 말하는 한 줄로 시작합니다(예: "This session was started headless (entrypoint sdk-cli); the user's standing rules for such sessions follow."). Claude Code 훅 문서가 훅 텍스트를 시스템 명령이 아닌 사실 문장으로 쓰라고 하기 때문입니다.

| 블록 | 한 줄 요지 | 주의 |
|---|---|---|
| **A** 자율 진행 | "사용자가 지켜보고 있지 않다. 되돌릴 수 있는 일은 묻지 말고 진행, 파괴적 행동만 멈춰라. 턴 끝에 마지막 문단이 계획이면 지금 실행하라" | 첫 문장이 효과의 대부분. 무인 세션에만 전체를, 대화형에는 자기 점검 문단만 |
| **M** 중간 보고로 멈추지 않기 | 할 일이 남았는데 턴을 끝내는 네 가지(다음 단계 예고로 끝내기, "원하시면 계속할게요", 막히지 않았는데 결정 목록 내밀기, 한 단계 마쳤다고 보고하며 멈추기)를 하지 말고, 보고와 권고는 다음 도구 호출과 같은 메시지에 | Opus 5.5 가이드 "Unattended agentic runs" 문단을 다듬은 것. 무인 세션에만(가이드: 사람이 지켜보는 대화에는 넣지 말 것). 위험한 행동의 확인은 그대로 |
| **D** 범위·테스트 | 시키지 않은 버그·개선은 고치지 말고 후속 과제로 보고. 테스트는 요청했거나 저장소 관례가 있을 때만 | 부탁한 것은 전부 완전히 |
| **L** 시킨 범위 그대로 | 시킨 범위 그대로, 일상적 판단은 스스로, 요청이 틀려 보이면 한 문장으로 말하고 그대로 진행, 막힌 부분만 빼고 나머지는 끝낸 뒤 뺀 것을 말하기 | Opus 5 가이드 원문에 Fable "Delivering work" 한 문장. 대화형·무인 모두 |
| **C** 부분 편집 | 결과가 같다면 파일을 통째로 다시 쓰지 말고 필요한 부분만 | |
| **E** 진행 보고 | 시작 한 줄, 중간 갱신, 끝에는 마지막 메시지만 봐도 되는 요약 | 먼저 "마지막에 한꺼번에 보고" 류 옛 지시를 삭제 |
| **I** 서식 규칙 | 내용이 다면적이면 목록, 요청하면 최소 서식, 대화체는 산문 | 옛 "서식 쓰지 마" 규칙은 삭제. 5.1은 이미 서식을 덜 씀 |
| **B** 도구 일괄 호출 | 필요한 것을 먼저 나열하고 서로 독립인 것은 한 번에 요청 | |
| **N** 확인이 통과하면 멈추기 | 부탁한 일이 끝나고 확인이 통과하면 멈추고 보고. 스스로 검토·보강을 몇 차례 더 돌리지 않고, 검토를 부탁받지 않았으면 검토용 서브에이전트도 띄우지 않으며, 더 깊은 검토가 필요해 보이면 끝에 말하기 | Sonnet 5.5 가이드에서 옴. `xhigh`/`max` effort 세션에만. 가이드의 시험(Sonnet 5.5, `max`)에서 검토용 서브에이전트가 사라지고 세션 비용이 약 3분의 1 줄었으며 품질 변화는 없었음 |

## 3층 · 설정값

- 모드 · `~/.claude/oh-my-fable.json` 의 `{"enabled": true, "mode": "interactive" | "unattended"}`. 프로젝트의 `.claude/oh-my-fable.json` 이 있으면 그것이 우선. `/fable-setup` 이 대신 써 줍니다.
- effort · `/effort <단계>` 후 Enter가 settings.json의 `modelSettings.<모델>.effortLevel`에 모델별로 저장합니다. 옛 전역 `effortLevel`은 Opus 5.5와 Sonnet 5.5에는 적용되지 않습니다. 환경 변수 `CLAUDE_CODE_EFFORT_LEVEL`이 있으면 그것이 이기니 모델별 값을 쓰려면 환경 변수를 비울 것. `maxEffortLevel`(전역 또는 모델별)이 있으면 어느 값이든 그 상한으로 깎이고, `/fable-status`가 깎인 값을 보여 줍니다. 기본값은 Opus 5.5·Sonnet 5.5 `medium`, 그 밖의 모델 `high`(Opus 4.7은 `xhigh`). 모델마다 단계의 실제 사고량이 달라 다른 모델의 값을 그대로 옮기지 말 것.
- API 직접 연동 · `thinking.display: "updates"`를 켜야 진행 메모가 화면에 옴. 대화 이력은 덧붙이기만(thinking 블록 포함), 턴마다 넣는 알림은 turn-scoped system message로. 압축은 서버 압축 또는 블록 K.
- 서브에이전트 · 시작 도구는 즉시 반환, 결과는 나중 메시지로. Claude Code 서브에이전트는 세션의 effort를 그대로 물려받으니, 고정하려면 에이전트 파일 머리말(frontmatter)에 `effort:`.
- 비전 · 차트·표는 crop-and-zoom 도구를 붙이면 대부분의 이득.
- 거절(`stop_reason: "refusal"`) 처리 · "컴파일 되나요?" 대신 "버그 있나요?"로 묻기.

## 증상별 처방

| 증상 | 처방 |
|---|---|
| "할까요?" 하고 멈춤 | 블록 A·M (무인 세션이면 자동, 항상 넣으려면 `/fable-setup unattended`) |
| 무인 실행이 진행 보고만 하고 턴을 끝냄 | 블록 M (무인 세션이면 자동) |
| `xhigh`/`max`에서 일이 끝난 뒤에도 검토·보강을 계속하거나 검토용 서브에이전트를 띄움 | 블록 N (`xhigh`/`max`로 시작한 세션이면 자동), 또는 일상 작업은 `high` 이하로 |
| 시키지 않은 곳까지 고침 | 블록 D |
| 시킨 것보다 좁히거나 넓혀서 함 | 블록 L |
| 몇 분씩 조용함 | 옛 지시 삭제 후 블록 E, API면 thinking.display |
| 한 줄 고치는데 파일 전체 재작성 | 블록 C |
| 최신 정보인데 안 찾아봄 | effort 올리기 또는 블록 H |
| 문장이 빽빽함 | `Please remove all mannered prose.` |
| 목록이 있어야 할 곳에 없음 | 서식 금지 규칙을 블록 I로 교체 |
| 요약에 원문이 인용 표시 없이 섞임 | 블록 J 예시 |
| 평범한 코드 요청이 거절됨 | "버그 있나요?"로 묻기, 생소한 언어는 문서 링크 |

블록 원문 전체: [`skills/fable/references/prompt-blocks.md`](skills/fable/references/prompt-blocks.md)

## FAQ

**CLAUDE.md에 이미 비슷한 규칙이 있으면?**
`/fable-setup`이 표로 짚어 줍니다. 같은 뜻이면 "이미 있음", 반대 뜻(서식 금지, 마지막에 한꺼번에 보고)이면 바꿔 넣을 문장을 제안합니다. 실제 수정은 사용자가 합니다. Claude Code가 AI의 CLAUDE.md 자기 수정을 막기 때문입니다.

**규칙을 CLAUDE.md 말고 다른 곳에 두고 싶어요.**
기본값에서는 규칙이 플러그인 안에만 있고 훅이 세션마다 넣으므로 CLAUDE.md도 규칙 파일도 만들지 않습니다. 권장하는 설정은 규칙 파일(`/fable-setup rules-file`)입니다. Claude Code 훅 문서가 바뀌지 않는 규칙은 훅 텍스트보다 파일에 두라고 하고, 에이전트 팀도 이 파일을 읽습니다. CLAUDE.md 구간은 세 번째 선택지입니다. 비교표는 [초보자 흐름](#초보자-흐름)의 "선택 사항"에 있습니다.

**Opus 5.5에서도 되나요?**
됩니다. 지금 Claude Code의 기본 모델이 Opus 5.5라 2.2.0부터 두 모델을 함께 기준으로 삼습니다. 끝까지 하기·범위 제한·진행 보고는 두 가이드가 같은 말을 하고, 무인 세션의 "중간 보고로 멈추지 말라" 문단(블록 M)은 Opus 5.5 가이드에서 왔습니다. 서식 규칙·부분 편집·도구 일괄 호출은 Fable 5.1 가이드에서 온 것이라 Opus 5.5에서는 효과가 작을 수 있지만 해는 없습니다. Sonnet 5.5, Opus 5, Sonnet 5도 마찬가지입니다. Sonnet 5.5도 Claude Code에서 `medium` effort로 시작하고 사용자 설정의 전역 `effortLevel`을 무시하며, 상태 줄이 그 사실을 보여 줍니다.

**왜 지금 바로 쓰려면 `/reload-plugins` 다음 `/clear` 인가요?**
공식 문서 기준 두 명령은 하는 일이 다릅니다. `/reload-plugins`는 "플러그인, 스킬, 에이전트, 훅, MCP 서버를 재시작 없이 다시 로드"합니다([Plugins](https://code.claude.com/docs/en/plugins)). 규칙을 넣는 SessionStart 훅은 "새 세션(startup), 재개(resume), `/clear`, 압축(compact), 분기(fork)" 때만 실행됩니다([Hooks](https://code.claude.com/docs/en/hooks#sessionstart)). 즉 reload는 훅을 등록만 하고 실행하지 않으므로, 설치한 세션에서는 `/clear`로 한 번 실행시켜야 합니다. 새 세션을 열면 둘 다 필요 없습니다.

**지금 뭐가 켜져 있는지 보려면?**
`/fable-status`. 플러그인 버전, 규칙 위치, 이 세션의 모드(자동 감지 근거 포함), effort, 규칙 파일 버전, CLAUDE.md 충돌을 표 하나로 보여 주고 아무것도 바꾸지 않습니다. 새 세션을 열 때도 같은 내용이 한 줄로 화면에 뜹니다(Claude의 문맥에는 들어가지 않음).

**요청 카드가 뭔가요? 끄려면?**
`/fable`이 보여 주는 개선된 요청을 대화 속 카드로 그려 주는 기능입니다. Claude Code의 [mod](https://code.claude.com/docs/en/plugins/mods/overview)(Claude Code 안에서 실행되는 플러그인 코드)로 만들었고, 하는 일은 그 블록을 화면에 다시 그리는 것 하나입니다(`claude plugin validate`가 보여 주는 호출은 `$.ui.resolve`뿐). Claude가 읽는 내용과 저장되는 대화는 그대로이며, 글자가 나오는 동안에는 코드 블록으로 보이다가 그 답변 덩어리가 끝나면 카드로 바뀝니다. 터미널에서는 Claude Code 2.1.287 이상에서 그려지며 2.1.292에서 확인했습니다. 데스크톱 앱에서도 그려지며(Claude Code 2.1.289가 내장된 앱에서 확인), VS Code 확장 창·`claude -p`·2.1.287보다 낮은 버전에서는 지금처럼 코드 블록으로 보입니다. Claude Code 2.1.290에 mod가 라틴 문자가 아닌 여러 줄 글을 그릴 때 화면이 멈칫하던 문제의 수정이 들어갔으니 2.1.290 이상을 권합니다. 끄려면 `/config`에서 `Improved request card`를 끄거나(세션을 다시 시작하지 않아도 바로 적용됩니다) `/plugin` → oh-my-fable → Configure options. 설치할 때부터 끄려면 `claude plugin install oh-my-fable@oh-my-fable --config card=false`.

**되돌리려면?**
`/fable-setup remove` 가 설정 파일, 규칙 파일, CLAUDE.md 구간을 지웁니다. 그다음 `claude plugin uninstall oh-my-fable@oh-my-fable`. 잠시 끄기만 하려면 `~/.claude/oh-my-fable.json` 에 `{"enabled": false}`.

**플러그인을 못 까는 헤드리스 전용 환경(별도 CLAUDE_CONFIG_DIR, CI)은?**
`hooks/rules-file-unattended.md`를 그 환경의 `rules/oh-my-fable.md`로 복사(또는 이 저장소 체크아웃에 심링크)하면 플러그인 없이 무인 규칙 전체가 실립니다. 훅은 이 파일을 사용자 관리 파일로 보고 조용합니다.

**`/fable-audit`와 `/doctor prompt-audit`는 뭐가 다른가요?**
묻는 방향이 반대입니다. `/fable-audit`는 내 규칙에 프롬프팅 가이드의 어떤 절이 빠졌는지(더할 것)를 찾고, Claude Code의 `/doctor prompt-audit`(2.1.283 이상)는 내 규칙에서 낡았거나 틀렸거나 서로 부딪히는 문구(지울 것)를 찾습니다. 둘 다 스스로 고치지 않으니, 설정을 정리할 때는 둘 다 돌리세요.

**`omitClaudeMd: true`인 서브에이전트도 규칙을 받나요?**
규칙 파일이나 CLAUDE.md로는 받지 못합니다. Claude Code 2.1.284에서 재 보니 `omitClaudeMd: true`인 사용자 정의 서브에이전트는 `~/.claude/rules/*.md`, 프로젝트의 `.claude/rules/*.md`, CLAUDE.md를 하나도 보지 못했고, 같은 에이전트에서 이 설정만 뺀 쪽은 셋 다 봤습니다. 훅은 이런 에이전트를 구별할 수 없어서(SubagentStart 입력에는 에이전트 종류만 옴) 훅만 방식이면 다른 서브에이전트처럼 짧은 판을 받고, 다른 방식이면 이 플러그인에서 아무것도 받지 않습니다. 가벼운 문맥이라는 이 설정의 취지와 맞으니, 꼭 닿아야 하는 규칙은 그 에이전트의 프롬프트에 넣으세요.

**API나 Agent SDK로 직접 붙이는 경우는?**
`/fable-setup`은 질문 도구가 필요해 SDK에서는 `auto` 인자만 됩니다. 가장 간단한 방법은 `hooks/always-on.md` 내용을 시스템 프롬프트에 그대로 붙이는 것입니다. 3층의 API 항목(thinking.display 등)은 그쪽 설정입니다.

## 구성

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            플러그인 매니페스트
│   └── marketplace.json       이 저장소를 마켓플레이스로 등록
├── hooks/
│   ├── hooks.json             SessionStart · SubagentStart 훅 등록, 요청 카드 mod 연결
│   ├── card/                  요청 카드 mod (register.tsx: 카드 그리기 · parse.ts: 개선된 요청 블록 읽기)
│   ├── session-start.sh       훅 본체 (세션 시작: 규칙 파일이 있으면 무인 문단만, 없으면 전체 · 서브에이전트: 짧은 판 · --status)
│   ├── subagent.md            서브에이전트에 넣는 짧은 판
│   ├── always-on.md           블록 원문 (영어)
│   ├── rules-file.md          /fable-setup이 ~/.claude/rules/oh-my-fable.md 로 복사하는 기본 규칙
│   ├── rules-file-unattended.md 플러그인 없는 헤드리스 전용 환경용 정적 규칙(무인 문단 둘 포함)
│   ├── effort-high.md         블록 N, 세션이 xhigh·max effort로 시작할 때만 추가
│   └── autonomy-unattended.md 무인 모드에서만 추가되는 문단 둘
├── skills/
│   ├── fable-setup/SKILL.md   충돌 점검·모드 전환·설정 점검 (2층·3층)
│   ├── fable-status/SKILL.md  지금 적용 중인 것 한 표로 (읽기 전용)
│   ├── fable-audit/
│   │   ├── SKILL.md           내 규칙을 가이드와 대조 (읽기 전용)
│   │   └── references/        가이드 절별 점검표와 모델별 주의점
│   ├── fable/
│   │   ├── SKILL.md           매번 요청 개선 (1층)
│   │   └── references/        블록 원문(A~N)과 전후 예시
│   └── fable-prompt/SKILL.md  /fable 의 옛 이름. 2.5.x 동안 그대로 동작
├── tests/card.test.ts         요청 카드 시험 (`claude plugin test .`)
├── evals/                     `claude plugin eval` 평가 묶음: 사례 5개, 모델 판정 없이 규칙으로 채점
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 기여와 라이선스

이슈와 PR을 환영합니다. 가이드가 갱신되면 `hooks/always-on.md`(주입 원문), `hooks/autonomy-unattended.md`(무인 문단), `hooks/rules-file.md`(마커 버전을 올릴 것), `hooks/rules-file-unattended.md`, `hooks/effort-high.md`, `skills/fable/references/prompt-blocks.md`(전체 블록 목록)를 같이 고칩니다. 플러그인이 실제로 무엇을 보태는지 재려면 `claude plugin eval . --scaffold --allow-tools Edit Write`를 돌립니다(사례마다 플러그인 없는 쪽도 함께 돌려 비교합니다).

MIT © Junhan2. 가이드 원문의 저작권은 Anthropic에 있습니다.
