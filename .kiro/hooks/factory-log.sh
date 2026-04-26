#!/bin/bash
# Kiro Factory — Structured Logger v6
# v6: Improved token estimation — correct direction, cumulative context, spawn overhead
# Stdin: {"hook_event_name":"...","cwd":"...","session_id":"...","tool_name":"...","tool_input":{...},"tool_response":"...","assistant_response":"..."}
# Usage: factory-log.sh <event-type>

LOG_DIR="$HOME/.kiro/logs/factory"
TRACE_DIR="$LOG_DIR/traces"
mkdir -p "$LOG_DIR" "$TRACE_DIR"

export TZ="Asia/Bangkok"
DATE=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/$DATE.jsonl"
SUMMARY_FILE="$LOG_DIR/$DATE.summary.log"
TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S+07:00')
EVENT="$1"

EVENT_DATA=$(cat 2>/dev/null || echo "{}")

# --- Trace/Span ID ---
TRACE_FILE="$TRACE_DIR/.active_trace"
SPAN_ID=$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-16)

# Extract session early (needed for trace logic)
SESSION=$(echo "$EVENT_DATA" | grep -oE '"session_id"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/' | cut -c1-8)

if [ "$EVENT" = "spawn" ]; then
  if [ -f "$TRACE_FILE" ]; then
    STORED_SESSION=$(head -2 "$TRACE_FILE" | tail -1)
    if [ "$SESSION" = "$STORED_SESSION" ]; then
      # same session (sub-agent spawn) — keep existing trace
      TRACE_ID=$(head -1 "$TRACE_FILE")
    else
      # new orchestrator session — new trace
      TRACE_ID=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-32)
      printf '%s\n%s\n' "$TRACE_ID" "$SESSION" > "$TRACE_FILE"
    fi
  else
    TRACE_ID=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-32)
    printf '%s\n%s\n' "$TRACE_ID" "$SESSION" > "$TRACE_FILE"
  fi
elif [ -f "$TRACE_FILE" ]; then
  TRACE_ID=$(head -1 "$TRACE_FILE")
elif [ "$EVENT" = "pre-tool" ]; then
  TRACE_ID=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-32)
  printf '%s\n%s\n' "$TRACE_ID" "${SESSION:-unknown}" > "$TRACE_FILE"
else
  TRACE_ID="unknown"
fi

# trace file is overwritten on next spawn, not deleted on turn-end
# this prevents late-arriving events from losing their trace ID

# --- Extract fields from Kiro CLI stdin ---
TOOL_NAME=$(echo "$EVENT_DATA" | grep -oE '"tool_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')

# For subagent tool calls, extract agent/stage/task from tool_input
AGENT_NAME=""
STAGE_NAME=""
TASK=""
MODEL=""
if [ "$TOOL_NAME" = "subagent" ]; then
  AGENT_NAME=$(echo "$EVENT_DATA" | grep -oE '"role"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
  STAGE_NAME=$(echo "$EVENT_DATA" | grep -oE '"name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
  TASK=$(echo "$EVENT_DATA" | grep -oE '"task"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
  # Lookup model from agent config
  AGENT_CFG="$HOME/.kiro/agents/${AGENT_NAME}.json"
  if [ -f "$AGENT_CFG" ]; then
    MODEL=$(grep -oE '"model"\s*:\s*"[^"]*"' "$AGENT_CFG" | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
  fi
fi
# Fallback: orchestrator model from cli.json
if [ -z "$MODEL" ]; then
  MODEL=$(grep -oE '"chat\.defaultModel"\s*:\s*"[^"]*"' "$HOME/.kiro/settings/cli.json" 2>/dev/null | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
fi

# Epoch ms for latency tracking
EPOCH_MS=$(python3 -c 'import time;print(int(time.time()*1000))' 2>/dev/null || echo 0)

# --- Token estimation v2 ---
# Extract content field sizes (chars / 4 ≈ tokens)
# Direction: tool_input = model OUTPUT (it chose to call), tool_response = model INPUT (it reads result)
#            assistant_response = model OUTPUT
TOOL_INPUT_SIZE=$(echo "$EVENT_DATA" | grep -oE '"tool_input"\s*:\s*(\{[^}]*\}|"[^"]*")' | head -1 | wc -c)
TOOL_RESP_SIZE=$(echo "$EVENT_DATA" | grep -oE '"tool_response"\s*:\s*"[^"]*"' | head -1 | wc -c)
ASST_RESP_SIZE=$(echo "$EVENT_DATA" | grep -oE '"assistant_response"\s*:\s*"[^"]*"' | head -1 | wc -c)

INPUT_TOKENS=0; OUTPUT_TOKENS=0
CTX_FILE="$TRACE_DIR/.ctx_${SESSION:-unknown}"

case "$EVENT" in
  spawn)
    # System prompt overhead (~3000 tokens) + reset cumulative context
    INPUT_TOKENS=3000
    echo "3000" > "$CTX_FILE"
    ;;
  pre-tool)
    # tool_input = model output (it generated the call)
    OUTPUT_TOKENS=$(( TOOL_INPUT_SIZE / 4 ))
    # Cumulative: model re-reads full context each turn
    if [ -f "$CTX_FILE" ]; then
      CTX=$(cat "$CTX_FILE")
      INPUT_TOKENS=$(( CTX + 0 ))
    fi
    ;;
  subagent-done)
    # tool_response = model will read this → adds to context
    RESP_TOK=$(( TOOL_RESP_SIZE / 4 ))
    INPUT_TOKENS=$RESP_TOK
    # Grow cumulative context
    if [ -f "$CTX_FILE" ]; then
      CTX=$(cat "$CTX_FILE")
      echo "$(( CTX + RESP_TOK + OUTPUT_TOKENS ))" > "$CTX_FILE"
    fi
    ;;
  turn-end)
    # assistant_response = model output
    OUTPUT_TOKENS=$(( ASST_RESP_SIZE / 4 ))
    # Add output to cumulative context (it becomes part of history)
    if [ -f "$CTX_FILE" ]; then
      CTX=$(cat "$CTX_FILE")
      echo "$(( CTX + OUTPUT_TOKENS ))" > "$CTX_FILE"
    fi
    ;;
esac

COST=""
if [ "$INPUT_TOKENS" -gt 0 ] || [ "$OUTPUT_TOKENS" -gt 0 ]; then
  # Model-aware pricing (USD per 1M tokens: input/output)
  case "$MODEL" in
    claude-opus-4.6|claude-opus-4-2025*)  IN_RATE=15; OUT_RATE=75 ;;
    claude-sonnet-4-2025*|claude-sonnet-4.5*) IN_RATE=3; OUT_RATE=15 ;;
    claude-haiku*|claude-3-5-haiku*)      IN_RATE=0.80; OUT_RATE=4 ;;
    *)                                     IN_RATE=3; OUT_RATE=15 ;;
  esac
  COST=$(awk "BEGIN {printf \"%.4f\", ($INPUT_TOKENS * $IN_RATE + $OUTPUT_TOKENS * $OUT_RATE) / 1000000}")
fi

# --- JSONL ---
echo "{\"ts\":\"$TIMESTAMP\",\"epoch_ms\":${EPOCH_MS:-0},\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"event\":\"$EVENT\",\"tool\":\"${TOOL_NAME:-none}\",\"agent\":\"${AGENT_NAME:-none}\",\"stage\":\"${STAGE_NAME:-none}\",\"task\":\"${TASK:-none}\",\"model\":\"${MODEL:-unknown}\",\"session\":\"${SESSION:-none}\",\"data_size\":${#EVENT_DATA},\"input_tokens\":${INPUT_TOKENS:-0},\"output_tokens\":${OUTPUT_TOKENS:-0},\"cost_usd\":${COST:-0}}" >> "$LOG_FILE"

# --- Summary ---
TID_SHORT=$(echo "$TRACE_ID" | cut -c1-8)
case "$EVENT" in
  spawn)
    echo "[$TIMESTAMP] 🏭 Factory started [trace:$TID_SHORT] [session:${SESSION:-?}]" >> "$SUMMARY_FILE"
    ;;
  pre-tool)
    if [ "$TOOL_NAME" = "subagent" ]; then
      echo "[$TIMESTAMP] 🔧 Dispatch: ${AGENT_NAME:-?} → ${STAGE_NAME:-?} [trace:$TID_SHORT]" >> "$SUMMARY_FILE"
    else
      echo "[$TIMESTAMP] 🔧 Tool: ${TOOL_NAME:-?} [trace:$TID_SHORT]" >> "$SUMMARY_FILE"
    fi
    ;;
  subagent-done)
    if [ "$TOOL_NAME" = "subagent" ]; then
      echo "[$TIMESTAMP] ✅ Done: ${AGENT_NAME:-?} → ${STAGE_NAME:-?} [trace:$TID_SHORT]" >> "$SUMMARY_FILE"
    else
      echo "[$TIMESTAMP] ✅ Tool done: ${TOOL_NAME:-?} [trace:$TID_SHORT]" >> "$SUMMARY_FILE"
    fi
    ;;
  turn-end)
    echo "[$TIMESTAMP] 🏁 Turn completed [trace:$TID_SHORT]" >> "$SUMMARY_FILE"
    ;;
  *)
    echo "[$TIMESTAMP] ℹ️  $EVENT [trace:$TID_SHORT]" >> "$SUMMARY_FILE"
    ;;
esac

exit 0
