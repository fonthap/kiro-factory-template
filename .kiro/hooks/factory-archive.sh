#!/bin/bash
# Kiro Factory — Decision Log Archiver
# Archives old entries when log exceeds threshold.
# Usage: factory-archive.sh [--dry-run]

DECISION_LOG="$HOME/.kiro/skills/factory-decision-log/SKILL.md"
ARCHIVE_DIR="$HOME/.kiro/skills/factory-decision-log/archive"
THRESHOLD=5120  # 5KB
DRY_RUN=false

[ "$1" = "--dry-run" ] && DRY_RUN=true

if [ ! -f "$DECISION_LOG" ]; then
  echo "No decision log found."
  exit 0
fi

SIZE=$(wc -c < "$DECISION_LOG" | tr -d ' ')
echo "Current decision log: ${SIZE} bytes (threshold: ${THRESHOLD})"

if [ "$SIZE" -lt "$THRESHOLD" ]; then
  echo "✅ Under threshold — no archival needed."
  exit 0
fi

QUARTER=$(date +%Y-Q)$(( ($(date +%-m) - 1) / 3 + 1 ))
ARCHIVE_FILE="$ARCHIVE_DIR/decision-log-${QUARTER}.md"

if $DRY_RUN; then
  echo "🔍 DRY RUN: Would archive to $ARCHIVE_FILE"
  exit 0
fi

mkdir -p "$ARCHIVE_DIR"

# Copy current log to archive (append if archive exists)
if [ -f "$ARCHIVE_FILE" ]; then
  echo "" >> "$ARCHIVE_FILE"
  echo "---" >> "$ARCHIVE_FILE"
  echo "# Archived $(date +%Y-%m-%d)" >> "$ARCHIVE_FILE"
  grep -A 1000 "^## Entries" "$DECISION_LOG" | tail -n +2 >> "$ARCHIVE_FILE"
else
  cp "$DECISION_LOG" "$ARCHIVE_FILE"
fi

# Keep only the header and last 2 entries in the active log
HEADER=$(sed '/^## Entries/q' "$DECISION_LOG")
LAST_ENTRIES=$(grep -n "^### " "$DECISION_LOG" | tail -2 | head -1 | cut -d: -f1)

if [ -n "$LAST_ENTRIES" ]; then
  KEPT=$(tail -n +"$LAST_ENTRIES" "$DECISION_LOG")
  printf '%s\n\n%s\n\n%s\n' "$HEADER" "" "$KEPT" > "$DECISION_LOG"
  echo "✅ Archived to $ARCHIVE_FILE — kept last 2 entries in active log."
else
  echo "⚠️  Could not parse entries — archive created but active log unchanged."
fi
