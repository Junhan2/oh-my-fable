<div align="center">

# oh-my-fable

**Claude Fable 5.1을 Claude Code에서 가장 좋은 품질로 쓰는 법. 한 번 세팅하고, 매번 개선된 요청으로.**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-2e7d32.svg)](https://github.com/Junhan2/oh-my-fable)
[![GitHub stars](https://img.shields.io/github/stars/Junhan2/oh-my-fable?style=flat)](https://github.com/Junhan2/oh-my-fable/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/Junhan2/oh-my-fable)](https://github.com/Junhan2/oh-my-fable/commits/main)

한국어 · [English](README.en.md) · [中文](README.zh.md)

</div>

---

```
/fable-prompt 이거 좀 고쳐줘
```
```
개선된 요청
목표: apps/web/src/lib/pricing.ts 의 TS2345 오류를 없애고 tsc --noEmit 이 0 오류로 끝나게 한다
맥락: 붙여넣은 오류 원문. 관련 결정 없음
범위: 이 파일과 타입 정의 파일만. 옆에 보이는 다른 오류는 고치지 말고 후속 과제로 보고
완료 기준: pnpm tsc --noEmit 출력 0 errors. 출력 원문을 보고에 첨부
effort: high
```

Anthropic 공식 문서 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)의 처방을 스킬 두 개에 담았습니다. 문구는 원문 그대로 씁니다.

> **Fable에서만 쓸 수 있나요?** 아닙니다. 네 칸 요청 틀(목표·맥락·범위·완료 기준)과 범위 제한·부분 편집·진행 보고 규칙은 Opus, Sonnet 등 어떤 모델에서도 그대로 도움이 됩니다. Fable 5.1 전용인 것은 그 모델의 버릇을 되돌리는 문구 몇 개(서식 규칙, 자율 진행 블록, effort 권고값)뿐이고, 다른 모델에 있어도 해가 되지 않습니다.

## 목차

- [무엇을 하나](#무엇을-하나)
- [빠른 시작](#빠른-시작)
- [초보자 흐름](#초보자-흐름)
- [작동 원리: 세 층](#작동-원리-세-층)
- [1층 · 매번 요청에](#1층--매번-요청에)
- [2층 · 한 번 깔아 두기](#2층--한-번-깔아-두기)
- [3층 · 설정값](#3층--설정값)
- [증상별 처방](#증상별-처방)
- [FAQ](#faq)
- [구성](#구성)
- [기여와 라이선스](#기여와-라이선스)

## 무엇을 하나

| 스킬 | 언제 | 하는 일 |
|---|---|---|
| `/fable-setup` | 설치 후 한 번 | 환경(CLAUDE.md, 설정, 에이전트 파일)을 읽고 충돌하는 옛 규칙을 짚은 뒤, 상시 규칙을 CLAUDE.md에 씁니다. `auto`를 붙이면 질문 없이 진행합니다 |
| `/fable-prompt` | 요청이 짧거나 막연할 때마다 | 목표·맥락·범위·완료 기준·effort를 채운 요청을 보여 주고 바로 실행합니다. `프롬프트만`을 붙이면 보여 주기만 합니다 |

Fable 5.1은 긴 작업을 혼자 끝까지 해내는 능력이 커진 대신 버릇이 바뀌었습니다. 작업 중 말수가 줄고, 한 번에 도구 하나씩만 부르고, 작은 수정에도 파일을 통째로 다시 쓰고, low effort에서는 검색 대신 기억으로 답합니다. 공식 가이드는 이 변화에 대한 증상별 처방이고, 이 플러그인은 그 처방을 자동으로 적용합니다.

## 빠른 시작

가장 쉬운 방법은 Claude Code에 한마디 하는 것입니다.

```
https://github.com/Junhan2/oh-my-fable 설치해줘
```

직접 설치하려면:

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```

그다음 Claude Code 안에서 **한 줄씩 따로** 입력합니다. 슬래시 명령은 한 줄에 하나만 인식되므로 두 줄을 한꺼번에 붙여 넣으면 첫 번째만 실행됩니다.

```
/reload-plugins
```
`Reloaded: … plugins` 가 뜨면
```
/fable-setup auto
```

끝입니다. 이후에는 막연한 요청 앞에 `/fable-prompt`를 붙이세요.

> **요구 사항** Claude Code 2.1.258 이상(`/reload-plugins` 명령 기준). 그 이전 버전은 설치 후 재시작하면 됩니다.

## 초보자 흐름

직접 입력하는 것은 굵게 표시한 세 번뿐입니다.

| 순서 | 누가 | 무엇 |
|---|---|---|
| 1 | **사용자** | Claude Code에 `https://github.com/Junhan2/oh-my-fable 설치해줘` |
| 2 | Claude | 이 README를 읽고 마켓플레이스 등록, 플러그인 설치, 설치 확인을 스스로 실행 |
| 3 | Claude | "먼저 `/reload-plugins` 를 입력하고 Enter, 완료 메시지가 뜨면 `/fable-setup auto` 를 입력하고 Enter" 라고 안내 |
| 4 | **사용자** | `/reload-plugins` 입력 후 Enter. `Reloaded: … plugins` 메시지가 뜨면 플러그인이 켜진 것 |
| 5 | **사용자** | 그다음 줄에 `/fable-setup auto` 입력 후 Enter (4번과 한 줄에 붙여 쓰면 앞의 것만 실행됨) |
| 6 | Claude | 환경을 읽고, 충돌하는 옛 규칙을 표로 보여 주고, CLAUDE.md에 상시 규칙 구간을 쓴 뒤, 쓴 내용과 되돌리는 법을 보여 줌. 질문 없음 |
| 7 | Claude | 사용법 세 줄 안내: "막연한 요청은 `/fable-prompt <요청>`. 보기만은 `프롬프트만`" |
| 8 | 사용자 | 이후 평소처럼. `/fable-prompt 이거 좀 고쳐줘` |

- **질문을 받고 싶으면** 5번에서 `auto`를 빼고 `/fable-setup`. 질문은 두 개입니다: 주 사용 방식(대화형 / 무인 / API 연동), 규칙 위치(글로벌 `~/.claude/CLAUDE.md` 전체 적용 / 이 프로젝트의 `CLAUDE.md`만).
- **`auto`의 범위**는 가장 넓은 글로벌 `~/.claude/CLAUDE.md`입니다(없으면 만듭니다). 프로젝트 하나에만 넣으려면 `auto` 없이 실행해 고릅니다.
- **되돌리기**는 CLAUDE.md에서 `<!-- oh-my-fable:start -->` 부터 `<!-- oh-my-fable:end -->` 까지 지우면 끝입니다.

<details>
<summary>AI가 따르는 절차 (Claude가 이 README를 읽고 실행)</summary>

1. `claude plugin marketplace add Junhan2/oh-my-fable`
2. `claude plugin install oh-my-fable@oh-my-fable`
3. `claude plugin list`로 `oh-my-fable@oh-my-fable`이 보이는지 확인
4. 사용자에게 이렇게만 안내한다: "먼저 `/reload-plugins` 를 입력하고 Enter를 누르세요. `Reloaded:` 메시지가 뜨면 `/fable-setup auto` 를 입력하고 Enter를 누르세요. 두 명령은 한 줄에 같이 쓰면 안 됩니다."
5. 그 밖의 설명은 하지 않는다. 사용법 안내는 `/fable-setup`이 끝에서 한다

</details>

## 작동 원리: 세 층

가이드의 처방은 적용 방법이 다른 세 층으로 나뉩니다.

| 층 | 무엇 | 어떻게 적용 |
|---|---|---|
| **1. 매번 요청에** | 목표·맥락·범위·완료 기준, effort, 진단만 하라는 예외, 시사성 질문의 검색 요청, 장문 안내문 | `/fable-prompt`가 채움 |
| **2. 한 번 깔아 두기** | 자율 진행, 범위·테스트 제한, 부분 편집, 진행 보고, 서식 규칙, 도구 일괄 호출 | `/fable-setup`이 CLAUDE.md에 씀 |
| **3. 설정값** | effort 기본값, thinking.display, 대화 이력 규칙, 서브에이전트, 비전 crop | `/fable-setup`이 점검표로 알려 줌. 변경은 관리자 |

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
- **effort** · 기본 `high`. 일상 편집은 `medium`. `low`는 검색을 건너뛸 수 있음. `xhigh`/`max`로 긴 문서를 시키면 초안을 두 번 써서 느려지니 장문 안내문(블록 G)을 붙이고 `max_tokens`를 넉넉히.
- **글이 빽빽할 때** · `Please remove all mannered prose.`
- **자료 요약** · 올바른 답 예시 1건(블록 J)을 같이 줌.

## 2층 · 한 번 깔아 두기

`/fable-setup`이 아래를 `## Fable 5.1 prompting (oh-my-fable)` 섹션으로 CLAUDE.md에 넣습니다. 다시 실행하면 같은 자리를 갱신합니다.

| 블록 | 한 줄 요지 | 주의 |
|---|---|---|
| **A** 자율 진행 | "사용자가 지켜보고 있지 않다. 되돌릴 수 있는 일은 묻지 말고 진행, 파괴적 행동만 멈춰라. 턴 끝에 마지막 문단이 계획이면 지금 실행하라" | 첫 문장이 효과의 대부분. 무인 세션에만 전체를, 대화형에는 자기 점검 문단만 |
| **D** 범위·테스트 | 시키지 않은 버그·개선은 고치지 말고 후속 과제로 보고. 테스트는 요청했거나 저장소 관례가 있을 때만 | 부탁한 것은 전부 완전히 |
| **C** 부분 편집 | 결과가 같다면 파일을 통째로 다시 쓰지 말고 필요한 부분만 | |
| **E** 진행 보고 | 시작 한 줄, 중간 갱신, 끝에는 마지막 메시지만 봐도 되는 요약 | 먼저 "마지막에 한꺼번에 보고" 류 옛 지시를 삭제 |
| **I** 서식 규칙 | 내용이 다면적이면 목록, 요청하면 최소 서식, 대화체는 산문 | 옛 "서식 쓰지 마" 규칙은 삭제. 5.1은 이미 서식을 덜 씀 |
| **B** 도구 일괄 호출 | 필요한 것을 먼저 나열하고 서로 독립인 것은 한 번에 요청 | |

## 3층 · 설정값

- `CLAUDE_CODE_EFFORT_LEVEL` · 기본 `high` 권장. 모델마다 단계의 실제 사고량이 달라 Fable 5 값을 그대로 옮기지 말 것.
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
`/fable-setup`이 먼저 표로 짚어 줍니다. 같은 뜻이면 중복하지 않고 "이미 있음"으로 표시하고, 반대 뜻(서식 금지, 마지막에 한꺼번에 보고)이면 교체를 제안합니다.

**`/fable-prompt`가 매번 긴 영어 문구를 붙이나요?**
아닙니다. CLAUDE.md에 `oh-my-fable` 구간이 있으면 상시 블록은 붙이지 않고 네 칸과 요청별 문구만 붙입니다. 구간이 없을 때만 인라인으로 붙이고 `/fable-setup`을 권합니다.

**Fable 5.1이 아닌 모델에서도 되나요?**
됩니다. 네 칸 요청 틀과 작업 규율(범위 제한, 부분 편집, 진행 보고, 도구 일괄 호출)은 모델과 무관하게 이득입니다. 서식 규칙, 자율 진행 블록, effort 권고값은 Fable 5.1 기준으로 측정된 것이라 다른 모델에서는 효과가 작을 수 있지만 해는 없습니다.

**되돌리려면?**
CLAUDE.md에서 `<!-- oh-my-fable:start -->` ~ `<!-- oh-my-fable:end -->` 구간을 지우고, `claude plugin uninstall oh-my-fable@oh-my-fable`.

## 구성

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            플러그인 매니페스트
│   └── marketplace.json       이 저장소를 마켓플레이스로 등록
├── skills/
│   ├── fable-setup/SKILL.md   한 번 세팅 (2층·3층)
│   └── fable-prompt/
│       ├── SKILL.md           매번 요청 개선 (1층)
│       └── references/        블록 원문(A~K)과 전후 예시
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 기여와 라이선스

이슈와 PR을 환영합니다. 가이드가 갱신되면 `skills/fable-prompt/references/prompt-blocks.md`만 고치면 두 스킬에 함께 반영됩니다.

MIT © Junhan2. 가이드 원문의 저작권은 Anthropic에 있습니다.
