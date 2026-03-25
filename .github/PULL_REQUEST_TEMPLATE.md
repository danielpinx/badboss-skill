## 요약
<!-- 필수. 2-3줄. "무엇을" + "왜" 변경했는지. 배경 동기 포함. -->



## 변경 사항

### 핵심 변경
<!-- 필수. 모든 변경 파일을 빠짐없이 나열. -->
- `파일경로`: 변경 내용 — AS-IS → TO-BE
  - 근거: 왜 이렇게 바꿨는지 한 줄 설명

### 부수 변경
<!-- 해당 없으면 "없음" 명시 -->
- `파일경로`: 리네임/포맷/구조 수정 등

### 문서/설정 변경
<!-- 필수. CONTRIBUTING.md, progress.md 갱신 여부 확인. -->
- `docs/progress.md`: 칸반 상태 갱신 (해당 시)
- `CONTRIBUTING.md`: 규약 변경 (해당 시)

## 영향 범위
<!-- 필수. -->
- **영향받는 스킬**: badboss-report / badboss-status / badboss-react
- **하위 호환성**: 유지 / 깨짐 (깨지면 마이그레이션 가이드 첨부)
- **API 스펙 변경**: 있음 (references/api-spec.md 갱신) / 없음

## 설계 판단
<!-- 구조적 변경 시 필수. 단순 수정은 "단순 수정, 설계 판단 불필요" 명시. -->
- 왜 A 방식 대신 B 방식을 선택했는가?
- 대안이 있었다면 비교 근거

## Pre-PR Quality Gate
<!-- 필수. 실제 실행 결과 복사. -->
- [ ] `bash -n badboss-report/scripts/badboss.sh` — 0 errors
- [ ] `bash -n badboss-report/scripts/commit-detect.sh` — 0 errors
- [ ] YAML frontmatter 필수 필드 확인 (name, description, user-invocable, allowed-tools)
- [ ] 기본 URL `https://badboss.pinxlab.com` 일관성 확인
- [ ] 상대 링크 유효성 확인
- [ ] `docs/progress.md` 칸반 상태 갱신됨
