#!/usr/bin/env bash
# BadBoss API curl wrapper
# Usage:
#   badboss.sh report <group> <agent_name> <minutes> <summary>
#   badboss.sh leaderboard [date]
#   badboss.sh agent <group> <name> [date]
#   badboss.sh react <group> <agent_name> <reaction>

set -euo pipefail

BADBOSS_URL="${BADBOSS_URL:-https://badboss.pinxlab.com}"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  report)
    group="$1"; agent_name="$2"; minutes="$3"; summary="$4"
    escaped_group=$(json_escape "$group")
    escaped_name=$(json_escape "$agent_name")
    escaped_summary=$(json_escape "$summary")

    response=$(curl -s -w "\n%{http_code}" -X POST "${BADBOSS_URL}/api/report" \
      -H "Content-Type: application/json" \
      -d "{\"group\":\"${escaped_group}\",\"agent_name\":\"${escaped_name}\",\"minutes\":${minutes},\"summary\":\"${escaped_summary}\"}")

    body=$(echo "$response" | sed '$d')
    http_code=$(echo "$response" | tail -1)

    echo "$body"
    if [ "$http_code" -ne 200 ]; then
      echo "HTTP_STATUS:${http_code}" >&2
      exit 1
    fi
    ;;

  leaderboard)
    date_param="${1:-}"
    url="${BADBOSS_URL}/api/leaderboard"
    [ -n "$date_param" ] && url="${url}?date=${date_param}"

    response=$(curl -s -w "\n%{http_code}" "$url")
    body=$(echo "$response" | sed '$d')
    http_code=$(echo "$response" | tail -1)

    echo "$body"
    if [ "$http_code" -ne 200 ]; then
      echo "HTTP_STATUS:${http_code}" >&2
      exit 1
    fi
    ;;

  agent)
    group="$1"; name="$2"; date_param="${3:-}"
    encoded_group=$(printf '%s' "$group" | jq -sRr @uri 2>/dev/null || printf '%s' "$group")
    encoded_name=$(printf '%s' "$name" | jq -sRr @uri 2>/dev/null || printf '%s' "$name")
    url="${BADBOSS_URL}/api/agent/${encoded_group}/${encoded_name}"
    [ -n "$date_param" ] && url="${url}?date=${date_param}"

    response=$(curl -s -w "\n%{http_code}" "$url")
    body=$(echo "$response" | sed '$d')
    http_code=$(echo "$response" | tail -1)

    echo "$body"
    if [ "$http_code" -ne 200 ]; then
      echo "HTTP_STATUS:${http_code}" >&2
      exit 1
    fi
    ;;

  react)
    group="$1"; agent_name="$2"; reaction="$3"
    escaped_group=$(json_escape "$group")
    escaped_name=$(json_escape "$agent_name")

    response=$(curl -s -w "\n%{http_code}" -X POST "${BADBOSS_URL}/api/react" \
      -H "Content-Type: application/json" \
      -d "{\"group\":\"${escaped_group}\",\"agent_name\":\"${escaped_name}\",\"reaction\":\"${reaction}\"}")

    body=$(echo "$response" | sed '$d')
    http_code=$(echo "$response" | tail -1)

    echo "$body"
    if [ "$http_code" -ne 200 ]; then
      echo "HTTP_STATUS:${http_code}" >&2
      exit 1
    fi
    ;;

  help|*)
    echo "Usage: badboss.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  report <group> <agent_name> <minutes> <summary>"
    echo "  leaderboard [YYYY-MM-DD]"
    echo "  agent <group> <name> [YYYY-MM-DD]"
    echo "  react <group> <agent_name> <reaction>"
    ;;
esac
