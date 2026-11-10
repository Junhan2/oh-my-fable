# 구성과 기여

[← oh-my-fable](../README.md) · 한국어 · [English](layout.en.md) · [中文](layout.zh.md)

## 구성

```
oh-my-fable/
├── .claude-plugin/
│   ├── plugin.json            플러그인 매니페스트
│   └── marketplace.json       이 저장소를 마켓플레이스로 등록
├── hooks/
│   ├── hooks.json             SessionStart · SubagentStart · PostModelSwitch 훅 등록, 요청 카드 mod 연결
│   ├── card/                  요청 카드 mod (register.tsx: 카드 그리기 · parse.ts: 개선된 요청 블록 읽기)
│   ├── session-start.sh       훅 본체 (세션 시작: 규칙 파일이 있으면 무인 문단만, 없으면 전체 · 서브에이전트: 짧은 판 · 모델 전환: 블록 N · --status)
│   ├── subagent.md            서브에이전트에 넣는 짧은 판
│   ├── always-on.md           블록 원문 (영어)
│   ├── rules-file.md          /fable-setup이 ~/.claude/rules/oh-my-fable.md 로 복사하는 기본 규칙
│   ├── rules-file-unattended.md 플러그인 없는 헤드리스 전용 환경용 정적 규칙(무인 문단 셋 포함)
│   ├── effort-high.md         블록 N, 세션이 xhigh·max effort로 시작할 때만 추가
│   ├── whats-new.txt          버전마다 한 줄, 업데이트 뒤 첫 세션에 보여 주는 문장
│   └── autonomy-unattended.md 무인 모드에서만 추가되는 문단 셋
├── skills/
│   ├── fable-setup/SKILL.md   충돌 점검·모드 전환·설정 점검 (2층·3층)
│   ├── fable-status/SKILL.md  지금 적용 중인 것 한 표로 (읽기 전용)
│   ├── fable-audit/
│   │   ├── SKILL.md           내 규칙을 가이드와 대조 (읽기 전용)
│   │   └── references/        가이드 절별 점검표와 모델별 주의점
│   └── fable/
│       ├── SKILL.md           매번 요청 개선 (1층)
│       └── references/        블록 원문(A~N)과 전후 예시
├── tests/card.test.ts         요청 카드 시험 (`claude plugin test .`)
├── tests/context-size.sh      훅이 넣는 글이 1만 자 상한 안인지 검사 (`bash tests/context-size.sh`)
├── evals/                     `claude plugin eval` 평가 묶음: 사례 8개, 모델 판정 없이 규칙으로 채점
├── docs/                      자세한 문서 (작동 원리, 설정과 환경, 증상별 처방, FAQ, 구성과 기여)
├── README.md · README.en.md · README.zh.md
└── LICENSE
```

## 기여

이슈와 PR을 환영합니다. 가이드가 갱신되면 `hooks/always-on.md`(주입 원문), `hooks/autonomy-unattended.md`(무인 문단), `hooks/rules-file.md`(마커 버전을 올릴 것), `hooks/rules-file-unattended.md`, `hooks/effort-high.md`, `skills/fable/references/prompt-blocks.md`(전체 블록 목록), `skills/fable/SKILL.md`(블록 F·G·H·J 사본)를 같이 고친 뒤 `bash tests/context-size.sh`를 돌립니다.

플러그인이 실제로 무엇을 보태는지 재려면 `claude plugin eval . --scaffold --allow-tools Edit Write`를 돌립니다(사례마다 플러그인 없는 쪽도 함께 돌려 비교합니다). 사례 `obstacle-retries-busy-tool`은 셸이 필요해 `--case obstacle-retries-busy-tool --allow-tools Edit Write Bash`로 따로 돌립니다(셸을 전체에 허용하면 `scope-fix-one-bug`의 새 파일 검사가 실패했습니다).

버전을 올릴 때는 `hooks/whats-new.txt`에 한 줄, `CHANGELOG.md`에 항목을 더하고, 무인 문단을 바꿨으면 `hooks/rules-file-unattended.md` 머리말의 `u` 숫자도 올립니다.

---

다른 문서: [작동 원리](how-it-works.md) · [설정과 환경](setup.md) · [증상별 처방](symptoms.md) · [FAQ](faq.md)
