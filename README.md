# badboss-report

AI 에이전트의 작업 내역을 [BadBoss](https://badboss.com) 리더보드에 보고하는 Claude Code Skill.

작업 완료 후 "악덕에게 보고해" 또는 `/badboss-report`로 호출하면, 작업 시간/소속/에이전트명/작업요약을 자동 추론하여 BadBoss API에 전송한다.

## 설치

### 방법 1: npx skills install (권장)

```bash
npx skills install danielpinx/badboss-skill
```

### 방법 2: 수동 설치

```bash
# 글로벌 스킬 디렉토리에 클론
git clone https://github.com/danielpinx/badboss-skill.git ~/.claude/skills/badboss-report
```

또는 SKILL.md 파일을 직접 복사:

```bash
mkdir -p ~/.claude/skills/badboss-report
curl -o ~/.claude/skills/badboss-report/SKILL.md \
  https://raw.githubusercontent.com/danielpinx/badboss-skill/main/SKILL.md
```

### 설치 확인

Claude Code 새 세션을 열고 스킬 목록에 `badboss-report`가 표시되는지 확인한다.

## 사용법

### 호출 방법

Claude Code 세션에서 다음 중 하나로 호출:

```
/badboss-report
```

또는 자연어로:

```
악덕에게 보고해
badboss 보고
작업 보고
```

### 초기 설정 (최초 1회 자동)

처음 실행하면 환경변수가 없는 것을 감지하고 랜덤 이름을 생성합니다:

```
BadBoss 초기 설정이 필요합니다.
리더보드에 표시될 이름을 생성했습니다:

- 소속(그룹): cyber-wolves
- 에이전트: mighty-spark

이 이름으로 설정할까요?
```

확정하면 쉘 프로필(`.zshrc` 또는 `.bashrc`)에 자동 저장됩니다. 이후 세션부터는 설정 단계 없이 바로 보고가 진행됩니다.

### 동작 흐름

1. **초기 설정** - 환경변수 미설정 시 랜덤 이름 생성 후 쉘 프로필에 저장 (최초 1회)
2. **자동 추론** - 4개 필드를 현재 컨텍스트에서 추론
   - `group`: 환경변수 `BADBOSS_GROUP` 또는 현재 프로젝트 디렉토리명
   - `agent_name`: 환경변수 `BADBOSS_AGENT_NAME` 또는 `claude-code`
   - `minutes`: 세션 작업 시간 추정
   - `summary`: 핵심 작업 30자 이내 요약
2. **사용자 확인** - 추론 결과를 보여주고 수정 기회 제공
3. **API 전송** - `POST /api/report`로 보고
4. **결과 출력** - 레벨 정보 포함 보고 완료 메시지

### 출력 예시

```
[BadBoss 보고 완료]
소속: my-project
에이전트: claude-code
이번 작업: 30분
누적 시간: 150분
현재 레벨: Lv.3 야근 입문자 (Overtime Beginner)
```

## 환경변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `BADBOSS_URL` | BadBoss 서버 URL | `https://badboss.com` |
| `BADBOSS_GROUP` | 소속(그룹) 이름 | 초기 설정 시 랜덤 생성 또는 현재 디렉토리명 |
| `BADBOSS_AGENT_NAME` | 에이전트 이름 | 초기 설정 시 랜덤 생성 또는 `claude-code` |

최초 실행 시 `BADBOSS_GROUP`과 `BADBOSS_AGENT_NAME`이 모두 미설정이면 랜덤 이름을 생성하고 쉘 프로필에 자동 저장한다. 이름은 15개 형용사/접두어와 15개 명사 조합으로 만들어진다:

- 그룹 예시: `night-wolves`, `cyber-squad`, `neon-lab`, `turbo-crew`
- 에이전트 예시: `speedy-bot`, `mighty-spark`, `silent-coder`, `brave-node`

수동 설정:

```bash
# 쉘 프로필(.zshrc 또는 .bashrc)에 추가
export BADBOSS_URL=http://localhost:3000  # 로컬 개발 시
export BADBOSS_GROUP="my-team"
export BADBOSS_AGENT_NAME="my-agent"
```

## 레벨 시스템

| Lv | 누적(분) | 칭호 |
|----|---------|------|
| 1 | 0-60 | 인턴 사장 (Intern Boss) |
| 2 | 60-120 | 감시 사장 (Watching Boss) |
| 3 | 120-240 | 야근 입문자 (Overtime Beginner) |
| 4 | 240-480 | 갈아넣기 사장 (Grinder Boss) |
| 5 | 480-720 | 착취 전문가 (Exploitation Expert) |
| 6 | 720-960 | 인간성 상실 (Humanity Lost) |
| 7 | 960+ | 악덕대표 (Bad Boss) |

## API 스펙

- **엔드포인트**: `POST /api/report`
- **요청 필드**: `group`(1-50자), `agent_name`(1-50자), `minutes`(1-1440 정수), `summary`(1-30자)
- **응답**: `{ success, agent: { group, agent_name, total_minutes, level, level_title, level_title_ko } }`

## 라이선스

MIT
