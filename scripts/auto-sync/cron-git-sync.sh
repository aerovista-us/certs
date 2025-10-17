#!/bin/bash
# Cron-based Git Sync for NXCore
# Periodically checks for updates and syncs if changes are found

set -e

# Configuration
REPO_DIR="/srv/core"
LOG_FILE="/var/log/nxcore-cron-sync.log"
CHECK_INTERVAL="${SYNC_INTERVAL:-300}"  # 5 minutes default

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check for updates and sync if needed
check_and_sync() {
    cd "$REPO_DIR"
    
    # Fetch latest changes without merging
    git fetch origin master
    
    # Check if there are new commits
    local_behind=$(git rev-list --count HEAD..origin/master)
    
    if [ "$local_behind" -gt 0 ]; then
        log "Found $local_behind new commits, starting sync..."
        
        # Get list of files that will change
        changed_files=$(git diff --name-only HEAD origin/master)
        log "Files to be updated: $changed_files"
        
        # Pull the changes
        git pull origin master
        
        # Make scripts executable
        chmod +x scripts/*.sh
        
        # Check what services need restarting
        restart_services "$changed_files"
        
        log "Cron sync completed successfully"
    else
        log "No new commits found, skipping sync"
    fi
}

# Restart services based on changed files
restart_services() {
    local changed_files="$1"
    
    # Check for Docker Compose changes
    if echo "$changed_files" | grep -q "docker/compose-.*\.yml"; then
        log "Docker Compose files changed, restarting affected services..."
        
        # Get list of changed compose files
        changed_compose=$(echo "$changed_files" | grep "docker/compose-.*\.yml")
        
        for file in $changed_compose; do
            service_name=$(basename "$file" .yml | sed 's/compose-//')
            log "Restarting service: $service_name"
            
            # Stop and restart the service
            docker-compose -f "$file" down
            docker-compose -f "$file" up -d
            
            # Wait for service to start
            sleep 5
            
            # Check service health
            if docker-compose -f "$file" ps | grep -q "Up"; then
                log "Service $service_name restarted successfully"
            else
                log "WARNING: Service $service_name may not have started properly"
            fi
        done
    fi
    
    # Check for Traefik configuration changes
    if echo "$changed_files" | grep -q "docker/tailnet-routes.yml"; then
        log "Traefik configuration changed, reloading Traefik..."
        docker-compose -f docker/compose-traefik.yml restart traefik
    fi
    
    # Check for landing page changes
    if echo "$changed_files" | grep -q "configs/landing/"; then
        log "Landing page changed, restarting landing service..."
        docker-compose -f docker/compose-landing.yml restart landing
    fi
    
    # Check for certificate changes
    if echo "$changed_files" | grep -q "certs/"; then
        log "Certificate files changed, restarting Traefik..."
        docker-compose -f docker/compose-traefik.yml restart traefik
    fi
}

# Main execution
case "${1:-check}" in
    check)
        check_and_sync
        ;;
    force)
        log "Force sync requested..."
        git pull origin master
        chmod +x scripts/*.sh
        log "Force sync completed"
        ;;
    status)
        cd "$REPO_DIR"
        git fetch origin master
        local_behind=$(git rev-list --count HEAD..origin/master)
        if [ "$local_behind" -gt 0 ]; then
            echo "Repository is $local_behind commits behind origin/master"
        else
            echo "Repository is up to date"
        fi
        ;;
    *)
        echo "Usage: $0 {check|force|status}"
        exit 1
        ;;
esac
