#!/bin/bash
# Kiro Factory — Log Cleanup
# Removes logs older than 30 days.
# Usage: factory-cleanup.sh [--dry-run]

LOG_DIR="$HOME/.kiro/logs/factory"
DAYS=30
DRY_RUN=false

[ "$1" = "--dry-run" ] && DRY_RUN=true

if [ ! -d "$LOG_DIR" ]; then
  echo "No log directory found."
  exit 0
fi

FILES=$(find "$LOG_DIR" -name "*.jsonl" -o -name "*.summary.log" -mtime +$DAYS)

if [ -z "$FILES" ]; then
  echo "✅ No logs older than ${DAYS} days."
  exit 0
fi

echo "Files older than ${DAYS} days:"
echo "$FILES"

if $DRY_RUN; then
  echo "🔍 DRY RUN: Would delete the above files."
else
  echo "$FILES" | xargs rm -f
  echo "✅ Deleted."
fi
