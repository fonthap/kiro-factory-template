#!/bin/bash
# Kiro Factory — Trace Viewer (compact)
# Usage: factory-trace.sh [last|all|TRACE_PREFIX] [DATE]
#   factory-trace.sh              # last trace, today
#   factory-trace.sh all          # all traces, today
#   factory-trace.sh a1b2         # trace matching prefix
#   factory-trace.sh all 2026-04-25

LOG_DIR="$HOME/.kiro/logs/factory"
MODE="${1:-last}"
DATE="${2:-$(date +%Y-%m-%d)}"
LOG="$LOG_DIR/$DATE.jsonl"

[ ! -f "$LOG" ] && echo "No logs for $DATE" && exit 0

ALL=$(grep -oE '"trace_id":"[^"]*"' "$LOG" | sed 's/"trace_id":"//;s/"//' | awk '!seen[$0]++')

if [ "$MODE" = "last" ]; then
  SEL=$(echo "$ALL" | tail -1)
elif [ "$MODE" = "all" ]; then
  SEL="$ALL"
else
  SEL=$(echo "$ALL" | grep "^$MODE")
fi

[ -z "$SEL" ] && echo "No matching traces" && exit 0

CN=$(echo "$SEL" | wc -l | tr -d ' ')
TN=$(echo "$ALL" | wc -l | tr -d ' ')
echo "-- $DATE ($CN/$TN traces) --"

for TR in $SEL; do
  TID=$(echo "$TR" | cut -c1-8)
  EVTS=$(grep "\"trace_id\":\"$TR\"" "$LOG")
  T0=$(echo "$EVTS" | head -1 | sed 's/.*"ts":"//;s/".*//' | sed 's/.*T//;s/+.*//' | cut -c1-8)
  TF=$(echo "$EVTS" | tail -1 | sed 's/.*"ts":"//;s/".*//' | sed 's/.*T//;s/+.*//' | cut -c1-8)
  SS=$(echo "$EVTS" | head -1 | sed 's/.*"session":"//;s/".*//')
  NC=$(echo "$EVTS" | wc -l | tr -d ' ')

  echo ""
  echo "> $TID  $T0>$TF  s:$SS  ${NC}ev"

  echo "$EVTS" | while IFS= read -r L; do
    EV=$(echo "$L" | sed 's/.*"event":"//;s/".*//')
    AG=$(echo "$L" | sed 's/.*"agent":"//;s/".*//')
    ST=$(echo "$L" | sed 's/.*"stage":"//;s/".*//')
    TL=$(echo "$L" | sed 's/.*"tool":"//;s/".*//')
    TS=$(echo "$L" | sed 's/.*"ts":"//;s/".*//' | sed 's/.*T//;s/+.*//' | cut -c1-8)
    IT=$(echo "$L" | grep -oE '"input_tokens":[0-9]*' | grep -oE '[0-9]+')
    OT=$(echo "$L" | grep -oE '"output_tokens":[0-9]*' | grep -oE '[0-9]+')

    TOK=""
    [ "${IT:-0}" -gt 0 ] 2>/dev/null && TOK=" ${IT}>${OT}t"

    case "$EV" in
      spawn)        echo "  $TS [START] kiro-factory" ;;
      pre-tool)     [ "$AG" != "none" ] && echo "  $TS [>>] $AG > $ST$TOK" || echo "  $TS [>>] $TL$TOK" ;;
      subagent-done) [ "$AG" != "none" ] && echo "  $TS [OK] $AG > $ST$TOK" || echo "  $TS [OK] $TL$TOK" ;;
      error)        echo "  $TS [ERR] $AG $ST" ;;
      turn-end)     echo "  $TS [END] kiro-factory$TOK" ;;
      *)            echo "  $TS [?] $EV" ;;
    esac
  done
done
echo ""
