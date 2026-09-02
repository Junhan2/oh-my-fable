# fable-prompt · before/after samples

Only the four fields plus conditional lines. Never repeat the always-on blocks; the plugin hook (or the user's
rules file) already carries them. No effort line.

## 1. Change · "로그인 버튼 눌러도 아무 반응 없어 고쳐줘" (context: React app, console error pasted)

```
개선된 요청
목표: 로그인 버튼을 누르면 /api/login 이 호출되고, 성공하면 /dashboard 로 이동하게 한다.
맥락: src/components/LoginButton.tsx, 브라우저 콘솔 오류 원문 "TypeError: onSubmit is not a function". 어제 인증 방식을 바꾼 커밋 a1b2c3 이후 생김.
범위: 이 버튼과 그 핸들러만. 옆의 회원가입 폼이나 다른 오류는 고치지 말고 후속 과제로 보고.
완료 기준: 실제 클릭을 재현해 /dashboard 이동 확인, 콘솔 오류 0, 변경 파일 목록 첨부.
```

## 2. Assessment · "왜 이거 자꾸 느려져?" (context: Next.js dev server)

```
개선된 요청
목표: next dev 가 시간이 갈수록 느려지는 원인을 증거와 함께 밝힌다. 수정은 하지 않는다.
맥락: ~/Desktop/app, Next 16, pnpm 모노레포.
범위: 원인 후보 3개 이상, 각각 지지·반박 증거, 가장 유력한 것 하나와 확인 방법. 코드 변경 금지.
완료 기준: 증거(명령 출력, 파일:줄)가 붙은 진단 보고 1개.
```

## 3. Research · "grok 4.6 요즘 가격 어때?" (time-sensitive, so block H is attached)

```
개선된 요청
목표: xAI Grok 4.6 의 현재 API 가격과 구독 요금을 출처 링크와 함께 정리한다.
맥락: 없음.
범위: 사용자가 쓴 표기 "grok 4.6" 을 그대로 넣은 검색 1회 이상 포함. 기억으로 답하지 않는다.
완료 기준: 가격 표 1개, 각 행에 출처 URL과 확인 날짜.
+ block H
```
