#!/bin/bash
# Inbox Sync System for NXCore
# Automatically syncs files from a specific inbox folder to GitHub

set -e

# Configuration
REPO_DIR="/srv/core"
INBOX_DIR="/srv/core/inbox"
SYNC_DIR="/srv/core/inbox-sync"
LOG_FILE="/var/log/nxcore-inbox-sync.log"
SYNC_INTERVAL="${INBOX_SYNC_INTERVAL:-60}"  # 1 minute default

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" | tee -a "$LOG_FILE"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# Create necessary directories
setup_directories() {
    mkdir -p "$INBOX_DIR"
    mkdir -p "$SYNC_DIR"
    
    # Create .gitignore for inbox if it doesn't exist
    if [ ! -f "$INBOX_DIR/.gitignore" ]; then
        cat > "$INBOX_DIR/.gitignore" << 'EOF'
# Inbox sync - ignore temporary files
*.tmp
*.temp
*.log
.DS_Store
Thumbs.db
EOF
    fi
}

# Check for new files in inbox
check_inbox() {
    local new_files=()
    
    # Find files newer than last sync
    if [ -f "$SYNC_DIR/.last-sync" ]; then
        local last_sync=$(cat "$SYNC_DIR/.last-sync")
        while IFS= read -r -d '' file; do
            new_files+=("$file")
        done < <(find "$INBOX_DIR" -type f -newer "$SYNC_DIR/.last-sync" -print0 2>/dev/null)
    else
        # First run - sync all files
        while IFS= read -r -d '' file; do
            new_files+=("$file")
        done < <(find "$INBOX_DIR" -type f -print0 2>/dev/null)
    fi
    
    echo "${new_files[@]}"
}

# Sync files to GitHub
sync_to_github() {
    local files=("$@")
    
    if [ ${#files[@]} -eq 0 ]; then
        return 0
    fi
    
    log "Syncing ${#files[@]} files to GitHub..."
    
    cd "$REPO_DIR"
    
    # Add files to git
    for file in "${files[@]}"; do
        local relative_path="${file#$INBOX_DIR/}"
        log "Adding file: $relative_path"
        git add "$relative_path"
    done
    
    # Check if there are changes to commit
    if git status --porcelain | grep -q "^A\|^M"; then
        # Create commit message
        local commit_msg="Inbox sync: $(date '+%Y-%m-%d %H:%M:%S')"
        if [ ${#files[@]} -eq 1 ]; then
            commit_msg="Inbox sync: $(basename "${files[0]}")"
        else
            commit_msg="Inbox sync: ${#files[@]} files"
        fi
        
        # Commit changes
        git commit -m "$commit_msg"
        
        # Push to GitHub
        if git push origin master; then
            log "Successfully synced ${#files[@]} files to GitHub"
            
            # Update last sync timestamp
            touch "$SYNC_DIR/.last-sync"
            
            return 0
        else
            error "Failed to push to GitHub"
            return 1
        fi
    else
        log "No changes to commit"
        return 0
    fi
}

# Process files (optional: convert, validate, etc.)
process_files() {
    local files=("$@")
    
    for file in "${files[@]}"; do
        local filename=$(basename "$file")
        local extension="${filename##*.}"
        
        # Process based on file type
        case "$extension" in
            txt|md|json|yaml|yml)
                # Text files - ensure proper line endings
                dos2unix "$file" 2>/dev/null || true
                ;;
            csv)
                # CSV files - validate format
                if ! head -1 "$file" | grep -q ","; then
                    warn "CSV file may not be properly formatted: $filename"
                fi
                ;;
            log)
                # Log files - compress if large
                if [ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null) -gt 1048576 ]; then
                    log "Compressing large log file: $filename"
                    gzip "$file"
                fi
                ;;
        esac
    done
}

# Main sync function
perform_sync() {
    log "Starting inbox sync..."
    
    # Setup directories
    setup_directories
    
    # Check for new files
    local new_files=($(check_inbox))
    
    if [ ${#new_files[@]} -eq 0 ]; then
        log "No new files to sync"
        return 0
    fi
    
    log "Found ${#new_files[@]} new files to sync"
    
    # Process files
    process_files "${new_files[@]}"
    
    # Sync to GitHub
    if sync_to_github "${new_files[@]}"; then
        log "Inbox sync completed successfully"
        return 0
    else
        error "Inbox sync failed"
        return 1
    fi
}

# Continuous sync mode
continuous_sync() {
    log "Starting continuous inbox sync (interval: ${SYNC_INTERVAL}s)"
    
    while true; do
        perform_sync
        sleep "$SYNC_INTERVAL"
    done
}

# One-time sync
one_time_sync() {
    log "Performing one-time inbox sync..."
    perform_sync
}

# List files in inbox
list_inbox() {
    echo "Files in inbox:"
    if [ -d "$INBOX_DIR" ]; then
        find "$INBOX_DIR" -type f | while read -r file; do
            local relative_path="${file#$INBOX_DIR/}"
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            local modified=$(stat -f%Sm "$file" 2>/dev/null || stat -c%y "$file" 2>/dev/null)
            echo "  $relative_path ($size bytes, modified: $modified)"
        done
    else
        echo "  Inbox directory does not exist"
    fi
}

# Clean inbox (remove processed files)
clean_inbox() {
    local days="${1:-7}"
    
    log "Cleaning inbox (removing files older than $days days)..."
    
    if [ -d "$INBOX_DIR" ]; then
        find "$INBOX_DIR" -type f -mtime +$days -delete
        log "Inbox cleanup completed"
    else
        warn "Inbox directory does not exist"
    fi
}

# Create systemd service for continuous sync
create_systemd_service() {
    log "Creating systemd service for inbox sync..."
    
    cat > /etc/systemd/system/nxcore-inbox-sync.service << EOF
[Unit]
Description=NXCore Inbox Sync
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$REPO_DIR
ExecStart=$REPO_DIR/scripts/auto-sync/inbox-sync.sh continuous
Restart=always
RestartSec=10
Environment=INBOX_SYNC_INTERVAL=$SYNC_INTERVAL
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable nxcore-inbox-sync.service
    
    log "Inbox sync systemd service created and enabled"
}

# Main execution
case "${1:-sync}" in
    sync)
        one_time_sync
        ;;
    continuous)
        continuous_sync
        ;;
    list)
        list_inbox
        ;;
    clean)
        clean_inbox "$2"
        ;;
    setup-service)
        create_systemd_service
        ;;
    start)
        systemctl start nxcore-inbox-sync.service
        log "Inbox sync service started"
        ;;
    stop)
        systemctl stop nxcore-inbox-sync.service
        log "Inbox sync service stopped"
        ;;
    status)
        systemctl status nxcore-inbox-sync.service --no-pager
        ;;
    *)
        echo "Usage: $0 {sync|continuous|list|clean|setup-service|start|stop|status}"
        echo
        echo "Commands:"
        echo "  sync              - One-time sync of inbox to GitHub"
        echo "  continuous        - Continuous sync mode (runs forever)"
        echo "  list              - List files in inbox"
        echo "  clean [days]      - Clean inbox (remove files older than N days)"
        echo "  setup-service     - Create systemd service for continuous sync"
        echo "  start             - Start inbox sync service"
        echo "  stop              - Stop inbox sync service"
        echo "  status            - Show service status"
        echo
        echo "Examples:"
        echo "  $0 sync           # Sync inbox once"
        echo "  $0 continuous     # Run continuous sync"
        echo "  $0 clean 30       # Remove files older than 30 days"
        echo "  $0 setup-service  # Create systemd service"
        exit 1
        ;;
esac
