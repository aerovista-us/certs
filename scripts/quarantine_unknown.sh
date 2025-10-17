#!/usr/bin/env bash
set -euo pipefail

# Quarantine unknown file types
# Moves files that don't match allowed patterns to quarantine directory

QUARANTINE_DIR="/srv/exchange/quarantine"
INBOX_DIR="/srv/exchange/inbox"
ALLOWED_EXT="\.md|\.txt|\.json|\.csv|\.yaml|\.yml|\.png|\.jpg|\.jpeg|\.webp|\.gif|\.svg|\.log\.gz|\.zip|\.pdf|\.doc|\.docx"

mkdir -p "$QUARANTINE_DIR"

# Find files that don't match allowed extensions
find "$INBOX_DIR" -type f ! -regex ".*(${ALLOWED_EXT})$" -print0 | while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        timestamp=$(date +%Y%m%d_%H%M%S)
        quarantine_path="$QUARANTINE_DIR/${timestamp}_${filename}"
        
        echo "[QUARANTINE] Moving unknown file type: $file -> $quarantine_path"
        mv "$file" "$quarantine_path"
        
        # Log the quarantine action
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) - QUARANTINED: $file (unknown type)" >> "$QUARANTINE_DIR/quarantine.log"
    fi
done
