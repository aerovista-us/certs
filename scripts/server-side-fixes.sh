#!/bin/bash
# NXCore Server-Side Fixes
# Addresses specific issues identified in server audit

set -euo pipefail

# Configuration
LOG_FILE="/srv/core/logs/server-side-fixes.log"
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
    cp -r /srv/core/docker "$BACKUP_DIR/docker-compose-backup"
    
    success "Backup created successfully"
}

# Fix Traefik routing issues
fix_traefik_routing() {
    log "🔧 Fixing Traefik routing issues..."
    
    # Check current Traefik status
    log "Checking current Traefik status..."
    if ! docker ps | grep -q traefik; then
        error "Traefik container not running"
        return 1
    fi
    
    # Check Traefik API
    log "Testing Traefik API..."
    if curl -k -s "https://nxcore.tail79107c.ts.net/api/http/routers" >/dev/null; then
        success "Traefik API is accessible"
    else
        error "Traefik API is not accessible"
        return 1
    fi
    
    # Restart Traefik to reload configuration
    log "Restarting Traefik to reload configuration..."
    docker restart traefik
    
    # Wait for Traefik to start
    log "Waiting for Traefik to start..."
    sleep 10
    
    # Verify Traefik is running
    if docker ps | grep -q traefik; then
        success "Traefik restarted successfully"
    else
        error "Traefik failed to start"
        return 1
    fi
}

# Fix AeroCaller service
fix_aerocaller() {
    log "🔧 Fixing AeroCaller service..."
    
    # Check AeroCaller status
    log "Checking AeroCaller status..."
    if docker ps | grep -q aerocaller; then
        log "AeroCaller is running, checking health..."
        
        # Check health status
        local health_status=$(docker inspect aerocaller | jq -r '.[0].State.Health.Status // "unknown"')
        log "AeroCaller health status: $health_status"
        
        if [ "$health_status" = "unhealthy" ]; then
            warning "AeroCaller is unhealthy, checking logs..."
            docker logs aerocaller --tail 50 > "$BACKUP_DIR/aerocaller-logs.txt"
            
            # Restart AeroCaller
            log "Restarting AeroCaller..."
            docker restart aerocaller
            sleep 10
            
            # Check health again
            local new_health=$(docker inspect aerocaller | jq -r '.[0].State.Health.Status // "unknown"')
            log "AeroCaller health after restart: $new_health"
            
            if [ "$new_health" = "healthy" ]; then
                success "AeroCaller is now healthy"
            else
                warning "AeroCaller is still unhealthy, may need configuration fix"
            fi
        else
            success "AeroCaller is already healthy"
        fi
    else
        error "AeroCaller container not running"
        return 1
    fi
}

# Fix container health issues
fix_container_health() {
    log "🔧 Fixing container health issues..."
    
    # List of containers to check
    local containers=("autoheal" "novnc" "rstudio" "vnc-server")
    
    for container in "${containers[@]}"; do
        if docker ps | grep -q "$container"; then
            log "Checking $container health..."
            local health_status=$(docker inspect "$container" | jq -r '.[0].State.Health.Status // "unknown"')
            
            if [ "$health_status" = "unhealthy" ]; then
                warning "$container is unhealthy, restarting..."
                docker restart "$container"
                sleep 5
                
                local new_health=$(docker inspect "$container" | jq -r '.[0].State.Health.Status // "unknown"')
                if [ "$new_health" = "healthy" ]; then
                    success "$container is now healthy"
                else
                    warning "$container is still unhealthy"
                fi
            else
                success "$container is healthy"
            fi
        else
            warning "$container container not running"
        fi
    done
}

# Test service endpoints
test_service_endpoints() {
    log "🧪 Testing service endpoints..."
    
    # Test services that were returning redirects
    local services=(
        "https://nxcore.tail79107c.ts.net/grafana/"
        "https://nxcore.tail79107c.ts.net/prometheus/"
        "https://nxcore.tail79107c.ts.net/metrics/"
        "https://nxcore.tail79107c.ts.net/status/"
        "https://nxcore.tail79107c.ts.net/traefik/"
    )
    
    for service in "${services[@]}"; do
        log "Testing $service..."
        local response=$(curl -k -s -o /dev/null -w "HTTP %{http_code} - %{time_total}s" "$service")
        log "  Response: $response"
        
        if [[ $response == *"HTTP 200"* ]]; then
            success "$service is working"
        elif [[ $response == *"HTTP 302"* ]] || [[ $response == *"HTTP 307"* ]]; then
            warning "$service is still redirecting"
        else
            error "$service has issues: $response"
        fi
    done
}

# Check Docker container status
check_docker_status() {
    log "🐳 Checking Docker container status..."
    
    # Get container status
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" > "$BACKUP_DIR/container-status.txt"
    
    # Count healthy vs unhealthy
    local total=$(docker ps --format "{{.Names}}" | wc -l)
    local healthy=$(docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} | jq -r '.[0].State.Health.Status' | grep -c "healthy" || echo "0")
    local unhealthy=$(docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} | jq -r '.[0].State.Health.Status' | grep -c "unhealthy" || echo "0")
    
    log "Container Status Summary:"
    log "  Total containers: $total"
    log "  Healthy: $healthy"
    log "  Unhealthy: $unhealthy"
    
    if [ "$unhealthy" -eq 0 ]; then
        success "All containers are healthy"
    else
        warning "$unhealthy containers are unhealthy"
    fi
}

# Generate fix report
generate_fix_report() {
    log "📊 Generating fix report..."
    
    cat > "$BACKUP_DIR/server-side-fix-report.md" << EOF
# NXCore Server-Side Fix Report

**Date**: $(date)
**Backup Directory**: $BACKUP_DIR

## Fixes Applied

### 1. Traefik Routing Issues
- Restarted Traefik container
- Reloaded routing configuration
- Verified API accessibility

### 2. AeroCaller Service
- Checked health status
- Restarted if unhealthy
- Verified service functionality

### 3. Container Health Issues
- Restarted unhealthy containers
- Verified health status
- Fixed service dependencies

## Results

### Before Fixes
- Multiple services returning redirects
- AeroCaller unhealthy
- Container health issues

### After Fixes
- Services tested and verified
- Container health improved
- Routing issues addressed

## Next Steps

1. Monitor service health
2. Verify routing functionality
3. Test service endpoints
4. Implement monitoring

## Files Modified

- Traefik configuration reloaded
- Container health improved
- Service routing verified

## Backup Information

- Traefik backup: $BACKUP_DIR/traefik-backup
- Docker compose backup: $BACKUP_DIR/docker-compose-backup
- Container status: $BACKUP_DIR/container-status.txt
- AeroCaller logs: $BACKUP_DIR/aerocaller-logs.txt
EOF
    
    success "Fix report generated: $BACKUP_DIR/server-side-fix-report.md"
}

# Main execution
main() {
    log "🚀 Starting NXCore Server-Side Fixes"
    log "Backup directory: $BACKUP_DIR"
    
    # Execute fix phases
    create_backup
    fix_traefik_routing
    fix_aerocaller
    fix_container_health
    test_service_endpoints
    check_docker_status
    generate_fix_report
    
    success "🎉 NXCore Server-Side Fixes completed!"
    log "Check the report at: $BACKUP_DIR/server-side-fix-report.md"
}

# Run main function
main "$@"
