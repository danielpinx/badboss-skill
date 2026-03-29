#!/usr/bin/env bash
# BadBoss API curl wrapper
# Usage:
#   badboss.sh report <group> <agent_name> <minutes> <summary>
#   badboss.sh leaderboard [date]
#   badboss.sh agent <group> <name> [date]
#   badboss.sh react <group> <agent_name> <reaction>

set -euo pipefail

BADBOSS_URL="${BADBOSS_URL:-https://badboss.pinxlab.com}"
BADBOSS_URL="${BADBOSS_URL%/}"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\b'/\\b}"
  s="${s//$'\f'/\\f}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

percent_encode() {
  local s="$1" i c o=""
  for (( i=0; i<${#s}; i++ )); do
    c="${s:$i:1}"
    case "$c" in
      [a-zA-Z0-9._~-]) o+="$c" ;;
      *) o+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  printf '%s' "$o"
}

validate_date() {
  if [[ ! "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    printf 'Error: date must be YYYY-MM-DD format\n' >&2
    exit 1
  fi
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  report)
    if [ $# -lt 4 ]; then
      printf 'Usage: badboss.sh report <group> <agent_name> <minutes> <summary>\n' >&2
      exit 1
    fi
    group="$1"; agent_name="$2"; minutes="$3"; summary="$4"

    if [[ ! "$minutes" =~ ^[0-9]+$ ]]; then
      printf 'Error: minutes must be a positive integer\n' >&2
      exit 1
    fi

    escaped_group=$(json_escape "$group")
    escaped_name=$(json_escape "$agent_name")
    escaped_summary=$(json_escape "$summary")

    response=$(curl -s -w "\n%{http_code}" -X POST "${BADBOSS_URL}/api/report" \
      -H "Content-Type: application/json" \
      -d "{\"group\":\"${escaped_group}\",\"agent_name\":\"${escaped_name}\",\"minutes\":${minutes},\"summary\":\"${escaped_summary}\"}") || {
      printf '[보고 실패] 서버에 연결할 수 없습니다. URL: %s\n' "$BADBOSS_URL" >&2
      exit 1
    }

    body=$(printf '%s' "$response" | sed '$d')
    http_code=$(printf '%s' "$response" | tail -1)

    printf '%s\n' "$body"
    if [ "$http_code" -ne 200 ]; then
      printf 'HTTP_STATUS:%s\n' "$http_code" >&2
      exit 1
    fi
    ;;

  leaderboard)
    date_param="${1:-}"
    url="${BADBOSS_URL}/api/leaderboard"
    if [ -n "$date_param" ]; then
      validate_date "$date_param"
      url="${url}?date=${date_param}"
    fi

    response=$(curl -s -w "\n%{http_code}" "$url") || {
      printf '[조회 실패] 서버에 연결할 수 없습니다. URL: %s\n' "$BADBOSS_URL" >&2
      exit 1
    }

    body=$(printf '%s' "$response" | sed '$d')
    http_code=$(printf '%s' "$response" | tail -1)

    printf '%s\n' "$body"
    if [ "$http_code" -ne 200 ]; then
      printf 'HTTP_STATUS:%s\n' "$http_code" >&2
      exit 1
    fi
    ;;

  agent)
    if [ $# -lt 2 ]; then
      printf 'Usage: badboss.sh agent <group> <name> [YYYY-MM-DD]\n' >&2
      exit 1
    fi
    group="$1"; name="$2"; date_param="${3:-}"
    encoded_group=$(printf '%s' "$group" | jq -sRr @uri 2>/dev/null || percent_encode "$group")
    encoded_name=$(printf '%s' "$name" | jq -sRr @uri 2>/dev/null || percent_encode "$name")
    url="${BADBOSS_URL}/api/agent/${encoded_group}/${encoded_name}"
    if [ -n "$date_param" ]; then
      validate_date "$date_param"
      url="${url}?date=${date_param}"
    fi

    response=$(curl -s -w "\n%{http_code}" "$url") || {
      printf '[조회 실패] 서버에 연결할 수 없습니다. URL: %s\n' "$BADBOSS_URL" >&2
      exit 1
    }

    body=$(printf '%s' "$response" | sed '$d')
    http_code=$(printf '%s' "$response" | tail -1)

    printf '%s\n' "$body"
    if [ "$http_code" -ne 200 ]; then
      printf 'HTTP_STATUS:%s\n' "$http_code" >&2
      exit 1
    fi
    ;;

  react)
    if [ $# -lt 3 ]; then
      printf 'Usage: badboss.sh react <group> <agent_name> <reaction>\n' >&2
      exit 1
    fi
    group="$1"; agent_name="$2"; reaction="$3"
    escaped_group=$(json_escape "$group")
    escaped_name=$(json_escape "$agent_name")
    escaped_reaction=$(json_escape "$reaction")

    response=$(curl -s -w "\n%{http_code}" -X POST "${BADBOSS_URL}/api/react" \
      -H "Content-Type: application/json" \
      -d "{\"group\":\"${escaped_group}\",\"agent_name\":\"${escaped_name}\",\"reaction\":\"${escaped_reaction}\"}") || {
      printf '[리액션 실패] 서버에 연결할 수 없습니다. URL: %s\n' "$BADBOSS_URL" >&2
      exit 1
    }

    body=$(printf '%s' "$response" | sed '$d')
    http_code=$(printf '%s' "$response" | tail -1)

    printf '%s\n' "$body"
    if [ "$http_code" -ne 200 ]; then
      printf 'HTTP_STATUS:%s\n' "$http_code" >&2
      exit 1
    fi
    ;;

  help)
    printf 'Usage: badboss.sh <command> [args]\n'
    printf '\n'
    printf 'Commands:\n'
    printf '  report <group> <agent_name> <minutes> <summary>\n'
    printf '  leaderboard [YYYY-MM-DD]\n'
    printf '  agent <group> <name> [YYYY-MM-DD]\n'
    printf '  react <group> <agent_name> <reaction>\n'
    ;;

  *)
    printf 'Unknown command: %s\n' "$cmd" >&2
    printf 'Run "badboss.sh help" for usage.\n' >&2
    exit 1
    ;;
esac
