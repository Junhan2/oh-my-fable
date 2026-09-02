# fable-prompt · before/after samples

## 1. Change · "뭐 이거 뭐 어떻게 해줘" (context: user just pasted a tsc error from `apps/web/src/lib/pricing.ts`)

```
개선된 요청
목표: apps/web/src/lib/pricing.ts 의 tsc 오류(TS2345, 붙여넣은 전문)를 없애고 pnpm tsc --noEmit 이 0 오류로 끝나게 한다.
맥락: 오류 원문 그대로 포함. 관련 pitfall 없음.
범위: 이 파일과 그 타입이 정의된 파일만. 옆에서 보이는 다른 오류나 개선점은 고치지 말고 요약에 후속 과제로 적는다. 테스트는 이 저장소가 lib/ 변경에 테스트를 두는 경우에만, 이웃 파일 크기로.
완료 기준: pnpm tsc --noEmit 출력 0 errors, eslint 변경 파일 통과. 출력 원문을 보고에 붙인다.
effort: high
실행 방식 블록 A/B/C/D/E 포함.
```

## 2. Assessment · "왜 이거 자꾸 느려져?" (context: Next.js dev server)

Kind is Assessment, so the prompt ends at findings and includes the guide's exception sentence.

```
개선된 요청
목표: next dev 가 시간이 갈수록 느려지는 원인을 증거와 함께 밝힌다. 수정은 하지 않는다.
맥락: ~/Desktop/shell, Next 16, pnpm 모노레포. pitfall 2026-05-28-nextjs16-turbopack-pnpm-dev-ram-blowup 먼저 읽는다.
범위: 원인 후보 3개 이상, 각각 지지·반박 증거, 가장 유력한 것 하나와 확인 방법. 코드 변경 금지.
완료 기준: 증거(명령 출력, 파일:줄) 가 붙은 진단 보고 1개.
effort: high
실행 방식 블록 A(예외 문단 포함)/B/E 포함.
```

## 3. Research at low effort · "grok 4.6 요즘 가격 어때?"

Time-sensitive name, so block H is attached and effort is not lowered.

```
개선된 요청
목표: xAI Grok 4.6 의 현재 API 가격과 구독 요금을 출처 링크와 함께 정리한다.
범위: 사용자가 쓴 표기 "grok 4.6" 을 그대로 넣은 검색 1회 이상 포함. 기억으로 답하지 않는다.
완료 기준: 가격 표 1개, 각 행에 출처 URL과 확인 날짜.
effort: high (low 는 검색을 생략할 수 있어 제외)
실행 방식 블록 A/B/E/H 포함.
```
