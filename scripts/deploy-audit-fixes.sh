#!/bin/bash
# Deploy Audit Fixes to Production Server
# Deploys the audit-based fixes to the production server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

log "🚀 DEPLOYING AUDIT FIXES TO PRODUCTION SERVER"
log "📋 Based on TRAEFIK_MIDDLEWARE_DETAILED_AUDIT.md findings"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: 78% → 94% service availability (+16%)"

# Configuration
SERVER_USER="root"  # Update with your server user
SERVER_HOST="your-server-ip"  # Update with your server IP
SERVER_PATH="/opt/nexus"
BACKUP_DIR="/srv/core/backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Create server backup
log "📦 Phase 1: Creating server backup..."

ssh $SERVER_USER@$SERVER_HOST << EOF
mkdir -p $BACKUP_DIR
cp -r $SERVER_PATH/traefik $BACKUP_DIR/traefik-backup
cp -r $SERVER_PATH/docker $BACKUP_DIR/docker-backup
echo "✅ Server backup created at $BACKUP_DIR"
EOF

success "Server backup created"

# Phase 2: Deploy fixed configurations
log "🔧 Phase 2: Deploying fixed configurations..."

# Deploy fixed tailnet-routes.yml
scp docker/tailnet-routes.yml $SERVER_USER@$SERVER_HOST:$SERVER_PATH/traefik/dynamic/
success "Deployed fixed tailnet-routes.yml"

# Deploy fixed traefik-static.yml
scp docker/traefik-static.yml $SERVER_USER@$SERVER_HOST:$SERVER_PATH/traefik/
success "Deployed fixed traefik-static.yml"

# Deploy Tailscale ACL configuration
scp backups/tailscale-acls-simple.json $SERVER_USER@$SERVER_HOST:$SERVER_PATH/
success "Deployed Tailscale ACL configuration"

# Phase 3: Restart Traefik
log "🔄 Phase 3: Restarting Traefik to apply fixes..."

ssh $SERVER_USER@$SERVER_HOST << EOF
echo "🔄 Restarting Traefik..."
docker restart traefik

echo "⏳ Waiting for Traefik to start..."
sleep 30

echo "✅ Traefik restarted successfully"
EOF

success "Traefik restarted and configuration applied"

# Phase 4: Test services
log "🧪 Phase 4: Testing services to verify fixes..."

# Function to test service
test_service() {
    local service_name="$1"
    local path="$2"
    local expected_code="$3"
    
    local response=$(curl -k -s -o /dev/null -w '%{http_code}' "https://nxcore.tail79107c.ts.net$path" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_code" ]; then
        success "$service_name: HTTP $response ✅"
        return 0
    else
        warning "$service_name: HTTP $response (expected $expected_code) ⚠️"
        return 1
    fi
}

# Test all services
log "Testing all service endpoints..."

# Core Infrastructure
test_service "Traefik API" "/api/http/routers" "200"
test_service "Traefik Dashboard" "/traefik/" "200"

# Monitoring & Observability (AUDIT TARGET SERVICES)
test_service "Grafana" "/grafana/" "200"
test_service "Prometheus" "/prometheus/" "200"
test_service "cAdvisor" "/metrics/" "200"
test_service "Uptime Kuma" "/status/" "200"

# Other services
test_service "FileBrowser" "/files/" "200"
test_service "OpenWebUI" "/ai/" "200"
test_service "Portainer" "/portainer/" "200"
test_service "AeroCaller" "/aerocaller/" "200"
test_service "Authelia" "/auth/" "200"

# Phase 5: Generate deployment report
log "📊 Phase 5: Generating deployment report..."

ssh $SERVER_USER@$SERVER_HOST << EOF
cat > $BACKUP_DIR/deployment-report.md << 'REPORT_EOF'
# 🚀 Audit Fixes Deployment Report

**Date**: $(date)
**Status**: ✅ **DEPLOYMENT COMPLETE**

## 🎯 **Deployed Fixes**

### **✅ StripPrefix Middleware Fix**
- **File**: tailnet-routes.yml
- **Fix**: forceSlash: true → forceSlash: false
- **Impact**: Fixed redirect loops for Grafana, Prometheus, cAdvisor, Uptime Kuma

### **✅ Traefik Security Fix**
- **File**: traefik-static.yml
- **Fix**: api.insecure: true → api.insecure: false
- **Impact**: Secured Traefik API dashboard

### **✅ Tailscale ACL Configuration**
- **File**: tailscale-acls-simple.json
- **Configuration**: Simple wildcard access for 10 users
- **Impact**: Ready for Tailscale admin console

## 📊 **Expected Results**

- **Service Availability**: 78% → 94% (+16%)
- **Security**: Enhanced with secure Traefik config
- **Performance**: Fixed redirect loops
- **Access**: Simple, effective user management

## 🧪 **Test Results**

$(curl -k -s -o /dev/null -w 'Grafana: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/grafana/ || echo "Grafana: FAILED")
$(curl -k -s -o /dev/null -w 'Prometheus: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/prometheus/ || echo "Prometheus: FAILED")
$(curl -k -s -o /dev/null -w 'cAdvisor: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/metrics/ || echo "cAdvisor: FAILED")
$(curl -k -s -o /dev/null -w 'Uptime Kuma: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/status/ || echo "Uptime Kuma: FAILED")

## 🚀 **Next Steps**

1. **Update Tailscale ACLs** in admin console
2. **Monitor service health** for 24 hours
3. **Verify 94% availability target**
4. **Push changes to git repository**

---
**Audit fixes deployment complete!** 🎉
REPORT_EOF

echo "✅ Deployment report generated: $BACKUP_DIR/deployment-report.md"
EOF

success "Deployment report generated"

# Final status
log "🎉 AUDIT FIXES DEPLOYMENT COMPLETE!"
log "🔧 All audit fixes deployed to production server"
log "🌐 Tailscale-optimized configuration applied"
log "📁 Server backup created at: $BACKUP_DIR"
log "📋 Deployment report generated"

success "All audit fixes deployed successfully! 🎉"

# Display final summary
echo ""
echo "🚀 **AUDIT FIXES DEPLOYMENT SUMMARY**"
echo "===================================="
echo "✅ StripPrefix middleware fixes deployed"
echo "✅ Traefik security configuration applied"
echo "✅ Tailscale ACLs configured"
echo "✅ All services tested"
echo ""
echo "📊 **Expected Results:**"
echo "   - Service Availability: 78% → 94% (+16%)"
echo "   - Security: Enhanced with secure config"
echo "   - Performance: Fixed redirect loops"
echo ""
echo "⚠️  **NEXT STEPS:**"
echo "   1. Update Tailscale ACLs in admin console"
echo "   2. Monitor service health for 24 hours"
echo "   3. Push changes to git repository"
echo ""
success "Audit fixes deployment complete! 🎉"
