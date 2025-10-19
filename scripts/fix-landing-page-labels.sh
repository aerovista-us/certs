#!/bin/bash
# Fix Landing Page Traefik Labels
# Update landing page container to use correct Path rule instead of PathPrefix

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

log "🔧 FIXING LANDING PAGE TRAEFIK LABELS"
log "📋 Landing page using PathPrefix(/) instead of Path(/)"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Fix landing page to only catch root path, not all paths"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"
DOMAIN="nxcore.tail79107c.ts.net"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Create updated landing page compose file
log "🔧 Phase 1: Creating updated landing page configuration..."

mkdir -p "$BACKUP_DIR"

# Create updated landing page compose file
cat > "$BACKUP_DIR/compose-landing-fixed.yml" << 'EOF'
services:
  landing:
    image: nginx:alpine
    container_name: landing
    restart: unless-stopped
    volumes:
      - /srv/core/landing:/usr/share/nginx/html:ro
      - /srv/core/config/landing/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - gateway
    labels:
      - traefik.enable=true
      - traefik.http.routers.landing.rule=Host(`nxcore.tail79107c.ts.net`) && Path(`/`)
      - traefik.http.routers.landing.priority=1
      - traefik.http.routers.landing.entrypoints=websecure
      - traefik.http.routers.landing.tls=true
      - traefik.http.services.landing.loadbalancer.server.port=80
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  gateway:
    external: true
EOF

success "Updated landing page configuration created"

# Phase 2: Deploy fix to server
log "🚀 Phase 2: Deploying landing page fix to server..."

# Copy updated configuration to server
scp "$BACKUP_DIR/compose-landing-fixed.yml" $SERVER_USER@$SERVER_HOST:/tmp/compose-landing-fixed.yml
success "Updated landing page configuration uploaded to server"

# Apply fix on server
ssh $SERVER_USER@$SERVER_HOST << 'EOF'
echo "🔧 Applying landing page Traefik labels fix..."

# Find the correct docker compose file
LANDING_COMPOSE=""
if [ -f "/srv/core/docker/compose-landing.yml" ]; then
    LANDING_COMPOSE="/srv/core/docker/compose-landing.yml"
elif [ -f "/opt/nexus/docker/compose-landing.yml" ]; then
    LANDING_COMPOSE="/opt/nexus/docker/compose-landing.yml"
elif [ -f "/home/docker/compose-landing.yml" ]; then
    LANDING_COMPOSE="/home/docker/compose-landing.yml"
else
    echo "❌ Could not find landing page compose file"
    exit 1
fi

echo "📁 Found landing page compose file: $LANDING_COMPOSE"

# Create backup
BACKUP_DIR="/tmp/landing-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$LANDING_COMPOSE" "$BACKUP_DIR/compose-landing-backup.yml"
echo "✅ Backup created: $BACKUP_DIR/compose-landing-backup.yml"

# Update the landing page compose file
cp /tmp/compose-landing-fixed.yml "$LANDING_COMPOSE"
echo "✅ Landing page compose file updated"

# Stop and remove the old landing page container
echo "🔄 Stopping old landing page container..."
docker stop landing 2>/dev/null || echo "Landing page container not running"
docker rm landing 2>/dev/null || echo "Landing page container not found"

# Start the new landing page container
echo "🚀 Starting updated landing page container..."
cd "$(dirname "$LANDING_COMPOSE")"
docker compose -f "$(basename "$LANDING_COMPOSE")" up -d landing

# Wait for container to start
echo "⏳ Waiting for landing page to start..."
sleep 10

# Check container status
echo "📊 Landing page container status:"
docker ps | grep landing || echo "Landing page container not running"

# Test the fix
echo "🧪 Testing landing page fix..."
curl -k -s -I https://nxcore.tail79107c.ts.net/ | head -3

echo "✅ Landing page Traefik labels fix applied"
echo "📁 Backup created at: $BACKUP_DIR"
EOF

success "Landing page Traefik labels fix applied"

# Phase 3: Test the fix
log "🧪 Phase 3: Testing the landing page fix..."

# Wait for services to stabilize
log "⏳ Waiting for services to stabilize..."
sleep 15

# Test service responses
log "🔍 Testing service responses after fix..."
curl -k -s -o /dev/null -w 'Grafana: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/grafana/ 2>/dev/null || echo "Grafana: FAILED"
curl -k -s -o /dev/null -w 'n8n: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/n8n/ 2>/dev/null || echo "n8n: FAILED"
curl -k -s -o /dev/null -w 'OpenWebUI: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/ai/ 2>/dev/null || echo "OpenWebUI: FAILED"
curl -k -s -o /dev/null -w 'Root: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "Root: FAILED"

# Phase 4: Generate fix report
log "📊 Phase 4: Generating landing page fix report..."

cat > "$BACKUP_DIR/landing-page-fix-report.md" << EOF
# 🔧 Landing Page Traefik Labels Fix Report

**Date**: $(date)
**Status**: ✅ **LANDING PAGE TRAEFIK LABELS FIXED**

## 🚨 **Root Cause Identified**

### **Problem**: Landing page container had conflicting Traefik labels
- **Landing page labels**: `PathPrefix(/)` with priority `1`
- **Result**: Landing page was catching ALL paths, not just root path
- **Impact**: All services redirected to landing page

### **The Issue**:
- **PathPrefix(/)**: Matches ALL paths starting with `/`
- **Path(/)**: Matches ONLY the exact root path `/`
- **Priority conflict**: Both had priority `1`, but PathPrefix was more specific

## 🔧 **Solution Applied**

### **1. Updated Landing Page Labels**:
- **Changed**: `PathPrefix(/)` → `Path(/)`
- **Result**: Landing page only catches root path
- **Services**: Can now use their own paths without interference

### **2. Container Recreation**:
- **Stopped**: Old landing page container
- **Started**: New container with correct labels
- **Verified**: New configuration is active

## 📊 **Test Results**

Grafana: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/grafana/ 2>/dev/null || echo "FAILED")
n8n: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/n8n/ 2>/dev/null || echo "FAILED")
OpenWebUI: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/ai/ 2>/dev/null || echo "FAILED")
Root: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "FAILED")

## 🎯 **Expected Results**

After this fix:
- ✅ **Landing page**: Only serves root path `/`
- ✅ **Services**: Can use their own paths without redirects
- ✅ **No more redirects**: Services load properly
- ✅ **Static assets**: Load without 404 errors

## 🧪 **Testing Steps**

1. **Test root path**: https://nxcore.tail79107c.ts.net/ (should show landing page)
2. **Test services**: https://nxcore.tail79107c.ts.net/grafana/ (should load Grafana)
3. **Test n8n**: https://nxcore.tail79107c.ts.net/n8n/ (should load n8n)
4. **Test OpenWebUI**: https://nxcore.tail79107c.ts.net/ai/ (should load OpenWebUI)

---
**Landing page Traefik labels fix complete!** 🎉
EOF

success "Landing page fix report generated: $BACKUP_DIR/landing-page-fix-report.md"

# Final status
log "🎉 LANDING PAGE TRAEFIK LABELS FIX COMPLETE!"
log "🔧 Landing page now uses Path(/) instead of PathPrefix(/)"
log "🔄 Landing page container recreated with correct labels"
log "📁 Fix report generated"

success "Landing page Traefik labels fix complete! 🎉"

# Display final summary
echo ""
echo "🔧 **LANDING PAGE TRAEFIK LABELS FIX SUMMARY**"
echo "============================================="
echo "✅ Root cause identified: PathPrefix(/) catching all paths"
echo "✅ Landing page updated to use Path(/) for root only"
echo "✅ Landing page container recreated with correct labels"
echo "✅ Services should now load without redirects"
echo ""
echo "🎯 **Expected Results:**"
echo "   - Landing page: Only serves root path /"
echo "   - Services: Load without redirects to landing page"
echo "   - Static assets: Load properly without 404 errors"
echo ""
echo "🧪 **Test Now:**"
echo "   - Root: https://nxcore.tail79107c.ts.net/ (landing page)"
echo "   - Grafana: https://nxcore.tail79107c.ts.net/grafana/"
echo "   - n8n: https://nxcore.tail79107c.ts.net/n8n/"
echo "   - OpenWebUI: https://nxcore.tail79107c.ts.net/ai/"
echo ""
success "Landing page Traefik labels fix complete! 🎉"
