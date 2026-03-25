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
   gh pr create --base develop --title "feat: 기능 설명" --body "..."
   ```

5. **CI 통과 확인** → 머지
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
