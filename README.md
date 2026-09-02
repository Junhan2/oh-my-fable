# oh-my-fable

Claude Fable 5.1을 Claude Code에서 가장 좋은 품질로 쓰기 위한 가이드와 스킬 2개.
근거는 Anthropic 공식 문서 [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)이며, 문구는 원문 그대로 씁니다.

## 설치 (30초)

```bash
claude plugin marketplace add Junhan2/oh-my-fable
claude plugin install oh-my-fable@oh-my-fable
```

그다음 Claude Code에서 한 번만:

```
/fable-setup
```

환경을 읽고 질문 두 개(주 사용 방식, 규칙 위치)만 한 뒤 CLAUDE.md에 상시 규칙을 넣어 줍니다. 이후에는 요청이 짧거나 막연할 때:

```
/fable-prompt 이거 좀 고쳐줘
```

목표·맥락·범위·완료 기준·effort를 채운 요청을 보여 주고 바로 실행합니다. 보기만 하려면 뒤에 `프롬프트만`.

## 왜 필요한가 (30초)

Fable 5.1은 긴 작업을 혼자 끝까지 해내는 능력이 커진 대신 버릇이 바뀌었습니다. 작업 중 말수가 줄고, 한 번에 도구 하나씩만 부르고, 작은 수정에도 파일을 통째로 다시 쓰고, low effort에서는 검색 대신 기억으로 답합니다. 공식 가이드는 이 변화에 대한 증상별 처방입니다. 처방은 세 층으로 나뉘고, 층마다 적용 방법이 다릅니다.

## 세 층

| 층 | 무엇 | 어떻게 적용 |
|---|---|---|
| **1. 매번 요청에** | 목표·맥락·범위·완료 기준, effort, 진단만 하라는 예외, 시사성 질문의 검색 요청, 장문 안내문 | `/fable-prompt`가 채움 |
| **2. 한 번 깔아 두기** | 자율 진행, 범위·테스트 제한, 부분 편집, 진행 보고, 서식 규칙, 도구 일괄 호출 | `/fable-setup`이 CLAUDE.md에 씀 |
| **3. 설정값** | effort 기본값, thinking.display, 대화 이력 규칙, 서브에이전트, 비전 crop | `/fable-setup`이 점검표로 알려 줌, 변경은 관리자 |

## 1층 · 매번 요청에 쓰는 것

좋은 요청은 네 칸입니다.

| 칸 | 나쁜 예 | 좋은 예 |
|---|---|---|
| 목표 | 보고서 좀 | 임원 회의용 1쪽 요약, 결론이 맨 위에 |
| 맥락 | 아까 그거 | `2026-08-sales.xlsx` 시트 "raw" |
| 범위 | (없음) | 표만. 원본 수정 금지. 이상값은 고치지 말고 메모 |
| 완료 기준 | (없음) | 합계가 시트 "summary" 총액과 일치. 일치 여부를 숫자로 보고 |

요청에 따라 덧붙이는 것:
- **문제를 설명만 할 때**: "진단만 하고 고치지 마". 가이드의 명시적 예외.
- **최신 정보가 필요할 때**: effort를 high 이상으로 두거나 "사용자가 쓴 이름 그대로 한 번은 검색해" (블록 H).
- **effort**: 기본 `high`. 일상 편집은 `medium`. `low`는 검색을 건너뛸 수 있음. `xhigh`/`max`로 긴 문서를 시키면 초안을 두 번 써서 느려지니 장문 안내문(블록 G)을 붙이고 `max_tokens`를 넉넉히.
- **글이 빽빽할 때**: `Please remove all mannered prose.`
- **자료 요약**: 올바른 답 예시 1건(블록 J)을 같이 줌.

## 2층 · 한 번 깔아 두는 것 (CLAUDE.md)

`/fable-setup`이 아래를 `## Fable 5.1 prompting (oh-my-fable)` 섹션으로 넣습니다. 다시 실행하면 같은 자리를 갱신합니다.

| 블록 | 한 줄 요지 | 주의 |
|---|---|---|
| A 자율 진행 | "사용자가 지켜보고 있지 않다. 되돌릴 수 있는 일은 묻지 말고 진행, 파괴적 행동만 멈춰라. 턴 끝에 마지막 문단이 계획이면 지금 실행하라" | 첫 문장이 효과의 대부분. 무인 세션에만 전체를, 대화형에는 자기 점검 문단만 |
| D 범위·테스트 | 시키지 않은 버그·개선은 고치지 말고 후속 과제로 보고. 테스트는 요청했거나 저장소 관례가 있을 때만 | 부탁한 것은 전부 완전히 |
| C 부분 편집 | 결과가 같다면 파일을 통째로 다시 쓰지 말고 필요한 부분만 | |
| E 진행 보고 | 시작 한 줄, 중간 갱신, 끝에는 마지막 메시지만 봐도 되는 요약 | 먼저 "마지막에 한꺼번에 보고" 류 옛 지시를 삭제 |
| I 서식 규칙 | 내용이 다면적이면 목록, 요청하면 최소 서식, 대화체는 산문 | 옛 "서식 쓰지 마" 규칙은 삭제. 5.1은 이미 서식을 덜 씀 |
| B 도구 일괄 호출 | 필요한 것을 먼저 나열하고 서로 독립인 것은 한 번에 요청 | |

## 3층 · 설정값 (관리자)

- `CLAUDE_CODE_EFFORT_LEVEL`: 기본 `high` 권장. 모델마다 단계의 실제 사고량이 달라 Fable 5 값을 그대로 옮기지 말 것.
- API 직접 연동: `thinking.display: "updates"`를 켜야 진행 메모가 화면에 옴. 대화 이력은 덧붙이기만(thinking 블록 포함), 턴마다 넣는 알림은 turn-scoped system message로. 압축은 서버 압축 또는 블록 K.
- 서브에이전트: 시작 도구는 즉시 반환, 결과는 나중 메시지로.
- 비전: 차트·표는 crop-and-zoom 도구를 붙이면 대부분의 이득.
- 거절(`stop_reason: "refusal"`) 처리. "컴파일 되나요?" 대신 "버그 있나요?"로 묻기.

## 증상별 처방 (잘 안 될 때)

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

블록 원문: [`skills/fable-prompt/references/prompt-blocks.md`](skills/fable-prompt/references/prompt-blocks.md)

## 구성

```
oh-my-fable/
├── .claude-plugin/        plugin.json, marketplace.json
├── skills/
│   ├── fable-setup/       한 번 세팅 (2층·3층)
│   └── fable-prompt/      매번 요청 개선 (1층) + references/ 블록 원문·예시
└── README.md              이 가이드
```

MIT. 가이드 원문의 저작권은 Anthropic에 있습니다.
