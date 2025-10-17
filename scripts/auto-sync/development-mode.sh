#!/bin/bash
# Development Mode Manager for NXCore Auto-Sync
# Allows easy enable/disable of auto-sync during development

set -e

# Configuration
REPO_DIR="/srv/core"
LOG_FILE="/var/log/nxcore-dev-mode.log"

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

# Check current mode
check_mode() {
    local webhook_status=$(systemctl is-active nxcore-webhook.service 2>/dev/null || echo "inactive")
    local cron_status=$(systemctl is-active nxcore-cron-sync.timer 2>/dev/null || echo "inactive")
    
    if [ "$webhook_status" = "active" ] && [ "$cron_status" = "active" ]; then
        echo "production"
    else
        echo "development"
    fi
}

# Enable production mode (auto-sync on)
enable_production() {
    log "Enabling production mode (auto-sync enabled)..."
    
    # Start services
    systemctl start nxcore-webhook.service
    systemctl start nxcore-cron-sync.timer
    
    # Enable services to start on boot
    systemctl enable nxcore-webhook.service
    systemctl enable nxcore-cron-sync.timer
    
    # Verify services are running
    local webhook_status=$(systemctl is-active nxcore-webhook.service)
    local cron_status=$(systemctl is-active nxcore-cron-sync.timer)
    
    if [ "$webhook_status" = "active" ] && [ "$cron_status" = "active" ]; then
        log "Production mode enabled successfully"
        echo -e "${GREEN}✅ Auto-sync is now ENABLED${NC}"
        echo -e "${YELLOW}⚠️  Local changes will be overwritten on GitHub updates${NC}"
    else
        error "Failed to enable production mode"
        return 1
    fi
}

# Enable development mode (auto-sync off)
enable_development() {
    log "Enabling development mode (auto-sync disabled)..."
    
    # Stop services
    systemctl stop nxcore-webhook.service
    systemctl stop nxcore-cron-sync.timer
    
    # Disable services from starting on boot
    systemctl disable nxcore-webhook.service
    systemctl disable nxcore-cron-sync.timer
    
    # Verify services are stopped
    local webhook_status=$(systemctl is-active nxcore-webhook.service 2>/dev/null || echo "inactive")
    local cron_status=$(systemctl is-active nxcore-cron-sync.timer 2>/dev/null || echo "inactive")
    
    if [ "$webhook_status" = "inactive" ] && [ "$cron_status" = "inactive" ]; then
        log "Development mode enabled successfully"
        echo -e "${GREEN}✅ Auto-sync is now DISABLED${NC}"
        echo -e "${BLUE}💡 You can now make local changes without them being overwritten${NC}"
    else
        error "Failed to enable development mode"
        return 1
    fi
}

# Show current status
show_status() {
    local current_mode=$(check_mode)
    local webhook_status=$(systemctl is-active nxcore-webhook.service 2>/dev/null || echo "inactive")
    local cron_status=$(systemctl is-active nxcore-cron-sync.timer 2>/dev/null || echo "inactive")
    
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    NXCore Development Mode Status     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    if [ "$current_mode" = "production" ]; then
        echo -e "${GREEN}Current Mode: PRODUCTION${NC}"
        echo -e "${YELLOW}Auto-sync: ENABLED${NC}"
        echo -e "${RED}⚠️  Local changes will be overwritten${NC}"
    else
        echo -e "${BLUE}Current Mode: DEVELOPMENT${NC}"
        echo -e "${GREEN}Auto-sync: DISABLED${NC}"
        echo -e "${GREEN}✅ Local changes are safe${NC}"
    fi
    
    echo
    echo -e "${BLUE}Service Status:${NC}"
    echo -e "  Webhook Service: $webhook_status"
    echo -e "  Cron Sync Timer: $cron_status"
    echo
    
    # Show recent activity
    if [ -f "/var/log/nxcore-autosync.log" ]; then
        echo -e "${BLUE}Recent Auto-Sync Activity:${NC}"
        tail -3 "/var/log/nxcore-autosync.log" | sed 's/^/  /'
    fi
    echo
}

# Manual sync (one-time)
manual_sync() {
    log "Performing manual sync..."
    
    cd "$REPO_DIR"
    
    # Check for local changes
    if git status --porcelain | grep -q "^M\|^A\|^D"; then
        warn "Local changes detected:"
        git status --porcelain | sed 's/^/  /'
        echo
        echo -e "${YELLOW}These changes will be lost. Continue? (y/N):${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Manual sync cancelled by user"
            return 1
        fi
    fi
    
    # Pull latest changes
    git pull origin master
    
    # Make scripts executable
    chmod +x scripts/*.sh
    
    log "Manual sync completed successfully"
    echo -e "${GREEN}✅ Manual sync completed${NC}"
}

# Interactive menu
interactive_menu() {
    while true; do
        show_status
        
        echo -e "${BLUE}Development Mode Options:${NC}"
        echo "1) Enable Development Mode (disable auto-sync)"
        echo "2) Enable Production Mode (enable auto-sync)"
        echo "3) Manual Sync (one-time pull from GitHub)"
        echo "4) Show Status"
        echo "5) Exit"
        echo
        
        read -p "Choose an option (1-5): " choice
        
        case $choice in
            1)
                enable_development
                ;;
            2)
                enable_production
                ;;
            3)
                manual_sync
                ;;
            4)
                show_status
                ;;
            5)
                log "Exiting development mode manager"
                exit 0
                ;;
            *)
                error "Invalid option. Please choose 1-5."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Main execution
case "${1:-menu}" in
    menu)
        interactive_menu
        ;;
    dev|development)
        enable_development
        ;;
    prod|production)
        enable_production
        ;;
    status)
        show_status
        ;;
    sync)
        manual_sync
        ;;
    *)
        echo "Usage: $0 {menu|dev|prod|status|sync}"
        echo
        echo "Commands:"
        echo "  menu        - Interactive menu"
        echo "  dev         - Enable development mode (disable auto-sync)"
        echo "  prod        - Enable production mode (enable auto-sync)"
        echo "  status      - Show current status"
        echo "  sync        - Manual sync (one-time pull from GitHub)"
        echo
        echo "Examples:"
        echo "  $0 dev      # Disable auto-sync for development"
        echo "  $0 prod     # Enable auto-sync for production"
        echo "  $0 status   # Check current mode"
        exit 1
        ;;
esac
