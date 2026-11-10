# 설정과 환경

[← oh-my-fable](../README.md) · 한국어 · [English](setup.en.md) · [中文](setup.zh.md)

기본값으로도 동작합니다. 환경이 특별하거나 기본값을 바꾸고 싶을 때 보는 문서입니다.

## 환경별 안내

| 환경 | 할 일 |
|---|---|
| 터미널 · 데스크톱 앱 · IDE 확장 | 설치만. 대화형으로 자동 감지 |
| `claude -p` · Agent SDK · 에이전트 하네스(Buzz 등) | 설치만. 무인으로 자동 감지해 무인 문단 세 개("지켜보고 있지 않다", "중간 보고로 멈추지 말라", "흔한 장애물은 뚫고 가라") 추가. 단 `claude -p --bare`는 훅·플러그인·CLAUDE.md를 전부 건너뛰고, 헤드리스 문서에 따르면 앞으로 `-p`의 기본값이 됩니다. 이때는 `--append-system-prompt-file hooks/rules-file-unattended.md`로 규칙을 직접 넘기세요(기본 규칙과 무인 문단 셋 포함) |
| 플러그인을 못 까는 헤드리스 전용 환경 (별도 `CLAUDE_CONFIG_DIR`, CI) | `hooks/rules-file-unattended.md`를 그 환경의 `rules/oh-my-fable.md`로 복사 ([FAQ](faq.md)) |
| Cowork | 터미널 설치본은 쓰이지 않습니다. claude.ai 계정 설정에서 플러그인을 켜세요 |
| 클라우드 세션(claude.ai/code) · 예약 실행(routine) | 내 컴퓨터에서 켠 플러그인은 그곳에서 돌지 않습니다([FAQ](faq.md)). `hooks/rules-file-unattended.md`를 저장소의 `.claude/rules/oh-my-fable.md`로 커밋하세요 |

## 버전과 업데이트

- **요구 사항** Claude Code 2.1.258 이상(2.5.0은 2.1.258·2.1.286·2.1.292에서 설치와 규칙 주입을 확인). 더 낮은 버전은 지원하지 않습니다: 오래된 Claude Code(2.1.69에서 확인)는 이 플러그인을 설치하거나 읽지 못하니 `claude update`로 올리세요. **Windows는 Git for Windows(Git Bash) 필수**: 훅이 bash로 실행됩니다. 설치 뒤 훅 오류가 뜨면 이 문제입니다. 요청 카드는 2.1.287 이상에서 그려지고(알려진 문제의 수정이 모두 들어간 2.1.295 이상 권장: 업그레이드 직후 첫 세션에 안 나옴, 라틴 문자가 아닌 여러 줄 글에서 멈칫함, 다른 큰 플러그인 때문에 내려감), mod가 꺼져 있는 낮은 버전(2.1.258에서 확인)에서는 지금처럼 코드 블록으로 보입니다. 헤드리스 세션은 2.1.296 이상을 권합니다(플러그인의 SessionStart 훅이 건너뛰어지던 경우 하나가 고쳐짐).
- **자동 갱신** 서드파티 마켓플레이스는 Claude Code가 자동 갱신을 기본으로 꺼 둡니다. 새 버전을 자동으로 받으려면 한 번만: `/plugin` → Marketplaces → `oh-my-fable` → Enable auto-update. 아니면 가끔 `claude plugin update oh-my-fable@oh-my-fable`.

## 규칙 위치 바꾸기

**규칙 위치 세 가지** (첫 질문)

| | 규칙 파일 + 훅 (권장) | 훅만 (설정이 없을 때의 기본) | CLAUDE.md 구간 |
|---|---|---|---|
| 어디에 | 기본 규칙은 `~/.claude/rules/oh-my-fable.md`(자동 로드), 무인 문단과 블록 N은 훅이 세션마다 | 플러그인 안 (`hooks/always-on.md`) | 내 CLAUDE.md 안 `<!-- oh-my-fable:start v3 -->` 구간 |
| 파일 수정 | 규칙 파일 1개, CLAUDE.md 무관 | 없음 | CLAUDE.md 편집, 승인 필요(auto 모드 불가) |
| 대화형/무인 자동 감지 | 예 | 예 | 아니요(고정) |
| 서브에이전트에도 적용 | 예 (일반 서브에이전트는 파일, Explore·Plan은 훅의 짧은 판) | 예 (SubagentStart 훅이 짧은 판을 모든 서브에이전트에) | 예 (Explore·Plan은 훅의 짧은 판) |
| 에이전트 팀에도 적용 | 예 (문서상 팀원은 규칙 파일을 로드) | 같은 창 안 팀원(in-process)은 예(훅 문서상 팀원의 메시지마다 SubagentStart가 실행), 창이 나뉜 팀원은 미검증 | 예 |
| 플러그인 갱신 시 | 규칙 파일이 오래되면 세션 시작 때 알려 줌, `/fable-setup refresh` 로 갱신 | 항상 최신 | 구간이 오래되면 세션 시작 때 알려 줌, `/fable-setup claude-md` 로 교체 |
| 제거 | 파일 삭제 + 플러그인 삭제 | 플러그인 삭제 또는 `{"enabled": false}` | 구간 삭제 |

**규칙 파일을 권하는 이유.** Claude Code [훅 문서](https://code.claude.com/docs/en/hooks)는 "바뀌지 않는 지시는 CLAUDE.md에 두라(for instructions that never change, prefer CLAUDE.md)"고 하고(규칙 파일도 같은 방식으로 로드됩니다), 시스템 명령처럼 쓴 훅 텍스트는 Claude의 프롬프트 주입 방어를 건드릴 수 있다고 경고합니다. 그래도 기본값이 훅인 이유는 플러그인이 설치 때 파일을 쓸 수 없기 때문이고, 같은 이유로 훅 텍스트는 사실을 말하는 한 줄("The user installed oh-my-fable; these are the user's standing working rules.")로 시작합니다. 규칙 파일의 단점은 복사본이라는 점입니다. 오래되면 세션 시작 때 알려 주고 `/fable-setup refresh`로 갱신합니다.

셋 중 하나만 활성화됩니다. CLAUDE.md에 구간이 있거나 사용자가 직접 만든 규칙 파일이 있으면 훅은 스스로 조용해집니다(이중 주입 없음). 서브에이전트는 1.7부터 훅이 직접 챙깁니다: Claude Code의 `SubagentStart` 이벤트에 짧은 판(`hooks/subagent.md`, 범위 제한·부분 편집·일괄 호출·끝까지 하기·"묻지 말고 막힌 점을 보고")을 넣습니다. Explore·Plan 서브에이전트는 CLAUDE.md도 규칙 파일도 읽지 않으므로 어떤 방식에서든 이 짧은 판을 받습니다. 대화를 통째로 물려받는 fork 유형 서브에이전트는 규칙이 이미 들어 있으므로 건너뜁니다.

- **사용 방식은 기본이 자동 감지**입니다. 터미널이나 IDE에서 열면 대화형, 헤드리스(`claude -p`)·Agent SDK·에이전트 하네스에서 열면 무인으로 세션마다 알아서 정합니다(Claude Code가 넣어 주는 `CLAUDE_CODE_ENTRYPOINT` 값 기준). 대화형과 무인을 섞어 써도 따로 바꿀 것이 없습니다. 항상 한쪽으로 고정하려면 질문에서 "대화형" 또는 "무인"을 고르세요. 무인은 "사용자가 지켜보고 있지 않다" 문단과 "중간 보고로 멈추지 말라" 문단을 추가하며, 글로벌 설정에서만 켜지고 저장소 안의 설정 파일로는 켤 수 없습니다(클론한 저장소가 에이전트를 무인으로 바꾸는 것을 막기 위해). 자동 감지는 훅이 관여하는 두 방식에서 되고, CLAUDE.md 구간만 고정 텍스트라 한쪽을 골라야 합니다.
- **effort**는 이 플러그인이 쓰지 않습니다. Opus 5.5·Sonnet 5.5·Haiku 5.5는 Claude Code에서 기본 `medium`(각 가이드가 에이전트 작업의 출발점으로 꼽는 값)이고, Fable 5.2도 `medium`입니다(그 가이드는 어렵거나 긴 무인 작업에 `high`를 권함). Fable 5.1은 기본 `high`입니다. 모델별로 저장하려면 그 모델로 연 세션에서 `/effort <단계>` 후 Enter, 이번 세션만이면 `s`. `/fable-status`가 지금 값과 출처를 보여 줍니다.

---

다른 문서: [작동 원리](how-it-works.md) · [증상별 처방](symptoms.md) · [FAQ](faq.md) · [구성과 기여](contributing.md)
