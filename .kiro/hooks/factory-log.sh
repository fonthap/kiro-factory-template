#!/bin/bash
# Kiro Factory — Structured Logger
# Stdin: JSON from kiro-cli hooks
# Usage: factory-log.sh <event-type>

LOG_DIR="$HOME/.kiro/logs/factory"
TRACE_DIR="$LOG_DIR/traces"
mkdir -p "$LOG_DIR" "$TRACE_DIR"

DATE=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/$DATE.jsonl"
SUMMARY_FILE="$LOG_DIR/$DATE.summary.log"
TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S%z' | sed 's/\(..\)$/:\1/')
EVENT="$1"

EVENT_DATA=$(cat 2>/dev/null || echo "{}")

# --- Trace/Span ID ---
TRACE_FILE="$TRACE_DIR/.active_trace"
SPAN_ID=$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-16)
SESSION=$(echo "$EVENT_DATA" | grep -oE '"session_id"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/' | cut -c1-8)

if [ "$EVENT" = "spawn" ]; then
  if [ -f "$TRACE_FILE" ]; then
    STORED_SESSION=$(head -2 "$TRACE_FILE" | tail -1)
    if [ "$SESSION" = "$STORED_SESSION" ]; then
      TRACE_ID=$(head -1 "$TRACE_FILE")
    else
      TRACE_ID=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-32)
      printf '%s\n%s\n' "$TRACE_ID" "$SESSION" > "$TRACE_FILE"
    fi
  else
    TRACE_ID=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-32)
    printf '%s\n%s\n' "$TRACE_ID" "$SESSION" > "$TRACE_FILE"
  fi
elif [ -f "$TRACE_FILE" ]; then
  TRACE_ID=$(head -1 "$TRACE_FILE")
else
  TRACE_ID="unknown"
fi

# --- Extract fields ---
TOOL_NAME=$(echo "$EVENT_DATA" | grep -oE '"tool_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
AGENT_NAME=""; STAGE_NAME=""; MODEL=""
if [ "$TOOL_NAME" = "subagent" ]; then
  AGENT_NAME=$(echo "$EVENT_DATA" | grep -oE '"role"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
  STAGE_NAME=$(echo "$EVENT_DATA" | grep -oE '"name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
  AGENT_CFG="$HOME/.kiro/agents/${AGENT_NAME}.json"
  [ -f "$AGENT_CFG" ] && MODEL=$(grep -oE '"model"\s*:\s*"[^"]*"' "$AGENT_CFG" | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
fi
[ -z "$MODEL" ] && MODEL=$(grep -oE '"chat\.defaultModel"\s*:\s*"[^"]*"' "$HOME/.kiro/settings/cli.json" 2>/dev/null | head -1 | sed 's/.*:.*"\(.*\)"/\1/')

EPOCH_MS=$(python3 -c 'import time;print(int(time.time()*1000))' 2>/dev/null || echo 0)

# --- JSONL ---
echo "{\"ts\":\"$TIMESTAMP\",\"epoch_ms\":$EPOCH_MS,\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"event\":\"$EVENT\",\"tool\":\"${TOOL_NAME:-none}\",\"agent\":\"${AGENT_NAME:-none}\",\"stage\":\"${STAGE_NAME:-none}\",\"model\":\"${MODEL:-unknown}\",\"session\":\"${SESSION:-none}\",\"data_size\":${#EVENT_DATA}}" >> "$LOG_FILE"

# --- Summary ---
TID=$(echo "$TRACE_ID" | cut -c1-8)
case "$EVENT" in
  spawn)        echo "[$TIMESTAMP] 🏭 Started [trace:$TID]" >> "$SUMMARY_FILE" ;;
  pre-tool)     [ "$TOOL_NAME" = "subagent" ] \
                  && echo "[$TIMESTAMP] 🔧 >> ${AGENT_NAME:-?} > ${STAGE_NAME:-?} [trace:$TID]" >> "$SUMMARY_FILE" \
                  || echo "[$TIMESTAMP] 🔧 ${TOOL_NAME:-?} [trace:$TID]" >> "$SUMMARY_FILE" ;;
  subagent-done) [ "$TOOL_NAME" = "subagent" ] \
                  && echo "[$TIMESTAMP] ✅ << ${AGENT_NAME:-?} > ${STAGE_NAME:-?} [trace:$TID]" >> "$SUMMARY_FILE" \
                  || echo "[$TIMESTAMP] ✅ ${TOOL_NAME:-?} [trace:$TID]" >> "$SUMMARY_FILE" ;;
  turn-end)     echo "[$TIMESTAMP] 🏁 Done [trace:$TID]" >> "$SUMMARY_FILE" ;;
  *)            echo "[$TIMESTAMP] ℹ️  $EVENT [trace:$TID]" >> "$SUMMARY_FILE" ;;
esac

exit 0
