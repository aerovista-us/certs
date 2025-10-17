#!/usr/bin/env bash
set -euo pipefail

# Inbox Watcher Script
# Monitors /srv/exchange/inbox for new files and dispatches to n8n

INBOX_DIR="/srv/exchange/inbox"
PROCESSING_DIR="/srv/exchange/processing"
ARCHIVE_DIR="/srv/exchange/archive"
N8N_WEBHOOK="http://localhost:5678/webhook/shipping-receiving"
MAX_RETRIES=3
RETRY_DELAY=5

# Create directories if they don't exist
mkdir -p "$PROCESSING_DIR" "$ARCHIVE_DIR"

log() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" >&2
}

process_file() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local date_dir=$(date +%Y-%m-%d)
    local processing_path="$PROCESSING_DIR/$date_dir"
    local archive_path="$ARCHIVE_DIR/$date_dir"
    
    # Create date-based directories
    mkdir -p "$processing_path" "$archive_path"
    
    # Move to processing and copy to archive
    mv "$filepath" "$processing_path/"
    cp "$processing_path/$filename" "$archive_path/"
    
    # Get file metadata
    local mimetype=$(file --mime-type -b "$processing_path/$filename")
    local extension="${filename##*.}"
    
    # Prepare webhook payload
    local payload=$(cat <<EOF
{
    "filepath": "$processing_path/$filename",
    "filename": "$filename",
    "mimetype": "$mimetype",
    "ext": ".$extension",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)
    
    # Send to n8n webhook with retries
    local retry_count=0
    while [ $retry_count -lt $MAX_RETRIES ]; do
        if curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$N8N_WEBHOOK" >/dev/null 2>&1; then
            log "Successfully dispatched $filename to n8n"
            return 0
        else
            retry_count=$((retry_count + 1))
            log "Failed to dispatch $filename (attempt $retry_count/$MAX_RETRIES)"
            if [ $retry_count -lt $MAX_RETRIES ]; then
                sleep $RETRY_DELAY
            fi
        fi
    done
    
    log "ERROR: Failed to dispatch $filename after $MAX_RETRIES attempts"
    return 1
}

# Main monitoring loop
log "Starting inbox watcher for $INBOX_DIR"

# Use inotifywait to monitor for file creation
inotifywait -m -e create,moved_to --format '%w%f' "$INBOX_DIR" | while read -r filepath; do
    # Wait a moment for file to be fully written
    sleep 2
    
    # Check if it's actually a file (not a directory)
    if [ -f "$filepath" ]; then
        log "New file detected: $filepath"
        process_file "$filepath"
    fi
done
