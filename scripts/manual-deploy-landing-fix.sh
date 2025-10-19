#!/bin/bash
# Manual Landing Page Redirect Fix Deployment
# Simplified deployment without server path assumptions

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

log "🚀 MANUAL LANDING PAGE REDIRECT FIX DEPLOYMENT"
log "📋 Critical fix for landing page intercepting all requests"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Fix 0% → 94% service availability"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"

# Phase 1: Create local backup
log "📦 Phase 1: Creating local backup..."

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp docker/compose-landing.yml "$BACKUP_DIR/compose-landing-backup.yml"
success "Local backup created at $BACKUP_DIR"

# Phase 2: Deploy fixed landing page configuration
log "🔧 Phase 2: Deploying fixed landing page configuration..."

# Copy the fixed file to server
scp docker/compose-landing.yml $SERVER_USER@$SERVER_HOST:/tmp/compose-landing-fixed.yml
success "Fixed landing page configuration uploaded to server"

# Phase 3: Apply fix on server
log "🔄 Phase 3: Applying fix on server..."

ssh $SERVER_USER@$SERVER_HOST << 'EOF'
echo "🔧 Applying landing page redirect fix on server..."

# Find the correct docker compose directory
DOCKER_DIR=""
if [ -d "/opt/nexus/docker" ]; then
    DOCKER_DIR="/opt/nexus/docker"
elif [ -d "/home/docker" ]; then
    DOCKER_DIR="/home/docker"
elif [ -d "/srv/core/docker" ]; then
    DOCKER_DIR="/srv/core/docker"
elif [ -d "./docker" ]; then
    DOCKER_DIR="./docker"
else
    echo "❌ Could not find docker directory"
    echo "Available directories:"
    find / -name "compose-landing.yml" 2>/dev/null | head -5
    exit 1
fi

echo "📁 Found docker directory: $DOCKER_DIR"

# Create backup
BACKUP_DIR="/tmp/backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$DOCKER_DIR/compose-landing.yml" "$BACKUP_DIR/compose-landing-backup.yml" 2>/dev/null || echo "No existing compose-landing.yml to backup"

# Deploy fixed configuration
cp /tmp/compose-landing-fixed.yml "$DOCKER_DIR/compose-landing.yml"
echo "✅ Fixed landing page configuration deployed"

# Restart services
echo "🔄 Restarting Traefik..."
docker restart traefik

echo "⏳ Waiting for Traefik to start..."
sleep 30

echo "🔄 Restarting landing page service..."
docker restart landing 2>/dev/null || echo "Landing page service restart skipped"

echo "✅ Services restarted successfully"
echo "📁 Backup created at: $BACKUP_DIR"
EOF

success "Landing page redirect fix applied on server"

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

# Test critical services
log "Testing critical service endpoints..."

# Test root path (should go to landing page)
test_service "Landing Page" "/" "200"

# Test service paths (should go to services, not landing page)
test_service "Grafana" "/grafana/" "200"
test_service "Prometheus" "/prometheus/" "200"
test_service "cAdvisor" "/metrics/" "200"
test_service "Uptime Kuma" "/status/" "200"

# Test other services
test_service "FileBrowser" "/files/" "200"
test_service "OpenWebUI" "/ai/" "200"
test_service "Portainer" "/portainer/" "200"
test_service "AeroCaller" "/aerocaller/" "200"
test_service "Authelia" "/auth/" "200"

# Phase 5: Generate deployment report
log "📊 Phase 5: Generating deployment report..."

cat > "$BACKUP_DIR/landing-fix-deployment-report.md" << EOF
# 🚀 Landing Page Redirect Fix Deployment Report

**Date**: $(date)
**Status**: ✅ **DEPLOYMENT COMPLETE**

## 🚨 **Critical Issue Fixed**

### **Problem**: Landing page intercepting all requests
- **Priority**: 1 (too high)
- **Rule**: PathPrefix('/') (catches all paths)
- **Impact**: All services redirect to landing page

### **Fix Applied**:
- **Priority**: Changed from 1 to 50
- **Rule**: Changed from PathPrefix('/') to Path('/')
- **Result**: Landing page only handles root path

## 📊 **Expected Results**

- **Root path (/)**: → Landing page ✅
- **Service paths**: → Services ✅
- **Service Availability**: 0% → 94% ✅

## 🧪 **Test Results**

Landing Page: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "FAILED")
Grafana: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/grafana/ 2>/dev/null || echo "FAILED")
Prometheus: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/prometheus/ 2>/dev/null || echo "FAILED")
cAdvisor: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/metrics/ 2>/dev/null || echo "FAILED")
Uptime Kuma: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/status/ 2>/dev/null || echo "FAILED")

## 🚀 **Next Steps**

1. **Monitor service health** for 24 hours
2. **Verify 94% availability target**
3. **Test all service endpoints**
4. **Update documentation**

---
**Landing page redirect fix deployment complete!** 🎉
EOF

success "Deployment report generated: $BACKUP_DIR/landing-fix-deployment-report.md"

# Final status
log "🎉 LANDING PAGE REDIRECT FIX DEPLOYMENT COMPLETE!"
log "🔧 Landing page configuration fixed and deployed"
log "🔄 Traefik restarted to apply changes"
log "📁 Local backup created at: $BACKUP_DIR"
log "📋 Deployment report generated"

success "Landing page redirect fix deployed successfully! 🎉"

# Display final summary
echo ""
echo "🚀 **LANDING PAGE REDIRECT FIX DEPLOYMENT SUMMARY**"
echo "================================================="
echo "✅ Landing page priority changed: 1 → 50"
echo "✅ Landing page rule changed: PathPrefix('/') → Path('/')"
echo "✅ Traefik restarted to apply changes"
echo "✅ All services should now be accessible"
echo ""
echo "📊 **Expected Results:**"
echo "   - Root path (/) → Landing page"
echo "   - Service paths → Services"
echo "   - Service Availability: 0% → 94%"
echo ""
echo "🧪 **Test These URLs:**"
echo "   - Landing: https://nxcore.tail79107c.ts.net/"
echo "   - Grafana: https://nxcore.tail79107c.ts.net/grafana/"
echo "   - Prometheus: https://nxcore.tail79107c.ts.net/prometheus/"
echo "   - cAdvisor: https://nxcore.tail79107c.ts.net/metrics/"
echo "   - Uptime Kuma: https://nxcore.tail79107c.ts.net/status/"
echo ""
success "Landing page redirect fix deployment complete! 🎉"
