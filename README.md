<div align="center" markdown="1">

# oh-my-fable

**Claude Fable 5.1을 Claude Code에서 가장 좋은 품질로 쓰는 법. 한 번 세팅하고, 매번 개선된 요청으로.**

Opus 5, Sonnet 5에서도 결과 품질이 올라갑니다.

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
/fable-prompt 로그인 버튼 눌러도 아무 반응 없어 고쳐줘
```
🤖 **Claude가 실제로 받는 요청** (대화 맥락에서 자동으로 채워짐)
```
목표: 로그인 버튼을 누르면 /api/login 이 호출되고, 성공하면 /dashboard 로 이동하게 한다
맥락: src/components/LoginButton.tsx, 콘솔 오류 "TypeError: onSubmit is not a function", 어제 인증 방식을 바꾼 커밋 이후 발생
범위: 이 버튼과 그 핸들러만. 옆의 회원가입 폼이나 다른 오류는 고치지 말고 후속 과제로 보고
완료 기준: 실제 클릭을 재현해 /dashboard 이동 확인, 콘솔 오류 0, 변경 파일 목록 첨부
```

Anthropic 공식 문서 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)의 처방을 스킬 두 개에 담았습니다. 문구는 원문 그대로 씁니다.

> **Fable에서만 쓸 수 있나요?** 아닙니다. **Opus 5, Sonnet 5에서도 결과 품질이 올라갑니다.** 네 칸 요청 틀(목표·맥락·범위·완료 기준)은 모델이 무엇이든 되묻기와 빗나간 결과를 줄이고, 범위 제한·부분 편집·진행 보고·끝까지 하기 규칙은 어떤 모델에서도 그대로 작업 품질을 끌어올립니다. Fable 5.1 전용인 것은 그 모델의 버릇을 되돌리는 문구 몇 개(서식 규칙, 자율 진행 블록, effort 권고값)뿐이고, 다른 모델에 있어도 해가 되지 않습니다.

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
| **상시 규칙** | 설치하면 자동, 파일 없음 | 세션이 시작될 때마다 훅이 Fable 5.1 가이드의 상시 규칙(자율 진행, 범위 제한, 부분 편집, 진행 보고, 서식, 도구 일괄 호출)을 영어 원문 그대로 넣습니다. 헤드리스·SDK 세션이면 "사용자가 지켜보고 있지 않다" 문단을 자동으로 더하고, Agent 도구로 띄운 서브에이전트에는 짧은 판을 따로 넣습니다. 규칙 파일도 CLAUDE.md도 만들지 않습니다 |
| `/fable-prompt` | 요청이 짧거나 막연할 때 | 목표·맥락·범위·완료 기준·effort를 채운 요청을 보여 주고 바로 실행합니다. `프롬프트만`을 붙이면 보여 주기만 합니다 |
| `/fable-status` | 지금 뭐가 켜져 있는지 궁금할 때 | 플러그인 버전, 규칙 위치, 감지된 모드, effort, 규칙 파일이 최신인지, CLAUDE.md 충돌 수를 표 하나로 보여 줍니다. 아무것도 쓰지 않습니다 |
| `/fable-setup` | 선택 사항 | 기본값을 바꾸고 싶을 때만: 규칙을 파일로 두거나(에이전트 팀용) CLAUDE.md 구간으로, 모드를 한쪽으로 고정, effort 기본값 기록, 기존 CLAUDE.md 규칙과의 충돌 점검 |

Fable 5.1은 긴 작업을 혼자 끝까지 해내는 능력이 커진 대신 버릇이 바뀌었습니다. 작업 중 말수가 줄고, 한 번에 도구 하나씩만 부르고, 작은 수정에도 파일을 통째로 다시 쓰고, low effort에서는 검색 대신 기억으로 답합니다. 공식 가이드는 이 변화에 대한 증상별 처방이고, 이 플러그인은 그 처방을 자동으로 적용합니다.

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

> **요구 사항** Claude Code 2.1.258 이상. **Windows는 Git for Windows(Git Bash) 필수**: 훅이 bash로 실행됩니다. 설치 뒤 훅 오류가 뜨면 이 문제입니다.
>
> **자동 갱신** 서드파티 마켓플레이스는 Claude Code가 자동 갱신을 기본으로 꺼 둡니다. 새 버전을 자동으로 받으려면 한 번만: `/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update. 아니면 가끔 `claude plugin update oh-my-fable@oh-my-fable`.

</details>

## 사용법: 평소처럼

그냥 평소처럼 요청하면 됩니다. 상시 규칙은 이미 켜져 있습니다. 요청이 짧거나 막연하면 앞에 `/fable-prompt`를 붙이세요.

```
/fable-prompt 이거 좀 고쳐줘
```

목표·맥락·범위·완료 기준·effort를 채운 요청을 보여 주고 바로 실행합니다. 보기만 하려면 뒤에 `프롬프트만`.

## 초보자 흐름

| 순서 | 누가 | 무엇 |
|---|---|---|
| 1 | **사용자** | `https://github.com/Junhan2/oh-my-fable 설치해줘` |
| 2 | Claude | 마켓플레이스 등록, 플러그인 설치, "다음 세션부터 자동 적용. 지금 쓰려면 `/reload-plugins` 다음 `/clear`" 안내 |
| 3 | 사용자 | 이후 평소처럼. 막연한 요청은 `/fable-prompt 이거 좀 고쳐줘`, 궁금하면 `/fable-status` |

**60초 경로: 내 환경에서는?**

| 환경 | 할 일 |
|---|---|
| 터미널 · 데스크톱 앱 · IDE 확장 | 설치만. 대화형으로 자동 감지 |
| `claude -p` · Agent SDK · 에이전트 하네스(Buzz 등) | 설치만. 무인으로 자동 감지해 "지켜보고 있지 않다" 문단 추가. 단 `claude -p --bare`는 훅·플러그인·CLAUDE.md를 전부 건너뛰므로 `hooks/always-on.md`를 시스템 프롬프트에 직접 붙이세요 |
| 플러그인을 못 까는 헤드리스 전용 환경 (별도 `CLAUDE_CONFIG_DIR`, CI) | `hooks/rules-file-unattended.md`를 그 환경의 `rules/oh-my-fable.md`로 복사 ([FAQ](#faq)) |
| Cowork · claude.ai/code | 터미널 설치본은 쓰이지 않습니다. claude.ai 계정 설정에서 플러그인을 켜세요 |

<details>
<summary>선택 사항: 규칙 위치 바꾸기 (`/fable-setup`)</summary>

**규칙 위치 세 가지** (첫 질문)

| | 훅만 (기본) | 규칙 파일 + 훅 (에이전트 팀용) | CLAUDE.md 구간 |
|---|---|---|---|
| 어디에 | 기본 규칙은 `~/.claude/rules/oh-my-fable.md`(자동 로드), 무인 문단은 훅이 세션마다 | 플러그인 안 (`hooks/always-on.md`) | 내 CLAUDE.md 안 `<!-- oh-my-fable:start v1 -->` 구간 |
| 파일 수정 | 규칙 파일 1개, CLAUDE.md 무관 | 없음 | CLAUDE.md 편집, 승인 필요(auto 모드 불가) |
| 대화형/무인 자동 감지 | 예 | 예 | 아니요(고정) |
| 서브에이전트에도 적용 | 예 (일반 서브에이전트는 파일, Explore·Plan은 훅의 짧은 판) | 예 (SubagentStart 훅이 짧은 판을 모든 서브에이전트에) | 예 (Explore·Plan은 훅의 짧은 판) |
| 에이전트 팀에도 적용 | 예 (문서상 팀원은 규칙 파일을 로드) | 미검증 | 예 |
| 플러그인 갱신 시 | 규칙 파일이 오래되면 세션 시작 때 알려 줌, `/fable-setup refresh` 로 갱신 | 항상 최신 | 구간을 다시 붙여 넣기 |
| 제거 | 파일 삭제 + 플러그인 삭제 | 플러그인 삭제 또는 `{"enabled": false}` | 구간 삭제 |

셋 중 하나만 활성화됩니다. CLAUDE.md에 구간이 있거나 사용자가 직접 만든 규칙 파일이 있으면 훅은 스스로 조용해집니다(이중 주입 없음). 서브에이전트는 1.7부터 훅이 직접 챙깁니다: Claude Code의 `SubagentStart` 이벤트에 짧은 판(`hooks/subagent.md`, 범위 제한·부분 편집·일괄 호출·끝까지 하기·"묻지 말고 막힌 점을 보고")을 넣습니다. Explore·Plan 서브에이전트는 CLAUDE.md도 규칙 파일도 읽지 않으므로 어떤 방식에서든 이 짧은 판을 받습니다.

- **사용 방식은 기본이 자동 감지**입니다. 터미널이나 IDE에서 열면 대화형, 헤드리스(`claude -p`)·Agent SDK·에이전트 하네스에서 열면 무인으로 세션마다 알아서 정합니다(Claude Code가 넣어 주는 `CLAUDE_CODE_ENTRYPOINT` 값 기준). 대화형과 무인을 섞어 써도 따로 바꿀 것이 없습니다. 항상 한쪽으로 고정하려면 질문에서 "대화형" 또는 "무인"을 고르세요. 무인은 "사용자가 지켜보고 있지 않다" 문단을 추가하며, 글로벌 설정에서만 켜지고 저장소 안의 설정 파일로는 켤 수 없습니다(클론한 저장소가 에이전트를 무인으로 바꾸는 것을 막기 위해). 자동 감지는 훅이 관여하는 두 방식에서 되고, CLAUDE.md 구간만 고정 텍스트라 한쪽을 골라야 합니다.
- **effort**는 `medium` 추천(Fable 5 수준 품질을 더 싸게, 어려운 작업만 그 세션에서 `/effort high`). Anthropic 가이드의 기본값은 `high`이니 품질을 우선하면 그것을 고르세요. settings.json의 `effortLevel`에 쓰며 승인 프롬프트가 뜰 수 있습니다.

</details>

<details>
<summary>AI가 따르는 절차 (Claude가 이 README를 읽고 실행)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. `~/.claude/plugins/installed_plugins.json` 에서 `oh-my-fable@oh-my-fable` 의 `installPath` 를 읽는다
4. 설치가 확인되면 사용자에게 이렇게만 안내한다: "설치가 끝났습니다. 다음 세션부터 자동 적용됩니다. 지금 바로 쓰려면 `/reload-plugins` 를 입력하고 Enter, 그다음 `/clear` 를 입력하고 Enter 하세요(한 줄에 하나씩). 막연한 요청은 `/fable-prompt <요청>` 으로 보내세요."
5. 그 밖의 설명은 하지 않고 `/fable-setup` 도 실행하지 않는다(선택 사항이며 기본값은 설정 없이 동작). 둘 다 필요한 이유: `/reload-plugins` 는 방금 설치한 플러그인(훅·스킬)을 이 세션에 로드하고, 규칙 주입은 세션 시작·`/clear`·압축 때만 일어난다

</details>

## 작동 원리: 세 층

가이드의 처방은 적용 방법이 다른 세 층으로 나뉩니다.

| 층 | 무엇 | 어떻게 적용 |
|---|---|---|
| **1. 매번 요청에** | 목표·맥락·범위·완료 기준, effort, 진단만 하라는 예외, 시사성 질문의 검색 요청, 장문 안내문 | `/fable-prompt`가 채움 |
| **2. 상시 규칙** | 자율 진행, 범위·테스트 제한, 부분 편집, 진행 보고, 서식 규칙, 도구 일괄 호출 | 플러그인 훅이 세션 시작 때 자동 주입 |
| **3. 설정값** | 대화형/무인 모드, effort 기본값, thinking.display, 대화 이력 규칙, 서브에이전트, 비전 crop | 모드는 자동 감지. 바꾸고 싶을 때만 `/fable-setup`이 모드와 effort를 쓰고 나머지는 점검표로 알려 줌 |

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
- **effort** · 추천 `medium`(가이드 기본은 `high`). 어려운 작업만 `/effort high`. `low`는 검색을 건너뛸 수 있음. `xhigh`/`max`로 긴 문서를 시키면 초안을 두 번 써서 느려지니 장문 안내문(블록 G)을 붙이고 `max_tokens`를 넉넉히.
- **글이 빽빽할 때** · `Please remove all mannered prose.`
- **자료 요약** · 올바른 답 예시 1건(블록 J)을 같이 줌.

## 2층 · 상시 규칙

플러그인의 SessionStart 훅이 세션마다 아래 블록을 영어 원문 그대로 불러옵니다(파일 `hooks/always-on.md`). CLAUDE.md는 수정하지 않으며, 사용자 언어와 무관하게 영어입니다. 블록 A의 첫 문단("사용자가 지켜보고 있지 않다")은 헤드리스·SDK 세션에서만 자동으로 들어가고 터미널·IDE에서는 빠집니다. 항상 넣으려면 `/fable-setup unattended`.

| 블록 | 한 줄 요지 | 주의 |
|---|---|---|
| **A** 자율 진행 | "사용자가 지켜보고 있지 않다. 되돌릴 수 있는 일은 묻지 말고 진행, 파괴적 행동만 멈춰라. 턴 끝에 마지막 문단이 계획이면 지금 실행하라" | 첫 문장이 효과의 대부분. 무인 세션에만 전체를, 대화형에는 자기 점검 문단만 |
| **D** 범위·테스트 | 시키지 않은 버그·개선은 고치지 말고 후속 과제로 보고. 테스트는 요청했거나 저장소 관례가 있을 때만 | 부탁한 것은 전부 완전히 |
| **C** 부분 편집 | 결과가 같다면 파일을 통째로 다시 쓰지 말고 필요한 부분만 | |
| **E** 진행 보고 | 시작 한 줄, 중간 갱신, 끝에는 마지막 메시지만 봐도 되는 요약 | 먼저 "마지막에 한꺼번에 보고" 류 옛 지시를 삭제 |
| **I** 서식 규칙 | 내용이 다면적이면 목록, 요청하면 최소 서식, 대화체는 산문 | 옛 "서식 쓰지 마" 규칙은 삭제. 5.1은 이미 서식을 덜 씀 |
| **B** 도구 일괄 호출 | 필요한 것을 먼저 나열하고 서로 독립인 것은 한 번에 요청 | |

## 3층 · 설정값

- 모드 · `~/.claude/oh-my-fable.json` 의 `{"enabled": true, "mode": "interactive" | "unattended"}`. 프로젝트의 `.claude/oh-my-fable.json` 이 있으면 그것이 우선. `/fable-setup` 이 대신 써 줍니다.
- effort · 설정 파일 `effortLevel`(전역) 또는 `modelSettings.<model>.effortLevel`(모델별). 환경 변수 `CLAUDE_CODE_EFFORT_LEVEL`이 있으면 그것이 이기니 모델별 값을 쓰려면 환경 변수를 비울 것. 추천 `medium`, 가이드 기본 `high`. 모델마다 단계의 실제 사고량이 달라 Fable 5 값을 그대로 옮기지 말 것.
- API 직접 연동 · `thinking.display: "updates"`를 켜야 진행 메모가 화면에 옴. 대화 이력은 덧붙이기만(thinking 블록 포함), 턴마다 넣는 알림은 turn-scoped system message로. 압축은 서버 압축 또는 블록 K.
- 서브에이전트 · 시작 도구는 즉시 반환, 결과는 나중 메시지로.
- 비전 · 차트·표는 crop-and-zoom 도구를 붙이면 대부분의 이득.
- 거절(`stop_reason: "refusal"`) 처리 · "컴파일 되나요?" 대신 "버그 있나요?"로 묻기.

## 증상별 처방

| 증상 | 처방 |
|---|---|
| "할까요?" 하고 멈춤 | 블록 A (`/fable-setup`) |
| 시키지 않은 곳까지 고침 | 블록 D |
| 몇 분씩 조용함 | 옛 지시 삭제 후 블록 E, API면 thinking.display |
| 한 줄 고치는데 파일 전체 재작성 | 블록 C |
| 최신 정보인데 안 찾아봄 | effort 올리기 또는 블록 H |
| 문장이 빽빽함 | `Please remove all mannered prose.` |
| 목록이 있어야 할 곳에 없음 | 서식 금지 규칙을 블록 I로 교체 |
| 요약에 원문이 인용 표시 없이 섞임 | 블록 J 예시 |
| 평범한 코드 요청이 거절됨 | "버그 있나요?"로 묻기, 생소한 언어는 문서 링크 |

블록 원문 전체: [`skills/fable-prompt/references/prompt-blocks.md`](skills/fable-prompt/references/prompt-blocks.md)

## FAQ

**CLAUDE.md에 이미 비슷한 규칙이 있으면?**
`/fable-setup`이 표로 짚어 줍니다. 같은 뜻이면 "이미 있음", 반대 뜻(서식 금지, 마지막에 한꺼번에 보고)이면 바꿔 넣을 문장을 제안합니다. 실제 수정은 사용자가 합니다. Claude Code가 AI의 CLAUDE.md 자기 수정을 막기 때문입니다.

**규칙을 CLAUDE.md 말고 다른 곳에 두고 싶어요.**
기본값이 이미 그렇습니다. 규칙은 플러그인 안에만 있고 훅이 세션마다 넣으므로 CLAUDE.md도 규칙 파일도 만들지 않습니다. 굳이 파일로 두고 싶으면(에이전트 팀을 쓰거나 팀원과 같은 파일을 공유하려면) `/fable-setup`에서 규칙 파일 또는 CLAUDE.md 구간을 고릅니다. 비교표는 [초보자 흐름](#초보자-흐름)의 "선택 사항"에 있습니다.

**Fable 5.1이 아닌 모델에서도 되나요?**
됩니다. 네 칸 요청 틀과 작업 규율(범위 제한, 부분 편집, 진행 보고, 도구 일괄 호출)은 모델과 무관하게 이득입니다. 서식 규칙, 자율 진행 블록, effort 권고값은 Fable 5.1 기준으로 측정된 것이라 다른 모델에서는 효과가 작을 수 있지만 해는 없습니다.

**왜 지금 바로 쓰려면 `/reload-plugins` 다음 `/clear` 인가요?**
공식 문서 기준 두 명령은 하는 일이 다릅니다. `/reload-plugins`는 "플러그인, 스킬, 에이전트, 훅, MCP 서버를 재시작 없이 다시 로드"합니다([Plugins](https://code.claude.com/docs/en/plugins)). 규칙을 넣는 SessionStart 훅은 "새 세션(startup), 재개(resume), `/clear`, 압축(compact), 분기(fork)" 때만 실행됩니다([Hooks](https://code.claude.com/docs/en/hooks#sessionstart)). 즉 reload는 훅을 등록만 하고 실행하지 않으므로, 설치한 세션에서는 `/clear`로 한 번 실행시켜야 합니다. 새 세션을 열면 둘 다 필요 없습니다.

**지금 뭐가 켜져 있는지 보려면?**
`/fable-status`. 플러그인 버전, 규칙 위치, 이 세션의 모드(자동 감지 근거 포함), effort, 규칙 파일 버전, CLAUDE.md 충돌을 표 하나로 보여 주고 아무것도 바꾸지 않습니다. 새 세션을 열 때도 같은 내용이 한 줄로 화면에 뜹니다(Claude의 문맥에는 들어가지 않음).

**되돌리려면?**
`/fable-setup remove` 가 설정 파일, 규칙 파일, CLAUDE.md 구간을 지웁니다. 그다음 `claude plugin uninstall oh-my-fable@oh-my-fable`. 잠시 끄기만 하려면 `~/.claude/oh-my-fable.json` 에 `{"enabled": false}`.

**플러그인을 못 까는 헤드리스 전용 환경(별도 CLAUDE_CONFIG_DIR, CI)은?**
`hooks/rules-file-unattended.md`를 그 환경의 `rules/oh-my-fable.md`로 복사(또는 이 저장소 체크아웃에 심링크)하면 플러그인 없이 무인 규칙 전체가 실립니다. 훅은 이 파일을 사용자 관리 파일로 보고 조용합니다.

**API나 Agent SDK로 직접 붙이는 경우는?**
`/fable-setup`은 질문 도구가 필요해 SDK에서는 `auto` 인자만 됩니다. 가장 간단한 방법은 `hooks/always-on.md` 내용을 시스템 프롬프트에 그대로 붙이는 것입니다. 3층의 API 항목(thinking.display 등)은 그쪽 설정입니다.

## 구성

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            플러그인 매니페스트
│   └── marketplace.json       이 저장소를 마켓플레이스로 등록
├── hooks/
│   ├── hooks.json             SessionStart · SubagentStart 훅 등록
│   ├── session-start.sh       훅 본체 (세션 시작: 규칙 파일이 있으면 무인 문단만, 없으면 전체 · 서브에이전트: 짧은 판 · --status)
│   ├── subagent.md            서브에이전트에 넣는 짧은 판
│   ├── always-on.md           블록 원문 (영어)
│   ├── rules-file.md          /fable-setup이 ~/.claude/rules/oh-my-fable.md 로 복사하는 기본 규칙
│   ├── rules-file-unattended.md 플러그인 없는 헤드리스 전용 환경용 정적 규칙(무인 문단 포함)
│   └── autonomy-unattended.md 무인 모드에서만 추가되는 문단
├── skills/
│   ├── fable-setup/SKILL.md   충돌 점검·모드 전환·설정 점검 (2층·3층)
│   ├── fable-status/SKILL.md  지금 적용 중인 것 한 표로 (읽기 전용)
│   └── fable-prompt/
│       ├── SKILL.md           매번 요청 개선 (1층)
│       └── references/        블록 원문(A~K)과 전후 예시
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 기여와 라이선스

이슈와 PR을 환영합니다. 가이드가 갱신되면 `hooks/always-on.md`(주입 원문)와 `skills/fable-prompt/references/prompt-blocks.md`(전체 블록 목록) 두 곳을 같이 고칩니다.

MIT © Junhan2. 가이드 원문의 저작권은 Anthropic에 있습니다.
