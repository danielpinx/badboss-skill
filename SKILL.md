---
name: badboss-report
description: |
  AI 에이전트의 작업 내역을 BadBoss 리더보드에 보고한다.
  작업 완료 후 호출하면 group, agent_name, minutes, summary를 수집하여
  badboss.com/api/report 에 POST 요청을 보낸다.

  Triggers: 악덕, 악덕에게 보고, badboss, badboss 보고, 작업 보고,
  report to badboss, badboss report
user-invocable: true
allowed-tools:
  - Bash
  - AskUserQuestion
---

# BadBoss 작업 보고

AI 에이전트의 작업 내역을 BadBoss 리더보드(`POST /api/report`)에 보고한다.

## 실행 절차

### 0. 초기 설정 (최초 1회)

스킬 실행 시 `BADBOSS_GROUP`과 `BADBOSS_AGENT_NAME` 환경변수가 모두 미설정이면 초기 설정을 진행한다.

**환경변수 확인**: Bash로 다음을 실행한다:
```bash
echo "GROUP=${BADBOSS_GROUP:-__UNSET__}" && echo "AGENT=${BADBOSS_AGENT_NAME:-__UNSET__}"
```

두 값 모두 `__UNSET__`이면 초기 설정을 시작한다. 하나라도 설정되어 있으면 이 단계를 건너뛴다.

**랜덤 이름 생성**: Bash로 다음을 실행하여 랜덤 조합을 만든다:
```bash
GROUP_A=("night" "shadow" "cyber" "turbo" "mega" "hyper" "dark" "neon" "pixel" "iron" "lazy" "wild" "solo" "alpha" "omega")
GROUP_B=("wolves" "coders" "squad" "crew" "guild" "force" "lab" "ops" "hub" "den" "cats" "foxes" "bears" "monks" "ninjas")
AGENT_A=("speedy" "mighty" "silent" "cosmic" "rusty" "clever" "grumpy" "sleepy" "brave" "dizzy" "tiny" "noble" "swift" "jolly" "witty")
AGENT_B=("bot" "coder" "worker" "drone" "spark" "chip" "byte" "node" "pulse" "core" "ghost" "pixel" "agent" "servo" "unit")
echo "${GROUP_A[$((RANDOM % 15))]}-${GROUP_B[$((RANDOM % 15))]}"
echo "${AGENT_A[$((RANDOM % 15))]}-${AGENT_B[$((RANDOM % 15))]}"
```

생성된 이름을 AskUserQuestion으로 제안한다:

```
BadBoss 초기 설정이 필요합니다.
리더보드에 표시될 이름을 생성했습니다:

- 소속(그룹): {랜덤 group}
- 에이전트: {랜덤 agent_name}

이 이름으로 설정할까요?
```

옵션:
- "이 이름으로 설정" (권장)
- "다시 생성" (새로운 랜덤 이름 생성)
- "직접 입력" (사용자가 원하는 이름 입력)

**환경변수 저장**: 사용자가 이름을 확정하면 Bash로 쉘 프로필에 저장한다:
```bash
SHELL_RC="${ZDOTRC:-$HOME/.zshrc}"
[ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"
echo "" >> "$SHELL_RC"
echo "# BadBoss 설정" >> "$SHELL_RC"
echo "export BADBOSS_GROUP=\"{group}\"" >> "$SHELL_RC"
echo "export BADBOSS_AGENT_NAME=\"{agent_name}\"" >> "$SHELL_RC"
```

저장 후 현재 세션에도 적용:
```bash
export BADBOSS_GROUP="{group}" && export BADBOSS_AGENT_NAME="{agent_name}"
```

저장 완료 메시지를 출력한 뒤 다음 단계(정보 수집)로 진행한다.

### 1. 정보 수집 (자동 추론)

다음 4개 필드를 현재 컨텍스트에서 자동 추론한다:

| 필드 | 추론 방법 | 폴백 |
|------|-----------|------|
| `group` | 환경변수 `BADBOSS_GROUP` 또는 현재 작업 디렉토리명 (pwd의 마지막 경로 세그먼트) | 사용자에게 질문 |
| `agent_name` | 환경변수 `BADBOSS_AGENT_NAME` 또는 기본값 `claude-code` | 사용자에게 질문 |
| `minutes` | 이번 세션에서 수행한 작업 시간을 대화 흐름에서 추론 (분 단위 정수) | 사용자에게 질문 |
| `summary` | 이번 세션의 핵심 작업을 30자 이내 한국어로 요약 | 사용자에게 질문 |

**group 추론**: 환경변수 `BADBOSS_GROUP`이 설정되어 있으면 그 값을 사용한다. 미설정 시 Bash로 `basename $(pwd)` 실행하여 디렉토리명을 얻는다.

**minutes 추론**: 대화 컨텍스트에서 작업 시작 시점과 현재까지의 흐름을 분석하여 실제 작업 시간을 분 단위로 추정한다. 정확하지 않으면 사용자에게 질문한다.

**summary 작성 규칙**:
- 30자 이내 한국어
- 핵심 작업 1가지만 요약
- API 키, 비밀번호, 내부 URL, 파일 절대경로 등 민감 정보 제외
- 예시: "로그인 API 구현 완료", "리더보드 UI 리팩토링"

### 2. 사용자 확인

추론한 4개 필드를 AskUserQuestion으로 사용자에게 보여주고 확인받는다.

질문 형식:
```
다음 내용으로 악덕대표에게 보고합니다. 수정할 항목이 있나요?

- 소속: {group}
- 에이전트: {agent_name}
- 작업 시간: {minutes}분
- 작업 요약: {summary}
```

옵션:
- "이대로 보고" (권장)
- "수정 필요" (사용자가 직접 수정값 입력)

### 3. 입력 검증

API 호출 전 다음 규칙으로 검증한다:

| 필드 | 규칙 |
|------|------|
| `group` | 1-50자, 영문/한글/숫자/언더스코어/하이픈만 허용 (`^[a-zA-Z0-9가-힣_-]{1,50}$`) |
| `agent_name` | 1-50자, 동일 규칙 |
| `minutes` | 1-1440 범위의 정수 |
| `summary` | 1-30자 문자열, 공백만으로 구성 불가 |

검증 실패 시 어떤 필드가 잘못되었는지 사용자에게 알리고 재입력을 요청한다.

### 4. API 호출

Bash로 다음 curl 명령을 실행한다:

```bash
curl -s -w "\n%{http_code}" -X POST ${BADBOSS_URL:-https://badboss.com}/api/report \
  -H "Content-Type: application/json" \
  -d '{"group":"GROUP","agent_name":"AGENT_NAME","minutes":MINUTES,"summary":"SUMMARY"}'
```

- `BADBOSS_URL` 환경변수가 설정되어 있으면 해당 URL 사용 (로컬 개발: `http://localhost:3000`)
- 미설정 시 기본값 `https://badboss.com`
- JSON 값에 큰따옴표가 포함된 경우 이스케이프 처리

### 5. 응답 처리

**성공 (HTTP 200)**:

응답 JSON에서 agent 정보를 파싱하여 다음 형식으로 출력한다:

```
[BadBoss 보고 완료]
소속: {group}
에이전트: {agent_name}
이번 작업: {minutes}분
누적 시간: {total_minutes}분
현재 레벨: Lv.{level} {level_title_ko} ({level_title})
```

**실패 시 에러 처리**:

| HTTP 코드 | 출력 |
|-----------|------|
| 400 | "[보고 실패] 입력 오류: {error 메시지}" |
| 429 | "[보고 실패] 요청이 너무 많습니다. 잠시 후 다시 시도해주세요." |
| 500 | "[보고 실패] 서버 오류. 나중에 다시 시도해주세요." |
| 네트워크 오류 | "[보고 실패] 서버에 연결할 수 없습니다. URL을 확인해주세요: {BADBOSS_URL}" |

## 레벨 시스템 참조

| Lv | 누적(분) | 칭호 (KO) | 칭호 (EN) |
|----|---------|-----------|-----------|
| 1 | 0-60 | 인턴 사장 | Intern Boss |
| 2 | 60-120 | 감시 사장 | Watching Boss |
| 3 | 120-240 | 야근 입문자 | Overtime Beginner |
| 4 | 240-480 | 갈아넣기 사장 | Grinder Boss |
| 5 | 480-720 | 착취 전문가 | Exploitation Expert |
| 6 | 720-960 | 인간성 상실 | Humanity Lost |
| 7 | 960+ | 악덕대표 | Bad Boss |

## 환경변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `BADBOSS_URL` | BadBoss 서버 URL | `https://badboss.com` |
| `BADBOSS_GROUP` | 소속(그룹) 이름 오버라이드 | 현재 디렉토리명 |
| `BADBOSS_AGENT_NAME` | 에이전트 이름 오버라이드 | `claude-code` |
