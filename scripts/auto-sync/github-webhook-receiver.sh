#!/bin/bash
# GitHub Webhook Receiver for NXCore Auto-Sync
# Receives webhook notifications from GitHub and triggers updates

set -e

# Configuration
REPO_DIR="/srv/core"
LOG_FILE="/var/log/nxcore-autosync.log"
WEBHOOK_SECRET="${GITHUB_WEBHOOK_SECRET:-nxcore-autosync-2024}"
PORT="${WEBHOOK_PORT:-8080}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Verify webhook signature
verify_signature() {
    local payload="$1"
    local signature="$2"
    local expected=$(echo -n "$payload" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | cut -d' ' -f2)
    local received=$(echo "$signature" | sed 's/sha256=//')
    
    if [ "$expected" = "$received" ]; then
        return 0
    else
        return 1
    fi
}

# Update repository and restart services
update_services() {
    log "Starting auto-sync update process..."
    
    cd "$REPO_DIR"
    
    # Pull latest changes
    log "Pulling latest changes from GitHub..."
    git pull origin master
    
    # Make scripts executable
    log "Setting executable permissions on scripts..."
    chmod +x scripts/*.sh
    
    # Check if Docker Compose files changed
    if git diff HEAD~1 HEAD --name-only | grep -q "docker/compose-.*\.yml"; then
        log "Docker Compose files changed, restarting affected services..."
        
        # Get list of changed compose files
        changed_files=$(git diff HEAD~1 HEAD --name-only | grep "docker/compose-.*\.yml")
        
        for file in $changed_files; do
            service_name=$(basename "$file" .yml | sed 's/compose-//')
            log "Restarting service: $service_name"
            
            # Stop and restart the service
            docker-compose -f "$file" down
            docker-compose -f "$file" up -d
            
            # Wait a moment for service to start
            sleep 5
            
            # Check if service is healthy
            if docker-compose -f "$file" ps | grep -q "Up"; then
                log "Service $service_name restarted successfully"
            else
                log "WARNING: Service $service_name may not have started properly"
            fi
        done
    fi
    
    # Check if Traefik configuration changed
    if git diff HEAD~1 HEAD --name-only | grep -q "docker/tailnet-routes.yml"; then
        log "Traefik configuration changed, reloading Traefik..."
        docker-compose -f docker/compose-traefik.yml restart traefik
    fi
    
    # Check if landing page changed
    if git diff HEAD~1 HEAD --name-only | grep -q "configs/landing/"; then
        log "Landing page changed, restarting landing service..."
        docker-compose -f docker/compose-landing.yml restart landing
    fi
    
    log "Auto-sync update completed successfully"
}

# Handle webhook request
handle_webhook() {
    local method="$1"
    local path="$2"
    
    if [ "$method" = "POST" ] && [ "$path" = "/webhook" ]; then
        # Read the payload
        payload=$(cat)
        
        # Get signature from headers
        signature=$(echo "$HTTP_X_HUB_SIGNATURE_256" | tr -d '\r')
        
        # Verify signature
        if verify_signature "$payload" "$signature"; then
            log "Valid webhook received, processing update..."
            update_services
            echo "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nOK"
        else
            log "Invalid webhook signature, ignoring request"
            echo "HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\n\r\nForbidden"
        fi
    else
        echo "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nNot Found"
    fi
}

# Start webhook server
start_server() {
    log "Starting GitHub webhook receiver on port $PORT"
    
    while true; do
        {
            # Read HTTP request line
            read -r method path version
            
            # Read headers
            while read -r header; do
                [ -z "$header" ] && break
                case "$header" in
                    X-Hub-Signature-256:*)
                        export HTTP_X_HUB_SIGNATURE_256="${header#X-Hub-Signature-256: }"
                        ;;
                esac
            done
            
            # Handle the request
            handle_webhook "$method" "$path"
            
        } | nc -l -p "$PORT" -q 1
    done
}

# Main execution
case "${1:-start}" in
    start)
        start_server
        ;;
    update)
        update_services
        ;;
    test)
        log "Testing webhook receiver..."
        echo "Test webhook received" | handle_webhook "POST" "/webhook"
        ;;
    *)
        echo "Usage: $0 {start|update|test}"
        exit 1
        ;;
esac
