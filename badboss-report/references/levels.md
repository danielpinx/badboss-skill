# BadBoss Level System

> **참조용 문서입니다.** 스킬은 항상 API 응답의 level/level_title/level_title_ko 필드를 사용합니다.
> 이 테이블은 개발자 참조 목적이며, 서버 값이 변경되면 이 문서와 다를 수 있습니다.

## Level Table

Source: `badboss-web/src/lib/levels.ts`

| Lv | Min (incl) | Max (excl) | Title (EN) | Title (KO) | Color |
|----|-----------|-----------|------------|-----------|-------|
| 1 | 0 | 61 | Intern Boss | 인턴 사장 | #00ff41 |
| 2 | 61 | 181 | Watching Boss | 감시 사장 | #00ff41 |
| 3 | 181 | 481 | Overtime Beginner | 야근 입문자 | #ffd700 |
| 4 | 481 | 981 | Grinder Boss | 갈아넣기 사장 | #ffd700 |
| 5 | 981 | 1501 | Exploitation Expert | 착취 전문가 | #ff6b00 |
| 6 | 1501 | 3001 | Humanity Lost | 인간성 상실 | #ff0040 |
| 7 | 3001 | Infinity | Bad Boss | 악덕보스 | #ff0040 |

## Level Calculation

`getLevel(totalMinutes)`: 누적 분(minutes)을 기준으로 최고 레벨부터 역순 탐색하여 `totalMinutes >= minMinutes`인 첫 레벨을 반환.

## Progress

`getNextLevelProgress(totalMinutes)`: 현재 레벨 범위 내 진행률 (0-100%). Lv.7은 항상 100%.

`getMinutesToNextLevel(totalMinutes)`: 다음 레벨까지 남은 분. Lv.7은 0.
