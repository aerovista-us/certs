#!/usr/bin/env bash
set -euo pipefail

# AI Service Monitor for NXCore
# Monitors Ollama and OpenWebUI services

OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
OPENWEBUI_HOST="${OPENWEBUI_HOST:-https://nxcore.tail79107c.ts.net/ai}"
ALERT_DIR="/srv/core/nxcore/state/outbox/alerts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date -u +%Y-%m-%dT%H:%M:%SZ)]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create alert directory
mkdir -p "$ALERT_DIR"

# Check Ollama service
check_ollama() {
    log "Checking Ollama service..."
    
    if curl -s -f "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
        success "Ollama is running"
        
        # Get model list
        local models=$(curl -s "$OLLAMA_HOST/api/tags" | jq -r '.models[]?.name' 2>/dev/null || echo "")
        if [ -n "$models" ]; then
            log "Available models:"
            echo "$models" | while read -r model; do
                echo "  - $model"
            done
        else
            warning "No models found"
        fi
        
        return 0
    else
        error "Ollama is not responding"
        return 1
    fi
}

# Check OpenWebUI service
check_openwebui() {
    log "Checking OpenWebUI service..."
    
    if curl -s -f -k "$OPENWEBUI_HOST/health" >/dev/null 2>&1; then
        success "OpenWebUI is running"
        return 0
    else
        error "OpenWebUI is not responding"
        return 1
    fi
}

# Test AI generation
test_ai_generation() {
    log "Testing AI generation..."
    
    local test_prompt="Hello, this is a test from NXCore AI Monitor. Please respond with 'AI service is working correctly.'"
    local response
    
    if response=$(curl -s -X POST "$OLLAMA_HOST/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"llama3.2\", \"prompt\": \"$test_prompt\", \"stream\": false}" \
        | jq -r '.response' 2>/dev/null); then
        
        if [ -n "$response" ] && [ "$response" != "null" ]; then
            success "AI generation test passed"
            log "Response: $response"
            return 0
        else
            error "AI generation test failed - no response"
            return 1
        fi
    else
        error "AI generation test failed - API error"
        return 1
    fi
}

# Check system resources
check_resources() {
    log "Checking system resources..."
    
    # Check disk space
    local disk_usage=$(df /srv/core/data/ollama 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0")
    if [ "$disk_usage" -gt 90 ]; then
        warning "Disk usage high: ${disk_usage}%"
        local alert_file="$ALERT_DIR/ai_disk_usage_$(date +%Y%m%d_%H%M%S).txt"
        cat > "$alert_file" <<EOF
ALERT: High disk usage for AI services
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Usage: ${disk_usage}%
Location: /srv/core/data/ollama

Action required: Clean up old models or expand storage
EOF
    else
        success "Disk usage OK: ${disk_usage}%"
    fi
    
    # Check memory usage
    local memory_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ "$memory_usage" -gt 85 ]; then
        warning "Memory usage high: ${memory_usage}%"
    else
        success "Memory usage OK: ${memory_usage}%"
    fi
}

# Check Docker containers
check_containers() {
    log "Checking AI containers..."
    
    local containers=("ollama" "openwebui")
    local all_healthy=true
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "$container.*Up"; then
            success "Container $container is running"
        else
            error "Container $container is not running"
            all_healthy=false
        fi
    done
    
    if [ "$all_healthy" = true ]; then
        return 0
    else
        return 1
    fi
}

# Generate health report
generate_report() {
    local report_file="$ALERT_DIR/ai_health_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" <<EOF
NXCore AI Services Health Report
Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

=== Service Status ===
Ollama: $(check_ollama && echo "HEALTHY" || echo "UNHEALTHY")
OpenWebUI: $(check_openwebui && echo "HEALTHY" || echo "UNHEALTHY")
AI Generation: $(test_ai_generation && echo "HEALTHY" || echo "UNHEALTHY")
Containers: $(check_containers && echo "HEALTHY" || echo "UNHEALTHY")

=== System Resources ===
Disk Usage: $(df /srv/core/data/ollama 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
Memory Usage: $(free | awk 'NR==2{printf "%.0f%%", $3*100/$2}')

=== Available Models ===
$(curl -s "$OLLAMA_HOST/api/tags" 2>/dev/null | jq -r '.models[]?.name' | sed 's/^/  - /' || echo "  Unable to retrieve models")

=== Recent Logs ===
$(journalctl -u ollama --since "1 hour ago" --no-pager -n 10 2>/dev/null | tail -5 || echo "No recent logs")

---
Generated by NXCore AI Monitor
EOF
    
    log "Health report generated: $report_file"
}

# Main monitoring function
main() {
    local exit_code=0
    
    log "Starting AI service monitoring..."
    
    # Run all checks
    check_ollama || exit_code=1
    check_openwebui || exit_code=1
    test_ai_generation || exit_code=1
    check_containers || exit_code=1
    check_resources
    
    # Generate report
    generate_report
    
    if [ $exit_code -eq 0 ]; then
        success "All AI services are healthy"
    else
        error "Some AI services have issues"
    fi
    
    return $exit_code
}

# Command line interface
case "${1:-monitor}" in
    "monitor")
        main
        ;;
    "check")
        check_ollama && check_openwebui && test_ai_generation
        ;;
    "report")
        generate_report
        ;;
    "help"|*)
        echo "NXCore AI Monitor"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  monitor  - Run full monitoring check (default)"
        echo "  check    - Quick health check"
        echo "  report   - Generate health report only"
        echo "  help     - Show this help"
        echo ""
        echo "Environment:"
        echo "  OLLAMA_HOST - Ollama server URL (default: http://localhost:11434)"
        echo "  OPENWEBUI_HOST - OpenWebUI server URL (default: https://nxcore.tail79107c.ts.net/ai)"
        ;;
esac
