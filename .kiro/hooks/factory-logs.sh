#!/bin/bash
# Kiro Factory — Log Viewer v2
# Usage: factory-logs.sh [today|YYYY-MM-DD|summary|json|stats|clean|archive]

LOG_DIR="$HOME/.kiro/logs/factory"
DATE="${1:-today}"

if [ "$DATE" = "today" ]; then
  DATE=$(date +%Y-%m-%d)
fi

case "$DATE" in
  summary)
    DATE=$(date +%Y-%m-%d)
    cat "$LOG_DIR/$DATE.summary.log" 2>/dev/null || echo "No summary logs for today."
    ;;
  json)
    DATE=$(date +%Y-%m-%d)
    cat "$LOG_DIR/$DATE.jsonl" 2>/dev/null || echo "No JSON logs for today."
    ;;
  stats)
    DATE=$(date +%Y-%m-%d)
    FILE="$LOG_DIR/$DATE.jsonl"
    if [ ! -f "$FILE" ]; then echo "No logs for today."; exit 0; fi
    echo "=== Today's Stats ($DATE) ==="
    echo "Total events: $(wc -l < "$FILE" | tr -d ' ')"
    echo "Spawns:       $(grep -c '"event":"spawn"' "$FILE")"
    echo "Tool calls:   $(grep -c '"event":"pre-tool"' "$FILE")"
    echo "Completions:  $(grep -c '"event":"subagent-done"' "$FILE")"
    echo "Errors:       $(grep -c '"event":"error"' "$FILE")"
    echo "Turns:        $(grep -c '"event":"turn-end"' "$FILE")"
    ;;
  clean)
    "$HOME/.kiro/hooks/factory-cleanup.sh" "${2:---dry-run}"
    ;;
  archive)
    "$HOME/.kiro/hooks/factory-archive.sh" "${2:---dry-run}"
    ;;
  *)
    echo "=== Summary ($DATE) ==="
    cat "$LOG_DIR/$DATE.summary.log" 2>/dev/null || echo "No logs."
    echo ""
    echo "=== Structured ($DATE) ==="
    cat "$LOG_DIR/$DATE.jsonl" 2>/dev/null || echo "No logs."
    ;;
esac
