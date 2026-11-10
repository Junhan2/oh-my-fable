# FAQ

[← oh-my-fable](../README.md) · 한국어 · [English](faq.en.md) · [中文](faq.zh.md)

[설치와 제거](#설치와-제거) · [켜져 있는지 확인](#켜져-있는지-확인) · [화면에 보이는 것](#화면에-보이는-것) · [규칙과 설정](#규칙과-설정) · [모델](#모델) · [다른 실행 환경](#다른-실행-환경)

## 설치와 제거

### 왜 지금 바로 쓰려면 `/reload-plugins` 다음 `/clear` 인가요?

공식 문서 기준 두 명령은 하는 일이 다릅니다. `/reload-plugins`는 "플러그인, 스킬, 에이전트, 훅, MCP 서버를 재시작 없이 다시 로드"합니다([Plugins](https://code.claude.com/docs/en/plugins)). 규칙을 넣는 SessionStart 훅은 "새 세션(startup), 재개(resume), `/clear`, 압축(compact), 분기(fork)" 때만 실행됩니다([Hooks](https://code.claude.com/docs/en/hooks#sessionstart)). 즉 reload는 훅을 등록만 하고 실행하지 않으므로, 설치한 세션에서는 `/clear`로 한 번 실행시켜야 합니다. 새 세션을 열면 둘 다 필요 없습니다.

### 되돌리려면?

`/fable-setup remove` 가 설정 파일, 규칙 파일, CLAUDE.md 구간을 지웁니다. 그다음 `claude plugin uninstall oh-my-fable@oh-my-fable`. 잠시 끄기만 하려면 `~/.claude/oh-my-fable.json` 에 `{"enabled": false}`.

## 켜져 있는지 확인

### 지금 뭐가 켜져 있는지 보려면?

`/fable-status`. 플러그인 버전, 규칙 위치, 이 세션의 모드(자동 감지 근거 포함), effort, 규칙 파일 버전, CLAUDE.md 충돌을 표 하나로 보여 주고 아무것도 바꾸지 않습니다. 새 세션을 열 때도 같은 내용이 한 줄로 화면에 뜹니다(Claude의 문맥에는 들어가지 않음).

### `/plugin`에 oh-my-fable이 "Not used recently"로 나와요.

14일이 지나고 10세션 동안 기록된 사용이 없으면 붙는 표시이고, 공식 문서가 사용으로 세는 목록에 훅은 없습니다(plugins measure 문서). 그래서 `/fable`이나 다른 명령을 한동안 쓰지 않으면 나올 수 있습니다. 규칙을 넣는 훅은 세션마다 그대로 돌고, `/fable-status`로 확인할 수 있습니다.

## 화면에 보이는 것

### 요청 카드가 뭔가요? 끄려면?

`/fable`이 보여 주는 개선된 요청을 대화 속 카드로 그려 주는 기능입니다. Claude Code의 [mod](https://code.claude.com/docs/en/plugins/mods/overview)(Claude Code 안에서 실행되는 플러그인 코드)로 만들었고, 하는 일은 그 블록을 화면에 다시 그리는 것 하나입니다(`claude plugin validate`가 보여 주는 호출은 `$.ui.resolve`뿐). Claude가 읽는 내용과 저장되는 대화는 그대로이며, 글자가 나오는 동안에는 코드 블록으로 보이다가 그 답변 덩어리가 끝나면 카드로 바뀝니다.

터미널에서는 Claude Code 2.1.287 이상에서 그려지며 2.1.292에서 확인했습니다. 데스크톱 앱에서도 그려지며(Claude Code 2.1.289가 내장된 앱에서 확인), VS Code 확장 창·`claude -p`·2.1.287보다 낮은 버전에서는 지금처럼 코드 블록으로 보입니다.

Claude Code 2.1.290에 mod가 라틴 문자가 아닌 여러 줄 글을 그릴 때 화면이 멈칫하던 문제의 수정이, 2.1.295에 마지막으로 알려진 카드 문제의 수정이 들어갔으니 2.1.295 이상을 권합니다. 끄려면 `/config`에서 `Improved request card`를 끄거나(세션을 다시 시작하지 않아도 바로 적용됩니다) `/plugin` → oh-my-fable → Configure options. 설치할 때부터 끄려면 `claude plugin install oh-my-fable@oh-my-fable --config card=false`.

### 세션을 열 때마다 뜨는 한 줄을 끄려면?

`/config`에서 oh-my-fable의 `Status line at session start`를 끄세요. 꺼도 설치 뒤 첫 세션의 안내, 업데이트 뒤 무엇이 바뀌었는지 한 줄, 조치가 필요한 알림은 나옵니다.

## 규칙과 설정

### CLAUDE.md에 이미 비슷한 규칙이 있으면?

`/fable-setup`이 표로 짚어 줍니다. 같은 뜻이면 "이미 있음", 반대 뜻(서식 금지, 마지막에 한꺼번에 보고)이면 바꿔 넣을 문장을 제안합니다. 실제 수정은 사용자가 합니다. Claude Code가 AI의 CLAUDE.md 자기 수정을 막기 때문입니다.

### 규칙을 CLAUDE.md 말고 다른 곳에 두고 싶어요.

기본값에서는 규칙이 플러그인 안에만 있고 훅이 세션마다 넣으므로 CLAUDE.md도 규칙 파일도 만들지 않습니다. 권장하는 설정은 규칙 파일(`/fable-setup rules-file`)입니다. Claude Code 훅 문서가 바뀌지 않는 규칙은 훅 텍스트보다 파일에 두라고 하고, 에이전트 팀도 이 파일을 읽습니다. CLAUDE.md 구간은 세 번째 선택지입니다. 비교표는 [규칙 위치 바꾸기](setup.md#규칙-위치-바꾸기)에 있습니다.

### `/fable-audit`와 `/doctor prompt-audit`는 뭐가 다른가요?

묻는 방향이 반대입니다. `/fable-audit`는 내 규칙에 프롬프팅 가이드의 어떤 절이 빠졌는지(더할 것)를 찾고, Claude Code의 `/doctor prompt-audit`(2.1.283 이상)는 내 규칙에서 낡았거나 틀렸거나 서로 부딪히는 문구(지울 것)를 찾습니다. 둘 다 스스로 고치지 않으니, 설정을 정리할 때는 둘 다 돌리세요.

## 모델

### Opus 5.5에서도 되나요?

됩니다. 지금 Claude Code의 기본 모델이 Opus 5.5라 2.2.0부터 두 모델을 함께 기준으로 삼습니다. 끝까지 하기·범위 제한·진행 보고는 두 가이드가 같은 말을 하고, 무인 세션의 "중간 보고로 멈추지 말라" 문단(블록 M)은 Opus 5.5 가이드에서 왔습니다.

서식 규칙·부분 편집·도구 일괄 호출은 Fable 5.1 가이드에서 온 것이라 Opus 5.5에서는 효과가 작을 수 있지만 해는 없습니다. Sonnet 5.5, Haiku 5.5, Opus 5, Sonnet 5도 마찬가지입니다. Sonnet 5.5와 Haiku 5.5도 Claude Code에서 `medium` effort로 시작하고 사용자 설정의 전역 `effortLevel`을 무시하며, 상태 줄이 그 사실을 보여 줍니다.

Haiku 5.5에서는 `/fable`이 블록 H 대신 그 가이드의 검색 문구를 씁니다. Fable 5.2도 `medium`으로 시작하고 같은 전역 값을 무시합니다. 그 가이드에서 온 블록 O는 무인 세션과 서브에이전트에 들어가고, 블록 P·Q는 `/fable`이 요청에 따라 붙입니다.

## 다른 실행 환경

### 플러그인을 못 까는 헤드리스 전용 환경(별도 CLAUDE_CONFIG_DIR, CI)은?

`hooks/rules-file-unattended.md`를 그 환경의 `rules/oh-my-fable.md`로 복사(또는 이 저장소 체크아웃에 심링크)하면 플러그인 없이 무인 규칙 전체가 실립니다. 링크는 그 환경의 사용자 단위 `rules/` 폴더에 두세요. 프로젝트의 `.claude/rules/` 안에서 프로젝트 밖을 가리키는 링크는 승인을 받아야 읽힙니다(memory 문서). 훅은 이 파일을 사용자 관리 파일로 보고 조용합니다.

### 클라우드 세션과 예약 실행(routine)에서는?

내 컴퓨터에서 켠 플러그인은 클라우드 세션(claude.ai/code)과 예약 실행에서 돌지 않습니다. 저장소에 커밋된 것만 클론과 함께 따라가며, `.claude/rules/`도 그중 하나입니다(cloud environments 문서). `hooks/rules-file-unattended.md`를 `.claude/rules/oh-my-fable.md`로 커밋하세요.

예약 실행은 승인 질문 없이 돌기 때문에 무인용 판이 맞습니다. `/fable`과 요청 카드는 그곳에서 쓸 수 없습니다.

### `omitClaudeMd: true`인 서브에이전트도 규칙을 받나요?

규칙 파일이나 CLAUDE.md로는 받지 못합니다. Claude Code 2.1.284에서 재 보니 `omitClaudeMd: true`인 사용자 정의 서브에이전트는 `~/.claude/rules/*.md`, 프로젝트의 `.claude/rules/*.md`, CLAUDE.md를 하나도 보지 못했고, 같은 에이전트에서 이 설정만 뺀 쪽은 셋 다 봤습니다.

훅은 이런 에이전트를 구별할 수 없어서(SubagentStart 입력에는 에이전트 종류만 옴) 훅만 방식이면 다른 서브에이전트처럼 짧은 판을 받고, 다른 방식이면 이 플러그인에서 아무것도 받지 않습니다. 가벼운 문맥이라는 이 설정의 취지와 맞으니, 꼭 닿아야 하는 규칙은 그 에이전트의 프롬프트에 넣으세요.

### API나 Agent SDK로 직접 붙이는 경우는?

`/fable-setup`은 질문 도구가 필요해 SDK에서는 `auto` 인자만 됩니다. 가장 간단한 방법은 `hooks/always-on.md` 내용을 시스템 프롬프트에 그대로 붙이는 것입니다. 3층의 API 항목(thinking.display 등)은 그쪽 설정입니다.

---

다른 문서: [작동 원리](how-it-works.md) · [설정과 환경](setup.md) · [증상별 처방](symptoms.md) · [구성과 기여](contributing.md)
