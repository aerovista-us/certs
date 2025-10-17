#!/bin/bash
# Setup Auto-Sync System for NXCore
# Installs and configures automatic GitHub synchronization

set -e

# Configuration
REPO_DIR="/srv/core"
WEBHOOK_PORT="${WEBHOOK_PORT:-8080}"
WEBHOOK_SECRET="${GITHUB_WEBHOOK_SECRET:-nxcore-autosync-$(date +%s)}"
SYNC_INTERVAL="${SYNC_INTERVAL:-300}"  # 5 minutes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Install required packages
install_dependencies() {
    log "Installing required packages..."
    
    # Update package list
    apt-get update
    
    # Install netcat for webhook server
    apt-get install -y netcat-openbsd
    
    # Install openssl for webhook signature verification
    apt-get install -y openssl
    
    log "Dependencies installed successfully"
}

# Create systemd service for webhook receiver
create_webhook_service() {
    log "Creating webhook receiver systemd service..."
    
    cat > /etc/systemd/system/nxcore-webhook.service << EOF
[Unit]
Description=NXCore GitHub Webhook Receiver
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=$REPO_DIR
ExecStart=$REPO_DIR/scripts/auto-sync/github-webhook-receiver.sh start
Restart=always
RestartSec=10
Environment=GITHUB_WEBHOOK_SECRET=$WEBHOOK_SECRET
Environment=WEBHOOK_PORT=$WEBHOOK_PORT
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable nxcore-webhook.service
    
    log "Webhook service created and enabled"
}

# Create systemd timer for cron sync
create_cron_timer() {
    log "Creating cron sync systemd timer..."
    
    # Create the service
    cat > /etc/systemd/system/nxcore-cron-sync.service << EOF
[Unit]
Description=NXCore Cron Git Sync
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
User=root
WorkingDirectory=$REPO_DIR
ExecStart=$REPO_DIR/scripts/auto-sync/cron-git-sync.sh check
Environment=SYNC_INTERVAL=$SYNC_INTERVAL
StandardOutput=journal
StandardError=journal
EOF

    # Create the timer
    cat > /etc/systemd/system/nxcore-cron-sync.timer << EOF
[Unit]
Description=Run NXCore Cron Git Sync every $SYNC_INTERVAL seconds
Requires=nxcore-cron-sync.service

[Timer]
OnBootSec=60
OnUnitActiveSec=$SYNC_INTERVAL
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable nxcore-cron-sync.timer
    
    log "Cron sync timer created and enabled"
}

# Create log rotation
setup_log_rotation() {
    log "Setting up log rotation..."
    
    cat > /etc/logrotate.d/nxcore-autosync << EOF
/var/log/nxcore-autosync.log
/var/log/nxcore-cron-sync.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        systemctl reload nxcore-webhook.service > /dev/null 2>&1 || true
    endscript
}
EOF

    log "Log rotation configured"
}

# Create firewall rules
setup_firewall() {
    log "Setting up firewall rules for webhook..."
    
    # Allow webhook port
    ufw allow $WEBHOOK_PORT/tcp comment "NXCore GitHub Webhook"
    
    log "Firewall rules configured"
}

# Generate webhook configuration
generate_webhook_config() {
    log "Generating webhook configuration..."
    
    cat > $REPO_DIR/scripts/auto-sync/webhook-config.env << EOF
# NXCore Auto-Sync Configuration
# Generated on $(date)

# Webhook Configuration
GITHUB_WEBHOOK_SECRET=$WEBHOOK_SECRET
WEBHOOK_PORT=$WEBHOOK_PORT

# Sync Configuration
SYNC_INTERVAL=$SYNC_INTERVAL
REPO_DIR=$REPO_DIR

# GitHub Repository
GITHUB_REPO=aerovista-us/nxcore
GITHUB_WEBHOOK_URL=https://nxcore.tail79107c.ts.net:$WEBHOOK_PORT/webhook
EOF

    log "Webhook configuration saved to $REPO_DIR/scripts/auto-sync/webhook-config.env"
}

# Display setup summary
display_summary() {
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    NXCore Auto-Sync Setup Complete    ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    echo -e "${GREEN}Webhook Configuration:${NC}"
    echo -e "  URL: https://nxcore.tail79107c.ts.net:$WEBHOOK_PORT/webhook"
    echo -e "  Secret: $WEBHOOK_SECRET"
    echo -e "  Port: $WEBHOOK_PORT"
    echo
    echo -e "${GREEN}Cron Sync Configuration:${NC}"
    echo -e "  Interval: $SYNC_INTERVAL seconds ($(($SYNC_INTERVAL/60)) minutes)"
    echo -e "  Service: nxcore-cron-sync.timer"
    echo
    echo -e "${GREEN}Services Created:${NC}"
    echo -e "  • nxcore-webhook.service (webhook receiver)"
    echo -e "  • nxcore-cron-sync.service (periodic sync)"
    echo -e "  • nxcore-cron-sync.timer (sync scheduler)"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "  1. Start services: systemctl start nxcore-webhook nxcore-cron-sync.timer"
    echo -e "  2. Configure GitHub webhook with the URL and secret above"
    echo -e "  3. Test the setup with: $REPO_DIR/scripts/auto-sync/test-autosync.sh"
    echo
    echo -e "${BLUE}Configuration saved to: $REPO_DIR/scripts/auto-sync/webhook-config.env${NC}"
    echo
}

# Main installation
main() {
    log "Starting NXCore Auto-Sync setup..."
    
    check_root
    install_dependencies
    create_webhook_service
    create_cron_timer
    setup_log_rotation
    setup_firewall
    generate_webhook_config
    
    log "Auto-sync setup completed successfully!"
    display_summary
}

# Handle command line arguments
case "${1:-install}" in
    install)
        main
        ;;
    start)
        log "Starting auto-sync services..."
        systemctl start nxcore-webhook.service
        systemctl start nxcore-cron-sync.timer
        log "Services started successfully"
        ;;
    stop)
        log "Stopping auto-sync services..."
        systemctl stop nxcore-webhook.service
        systemctl stop nxcore-cron-sync.timer
        log "Services stopped successfully"
        ;;
    status)
        echo "Webhook Service Status:"
        systemctl status nxcore-webhook.service --no-pager
        echo
        echo "Cron Sync Timer Status:"
        systemctl status nxcore-cron-sync.timer --no-pager
        ;;
    uninstall)
        log "Uninstalling auto-sync system..."
        systemctl stop nxcore-webhook.service || true
        systemctl stop nxcore-cron-sync.timer || true
        systemctl disable nxcore-webhook.service || true
        systemctl disable nxcore-cron-sync.timer || true
        rm -f /etc/systemd/system/nxcore-webhook.service
        rm -f /etc/systemd/system/nxcore-cron-sync.service
        rm -f /etc/systemd/system/nxcore-cron-sync.timer
        rm -f /etc/logrotate.d/nxcore-autosync
        systemctl daemon-reload
        log "Auto-sync system uninstalled"
        ;;
    *)
        echo "Usage: $0 {install|start|stop|status|uninstall}"
        exit 1
        ;;
esac
