# 증상별 처방

[← oh-my-fable](../README.md) · 한국어 · [English](symptoms.en.md) · [中文](symptoms.zh.md)

| 증상 | 처방 |
|---|---|
| "할까요?" 하고 멈춤 | 블록 A·M (무인 세션이면 자동, 항상 넣으려면 `/fable-setup unattended`) |
| 무인 실행이 진행 보고만 하고 턴을 끝냄 | 블록 M (무인 세션이면 자동) |
| `xhigh`/`max`에서 일이 끝난 뒤에도 검토·보강을 계속하거나 검토용 서브에이전트를 띄움 | 블록 N (`xhigh`/`max`로 시작한 세션이면 자동), 또는 일상 작업은 `high` 이하로 |
| 타임아웃이나 도구 실패에서 다른 방법을 써 보지 않고 멈춤 | 블록 O (무인 세션과 서브에이전트에 자동) |
| 최종 보고가 과정을 못 본 사람에게 읽기 어려움 | 블록 P (`/fable`이 보고·인계 요청에 붙임) |
| 있는 코드를 합치지 않고 비슷한 코드를 또 만듦 | 블록 Q, 구조를 바꿔도 될 때만 |
| 필요 없는 승인을 구하거나 일상 작업을 보류함 | 승인 규칙에 행동을 정확히 적고, "절대 금지" 규칙 안에 예외를 적기 (`/fable-audit` N19·N20) |
| 시키지 않은 곳까지 고침 | 블록 D |
| 시킨 것보다 좁히거나 넓혀서 함 | 블록 L |
| 몇 분씩 조용함 | 옛 지시 삭제 후 블록 E, API면 thinking.display |
| 한 줄 고치는데 파일 전체 재작성 | 블록 C |
| 최신 정보인데 안 찾아봄 | effort 올리기 또는 블록 H |
| 문장이 빽빽함 | `Please remove all mannered prose.` |
| 목록이 있어야 할 곳에 없음 | 서식 금지 규칙을 블록 I로 교체 |
| 요약에 원문이 인용 표시 없이 섞임 | 블록 J 예시 |
| 평범한 코드 요청이 거절됨 | "버그 있나요?"로 묻기, 생소한 언어는 문서 링크 |

블록 원문 전체: [`skills/fable/references/prompt-blocks.md`](https://github.com/Junhan2/oh-my-fable/blob/main/skills/fable/references/prompt-blocks.md)

---

다른 문서: [작동 원리](how-it-works.md) · [설정과 환경](setup.md) · [FAQ](faq.md) · [구성과 기여](contributing.md)
