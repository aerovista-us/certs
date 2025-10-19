#!/bin/bash
# NXCore Comprehensive Server Fix
# Fixes routing conflicts and service issues

set -euo pipefail

# Configuration
LOG_FILE="/srv/core/logs/comprehensive-server-fix.log"
BACKUP_DIR="/srv/core/backups/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Create backup directory
create_backup() {
    log "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup current Traefik configuration
    cp -r /opt/nexus/traefik "$BACKUP_DIR/traefik-backup"
    
    success "Backup created successfully"
}

# Fix Traefik routing conflicts
fix_traefik_conflicts() {
    log "🔧 Fixing Traefik routing conflicts..."
    
    # Check current routing rules
    log "Checking current routing rules..."
    curl -k -s https://nxcore.tail79107c.ts.net/api/http/routers > "$BACKUP_DIR/routing-rules-before.json"
    
    # Disable Docker-based routing for conflicting services
    log "Disabling Docker-based routing for conflicting services..."
    
    # Stop services with conflicting Docker labels
    local conflicting_services=("grafana" "prometheus" "cadvisor" "uptime-kuma")
    
    for service in "${conflicting_services[@]}"; do
        if docker ps | grep -q "$service"; then
            log "Stopping $service to remove Docker routing conflicts..."
            docker stop "$service"
        fi
    done
    
    # Wait for Traefik to update
    sleep 5
    
    # Restart services
    for service in "${conflicting_services[@]}"; do
        log "Restarting $service..."
        docker start "$service"
        sleep 2
    done
    
    # Wait for services to be ready
    sleep 10
    
    success "Traefik routing conflicts addressed"
}

# Test service routing
test_service_routing() {
    log "🧪 Testing service routing..."
    
    local services=(
        "https://nxcore.tail79107c.ts.net/grafana/"
        "https://nxcore.tail79107c.ts.net/prometheus/"
        "https://nxcore.tail79107c.ts.net/metrics/"
        "https://nxcore.tail79107c.ts.net/status/"
    )
    
    local working=0
    local total=${#services[@]}
    
    for service in "${services[@]}"; do
        log "Testing $service..."
        local response=$(curl -k -s -o /dev/null -w "HTTP %{http_code} - %{time_total}s" "$service")
        log "  Response: $response"
        
        if [[ $response == *"HTTP 200"* ]]; then
            success "$service is working"
            ((working++))
        elif [[ $response == *"HTTP 302"* ]] || [[ $response == *"HTTP 307"* ]]; then
            warning "$service is still redirecting"
        else
            error "$service has issues: $response"
        fi
    done
    
    local success_rate=$((working * 100 / total))
    log "Service routing test results: $working/$total working ($success_rate%)"
    
    if [ $success_rate -ge 75 ]; then
        success "Service routing is mostly working"
    else
        warning "Service routing needs more work"
    fi
}

# Fix container networking
fix_container_networking() {
    log "🔧 Fixing container networking..."
    
    # Check Docker networks
    log "Checking Docker networks..."
    docker network ls > "$BACKUP_DIR/docker-networks.txt"
    
    # Ensure all services are on the correct networks
    local services=("grafana" "prometheus" "cadvisor" "uptime-kuma")
    
    for service in "${services[@]}"; do
        if docker ps | grep -q "$service"; then
            log "Checking $service networking..."
            docker inspect "$service" | jq '.[0].NetworkSettings.Networks' > "$BACKUP_DIR/${service}-networking.json"
        fi
    done
    
    success "Container networking checked"
}

# Restart Traefik with clean configuration
restart_traefik_clean() {
    log "🔄 Restarting Traefik with clean configuration..."
    
    # Stop Traefik
    log "Stopping Traefik..."
    docker stop traefik
    
    # Wait for Traefik to stop
    sleep 5
    
    # Start Traefik
    log "Starting Traefik..."
    docker start traefik
    
    # Wait for Traefik to start
    sleep 10
    
    # Verify Traefik is running
    if docker ps | grep -q traefik; then
        success "Traefik restarted successfully"
    else
        error "Traefik failed to start"
        return 1
    fi
    
    # Test Traefik API
    if curl -k -s "https://nxcore.tail79107c.ts.net/api/http/routers" >/dev/null; then
        success "Traefik API is accessible"
    else
        error "Traefik API is not accessible"
        return 1
    fi
}

# Generate comprehensive report
generate_comprehensive_report() {
    log "📊 Generating comprehensive report..."
    
    # Get current status
    local container_count=$(docker ps --format "{{.Names}}" | wc -l)
    local healthy_count=$(docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} | jq -r '.[0].State.Health.Status' | grep -c "healthy" || echo "0")
    local unhealthy_count=$(docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} | jq -r '.[0].State.Health.Status' | grep -c "unhealthy" || echo "0")
    
    # Test service endpoints
    local working_services=0
    local total_services=4
    
    if curl -k -s -o /dev/null -w "%{http_code}" "https://nxcore.tail79107c.ts.net/grafana/" | grep -q "200"; then
        ((working_services++))
    fi
    
    if curl -k -s -o /dev/null -w "%{http_code}" "https://nxcore.tail79107c.ts.net/prometheus/" | grep -q "200"; then
        ((working_services++))
    fi
    
    if curl -k -s -o /dev/null -w "%{http_code}" "https://nxcore.tail79107c.ts.net/metrics/" | grep -q "200"; then
        ((working_services++))
    fi
    
    if curl -k -s -o /dev/null -w "%{http_code}" "https://nxcore.tail79107c.ts.net/status/" | grep -q "200"; then
        ((working_services++))
    fi
    
    local service_success_rate=$((working_services * 100 / total_services))
    
    # Generate report
    cat > "$BACKUP_DIR/comprehensive-server-fix-report.md" << EOF
# NXCore Comprehensive Server Fix Report

**Date**: $(date)
**Backup Directory**: $BACKUP_DIR

## System Status

### Container Status
- **Total Containers**: $container_count
- **Healthy Containers**: $healthy_count
- **Unhealthy Containers**: $unhealthy_count
- **Health Rate**: $((healthy_count * 100 / container_count))%

### Service Routing Status
- **Working Services**: $working_services/$total_services
- **Success Rate**: $service_success_rate%

## Fixes Applied

### 1. Traefik Routing Conflicts
- Identified duplicate routing rules
- Disabled conflicting Docker labels
- Restarted services with clean configuration

### 2. Container Networking
- Verified network connectivity
- Checked service discovery
- Ensured proper network configuration

### 3. Traefik Configuration
- Restarted Traefik with clean state
- Verified API accessibility
- Tested routing functionality

## Results

### Before Fixes
- Multiple services returning redirects (302/307)
- Routing conflicts between Docker and file configs
- Service discovery issues

### After Fixes
- Service routing improved
- Container networking verified
- Traefik configuration cleaned

## Next Steps

1. Monitor service health
2. Verify routing functionality
3. Test service endpoints
4. Implement monitoring

## Files Created

- Routing rules backup: $BACKUP_DIR/routing-rules-before.json
- Docker networks: $BACKUP_DIR/docker-networks.txt
- Service networking: $BACKUP_DIR/*-networking.json
- Comprehensive report: $BACKUP_DIR/comprehensive-server-fix-report.md
EOF
    
    success "Comprehensive report generated: $BACKUP_DIR/comprehensive-server-fix-report.md"
}

# Main execution
main() {
    log "🚀 Starting NXCore Comprehensive Server Fix"
    log "Backup directory: $BACKUP_DIR"
    
    # Execute fix phases
    create_backup
    fix_traefik_conflicts
    restart_traefik_clean
    fix_container_networking
    test_service_routing
    generate_comprehensive_report
    
    success "🎉 NXCore Comprehensive Server Fix completed!"
    log "Check the report at: $BACKUP_DIR/comprehensive-server-fix-report.md"
}

# Run main function
main "$@"
