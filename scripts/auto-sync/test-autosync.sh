#!/bin/bash
# Test Auto-Sync System for NXCore
# Tests webhook receiver and cron sync functionality

set -e

# Configuration
REPO_DIR="/srv/core"
WEBHOOK_PORT="${WEBHOOK_PORT:-8080}"
WEBHOOK_SECRET="${GITHUB_WEBHOOK_SECRET:-nxcore-autosync-2024}"

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

# Test webhook signature generation
test_webhook_signature() {
    log "Testing webhook signature generation..."
    
    local payload='{"test": "data"}'
    local expected=$(echo -n "$payload" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | cut -d' ' -f2)
    
    echo "Payload: $payload"
    echo "Secret: $WEBHOOK_SECRET"
    echo "Expected signature: sha256=$expected"
    
    log "Webhook signature test completed"
}

# Test webhook receiver
test_webhook_receiver() {
    log "Testing webhook receiver..."
    
    # Check if webhook service is running
    if systemctl is-active --quiet nxcore-webhook.service; then
        log "Webhook service is running"
    else
        warn "Webhook service is not running"
        return 1
    fi
    
    # Test webhook endpoint
    local payload='{"test": "webhook"}'
    local signature=$(echo -n "$payload" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | cut -d' ' -f2)
    
    log "Sending test webhook..."
    
    # Send test webhook
    response=$(echo -e "POST /webhook HTTP/1.1\r\nHost: localhost:$WEBHOOK_PORT\r\nX-Hub-Signature-256: sha256=$signature\r\nContent-Length: ${#payload}\r\n\r\n$payload" | nc localhost $WEBHOOK_PORT)
    
    if echo "$response" | grep -q "200 OK"; then
        log "Webhook test successful"
    else
        error "Webhook test failed: $response"
        return 1
    fi
}

# Test cron sync
test_cron_sync() {
    log "Testing cron sync..."
    
    # Check if cron timer is active
    if systemctl is-active --quiet nxcore-cron-sync.timer; then
        log "Cron sync timer is active"
    else
        warn "Cron sync timer is not active"
    fi
    
    # Run manual sync test
    log "Running manual sync test..."
    if $REPO_DIR/scripts/auto-sync/cron-git-sync.sh check; then
        log "Manual sync test successful"
    else
        error "Manual sync test failed"
        return 1
    fi
}

# Test service restart logic
test_service_restart() {
    log "Testing service restart logic..."
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        error "Docker is not running"
        return 1
    fi
    
    # Test landing service restart
    log "Testing landing service restart..."
    if docker-compose -f $REPO_DIR/docker/compose-landing.yml ps | grep -q "Up"; then
        log "Landing service is running, testing restart..."
        docker-compose -f $REPO_DIR/docker/compose-landing.yml restart landing
        sleep 5
        
        if docker-compose -f $REPO_DIR/docker/compose-landing.yml ps | grep -q "Up"; then
            log "Landing service restart test successful"
        else
            error "Landing service restart test failed"
            return 1
        fi
    else
        warn "Landing service is not running, skipping restart test"
    fi
}

# Test log files
test_log_files() {
    log "Testing log files..."
    
    local log_files=(
        "/var/log/nxcore-autosync.log"
        "/var/log/nxcore-cron-sync.log"
    )
    
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            log "Log file exists: $log_file"
            log "Last 5 lines:"
            tail -5 "$log_file" | sed 's/^/  /'
        else
            warn "Log file does not exist: $log_file"
        fi
    done
}

# Display system status
display_status() {
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    NXCore Auto-Sync System Status    ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${GREEN}Service Status:${NC}"
    echo -e "  Webhook Service: $(systemctl is-active nxcore-webhook.service 2>/dev/null || echo 'not installed')"
    echo -e "  Cron Timer: $(systemctl is-active nxcore-cron-sync.timer 2>/dev/null || echo 'not installed')"
    echo
    
    echo -e "${GREEN}Configuration:${NC}"
    echo -e "  Webhook Port: $WEBHOOK_PORT"
    echo -e "  Repository: $REPO_DIR"
    echo -e "  Webhook Secret: ${WEBHOOK_SECRET:0:10}..."
    echo
    
    echo -e "${GREEN}Recent Activity:${NC}"
    if [ -f "/var/log/nxcore-autosync.log" ]; then
        echo "  Webhook Log (last 3 lines):"
        tail -3 "/var/log/nxcore-autosync.log" | sed 's/^/    /'
    fi
    
    if [ -f "/var/log/nxcore-cron-sync.log" ]; then
        echo "  Cron Sync Log (last 3 lines):"
        tail -3 "/var/log/nxcore-cron-sync.log" | sed 's/^/    /'
    fi
    echo
}

# Main test function
main() {
    log "Starting NXCore Auto-Sync tests..."
    
    local tests_passed=0
    local tests_failed=0
    
    # Run tests
    if test_webhook_signature; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    if test_webhook_receiver; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    if test_cron_sync; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    if test_service_restart; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    test_log_files  # This test doesn't fail the overall test
    
    # Display results
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}           Test Results Summary        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Tests Passed: $tests_passed${NC}"
    echo -e "${RED}Tests Failed: $tests_failed${NC}"
    echo
    
    if [ $tests_failed -eq 0 ]; then
        log "All tests passed! Auto-sync system is working correctly."
        exit 0
    else
        error "Some tests failed. Please check the logs and configuration."
        exit 1
    fi
}

# Handle command line arguments
case "${1:-all}" in
    all)
        main
        ;;
    signature)
        test_webhook_signature
        ;;
    webhook)
        test_webhook_receiver
        ;;
    cron)
        test_cron_sync
        ;;
    restart)
        test_service_restart
        ;;
    logs)
        test_log_files
        ;;
    status)
        display_status
        ;;
    *)
        echo "Usage: $0 {all|signature|webhook|cron|restart|logs|status}"
        exit 1
        ;;
esac
