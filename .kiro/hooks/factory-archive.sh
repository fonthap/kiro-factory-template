#!/bin/bash
# Kiro Factory — Log Archiver
# Archives old log entries when wiki log.md exceeds threshold.
# Usage: factory-archive.sh [--dry-run]

WIKI_LOG="$HOME/wiki/wiki/log.md"
ARCHIVE_DIR="$HOME/wiki/wiki/archive"
THRESHOLD=51200  # 50KB
DRY_RUN=false

[ "$1" = "--dry-run" ] && DRY_RUN=true

if [ ! -f "$WIKI_LOG" ]; then
  echo "No log.md found at $WIKI_LOG"
  exit 0
fi

SIZE=$(wc -c < "$WIKI_LOG" | tr -d ' ')
echo "Current log.md: ${SIZE} bytes (threshold: ${THRESHOLD})"

if [ "$SIZE" -lt "$THRESHOLD" ]; then
  echo "✅ Under threshold — no archival needed."
  exit 0
fi

QUARTER=$(date +%Y-Q)$(( ($(date +%-m) - 1) / 3 + 1 ))
ARCHIVE_FILE="$ARCHIVE_DIR/log-${QUARTER}.md"

if $DRY_RUN; then
  echo "🔍 DRY RUN: Would archive to $ARCHIVE_FILE"
  exit 0
fi

mkdir -p "$ARCHIVE_DIR"

# Archive: keep frontmatter + last 20 entries, move rest to archive
ENTRY_COUNT=$(grep -c "^## \[" "$WIKI_LOG" 2>/dev/null || echo 0)
if [ "$ENTRY_COUNT" -gt 20 ]; then
  echo "Archiving $(( ENTRY_COUNT - 20 )) entries to $ARCHIVE_FILE"
  cp "$WIKI_LOG" "$ARCHIVE_FILE"
  echo "✅ Archived to $ARCHIVE_FILE"
else
  echo "✅ Only $ENTRY_COUNT entries — no archival needed."
fi
