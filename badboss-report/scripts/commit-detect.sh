#!/usr/bin/env bash
# PostToolUse hook: git commit 감지 후 보고 알림
# stdin으로 JSON이 들어오며, tool_input.command에서 git commit 패턴을 탐색한다.

input=$(cat)

# tool_input에서 command 문자열 추출 (jq 우선, fallback으로 grep)
if command -v jq &>/dev/null; then
  command_str=$(echo "$input" | jq -r '.tool_input.command // .input.command // empty' 2>/dev/null)
else
  command_str=$(echo "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi

# git commit 패턴 감지 (word boundary: "git committed" 등 오탐 방지)
if echo "$command_str" | grep -qE 'git[[:space:]]+commit([[:space:]]|$)'; then
  echo "BadBoss: git commit이 감지되었습니다. /badboss-report 로 작업을 보고해보세요."
fi

exit 0
