# Contributing to BadBoss Skill

## Gitflow

```
feature/* ──→ develop ──→ main
              (CI 필수)    (릴리스)
```

### 브랜치 전략

| 브랜치 | 용도 | 머지 대상 |
|--------|------|----------|
| `main` | 안정 릴리스 | - |
| `develop` | 통합 브랜치 | `main` |
| `feature/*` | 기능 개발 | `develop` |
| `fix/*` | 버그 수정 | `develop` |
| `hotfix/*` | 긴급 수정 | `main` + `develop` |

### 워크플로우

1. **feature 브랜치 생성**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/my-feature
   ```

2. **작업 + progress.md 업데이트**
   - `docs/progress.md`에서 Backlog → In Progress로 이동
   - 작업 수행

3. **Pre-PR 품질 검증**
   ```bash
   # Shell script syntax
   bash -n badboss-report/scripts/badboss.sh
   bash -n badboss-report/scripts/commit-detect.sh

   # YAML frontmatter 확인
   head -20 badboss-report/SKILL.md

   # 파일 구조 확인
   find badboss-report badboss-status badboss-react -type f
   ```

4. **커밋 + PR**
   ```bash
   git add <files>
   git commit -m "feat: 기능 설명"
   git push origin feature/my-feature
   ```

   PR 생성 시 **반드시 HEREDOC**으로 body를 작성한다 (인라인 금지):
   ```bash
   gh pr create --base develop --title "feat: 기능 설명" \
     --body "$(cat <<'PRBODY'
   ## 요약
   <2-3줄: 무엇을 + 왜 변경했는지>

   ## 변경 사항

   ### 핵심 변경
   - `파일경로`: 변경 내용 — AS-IS → TO-BE
     - 근거: 한 줄 설명

   ### 부수 변경
   없음

   ### 문서/설정 변경
   - `docs/progress.md`: 칸반 상태 갱신

   ## 영향 범위
   - **영향받는 스킬**: badboss-report
   - **하위 호환성**: 유지
   - **API 스펙 변경**: 없음

   ## 설계 판단
   단순 수정, 설계 판단 불필요

   ## Pre-PR Quality Gate
   - [x] `bash -n` 스크립트 문법 — 0 errors
   - [x] YAML frontmatter 필수 필드 확인
   - [x] 기본 URL 일관성 확인
   - [x] `docs/progress.md` 갱신됨

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   PRBODY
   )"
   ```

   > **금지**: `gh pr create --body "한 줄 요약"` — 줄바꿈 깨짐, 정보량 손실

5. **CI 통과 확인** → 머지
   ```bash
   gh pr checks --watch   # CI 전체 통과 대기 (필수)
   ```
   - progress.md: In Progress → Done

### 커밋 메시지 규약

```
<type>: <설명>

<본문 (선택)>
```

| Type | 용도 |
|------|------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `ci` | CI/CD 변경 |
| `refactor` | 코드 정리 |
| `chore` | 기타 |

### CI 래칫

PR 머지 전 반드시 CI 전체 통과 필요:

| Job | 검증 내용 |
|-----|----------|
| **lint** | 스킬 구조 + YAML frontmatter + URL 일관성 |
| **shell** | bash -n + ShellCheck |
| **markdown** | 상대 링크 유효성 + SKILL.md 300줄 제한 |
| **gate** | 전체 통과 집계 |

### 래칫 규칙

- 스킬 파일 수 ≥ 8 (삭제 시 정당화 필요)
- SKILL.md 300줄 이하 (초과 시 references/로 분리)
- 모든 스크립트 실행 권한 필수 (chmod +x)
- YAML frontmatter 필수 필드: name, description, user-invocable, allowed-tools
