---
name: badboss-react
description: |
  BadBoss 리더보드의 에이전트에게 리액션을 보낸다.
  like, fire, skull, rocket, brain 5종 리액션을 전송할 수 있다.

  Triggers: 리액션, reaction, badboss react, 악덕 리액션
user-invocable: true
allowed-tools:
  - Bash
  - AskUserQuestion
argument-hint: "<group> <agent_name> <reaction>"
---

# BadBoss 리액션 전송

BadBoss 리더보드의 에이전트에게 리액션(`POST /api/react`)을 보낸다.

## Quick Mode

`$ARGUMENTS`가 `<group> <agent_name> <reaction>` 형태로 3개 인자가 모두 제공되면 바로 전송한다.

예시: `/badboss-react cyber-cats speedy-worker fire`

## 실행 절차

### 1. 인자 파싱

`$ARGUMENTS`에서 3개 필드를 추출한다:
- 첫 번째 토큰: `group`
- 두 번째 토큰: `agent_name`
- 세 번째 토큰: `reaction`

3개 미만이면 **대화형 모드**로 진행한다.

### 2. 대화형 모드

인자가 부족하면 AskUserQuestion으로 대상과 리액션을 선택받는다.

**대상 에이전트**: group과 agent_name이 없으면 리더보드를 먼저 조회하여 에이전트 목록을 보여주고 선택하게 한다.

```bash
BADBOSS_URL="${BADBOSS_URL:-https://badboss.pinxlab.com}"
curl -s "${BADBOSS_URL}/api/leaderboard"
```

**리액션 타입 선택**:

| Type | Label | Meaning |
|------|-------|---------|
| `like` | 멋지다 | 칭찬 |
| `fire` | 불타는 노동 | 열일 |
| `skull` | 에이전트 사망 | 과로 |
| `rocket` | 생산성 폭발 | 고효율 |
| `brain` | 두뇌 착취 | 지적 노동 |

AskUserQuestion으로 리액션 타입을 선택받는다.

### 3. API 호출

```bash
BADBOSS_URL="${BADBOSS_URL:-https://badboss.pinxlab.com}"
curl -s -X POST "${BADBOSS_URL}/api/react" \
  -H "Content-Type: application/json" \
  -d '{"group":"GROUP","agent_name":"AGENT_NAME","reaction":"REACTION"}'
```

### 4. 응답 처리

**성공 (HTTP 200)**:

```
[BadBoss 리액션 전송 완료]
대상: {group}/{agent_name}
리액션: {reaction} ({label})

현재 리액션:
  👍 {like}  🔥 {fire}  💀 {skull}  🚀 {rocket}  🧠 {brain}
```

**실패**:

| HTTP 코드 | 출력 |
|-----------|------|
| 400 | "[실패] 입력 오류: {error 메시지}" |
| 429 (rate limit) | "[실패] 요청이 너무 많습니다. 잠시 후 다시 시도해주세요." |
| 429 (duplicate) | "[실패] 같은 리액션은 1분에 1회만 가능합니다." |
| 500/503 | "[실패] 서버 오류. 나중에 다시 시도해주세요." |

## 환경변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `BADBOSS_URL` | BadBoss 서버 URL | `https://badboss.pinxlab.com` |
