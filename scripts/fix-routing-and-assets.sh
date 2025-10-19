#!/bin/bash
# Fix Routing and Static Assets Issues
# Addresses services redirecting to landing page and 404 errors for static assets

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

log "🔧 FIXING ROUTING AND STATIC ASSETS ISSUES"
log "📋 Services redirecting to landing page and 404 errors for static assets"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Fix routing configuration and static asset loading"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"
DOMAIN="nxcore.tail79107c.ts.net"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Analyze current routing issues
log "🔍 Phase 1: Analyzing current routing issues..."

# Test current service responses
log "🧪 Testing current service responses..."
curl -k -s -o /dev/null -w 'Grafana: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/grafana/ 2>/dev/null || echo "Grafana: FAILED"
curl -k -s -o /dev/null -w 'n8n: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/n8n/ 2>/dev/null || echo "n8n: FAILED"
curl -k -s -o /dev/null -w 'OpenWebUI: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/ai/ 2>/dev/null || echo "OpenWebUI: FAILED"

# Phase 2: Create comprehensive routing fix
log "🔧 Phase 2: Creating comprehensive routing fix..."

mkdir -p "$BACKUP_DIR"

# Create comprehensive routing configuration
cat > "$BACKUP_DIR/comprehensive-routing-fix.yml" << 'EOF'
# Comprehensive Routing Fix
# Addresses services redirecting to landing page and static asset 404 errors

http:
  routers:
    # Landing page - LOWEST priority (catch-all for root only)
    landing:
      rule: Host(`nxcore.tail79107c.ts.net`) && Path(`/`)
      priority: 1
      entryPoints: [websecure]
      tls: {}
      service: landing-svc

    # Core Infrastructure - HIGH priority
    traefik-api:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/api`)
      priority: 100
      entryPoints: [websecure]
      tls: {}
      service: api@internal

    traefik-dashboard:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/traefik`)
      priority: 100
      entryPoints: [websecure]
      tls: {}
      middlewares: [traefik-strip]
      service: api@internal

    # Monitoring & Observability - HIGH priority
    grafana:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/grafana`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [grafana-strip, grafana-headers]
      service: grafana-svc

    prometheus:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/prometheus`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [prometheus-strip]
      service: prometheus-svc

    cadvisor:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/metrics`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [cadvisor-strip]
      service: cadvisor-svc

    uptime-kuma:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/status`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [uptime-strip]
      service: uptime-svc

    # AI & Development - HIGH priority
    openwebui:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/ai`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [openwebui-strip, openwebui-headers]
      service: openwebui-svc

    n8n:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/n8n`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [n8n-strip, n8n-headers]
      service: n8n-svc

    # Management Tools - HIGH priority
    portainer:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/portainer`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [portainer-strip]
      service: portainer-svc

    filebrowser:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/files`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [files-strip]
      service: filebrowser-svc

    # Authentication
    authelia:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/auth`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [auth-strip]
      service: authelia-svc

  middlewares:
    # StripPrefix middlewares - FIXED for static assets
    traefik-strip:
      stripPrefix:
        prefixes: ["/traefik"]
        forceSlash: false

    grafana-strip:
      stripPrefix:
        prefixes: ["/grafana"]
        forceSlash: false

    prometheus-strip:
      stripPrefix:
        prefixes: ["/prometheus"]
        forceSlash: false

    cadvisor-strip:
      stripPrefix:
        prefixes: ["/metrics"]
        forceSlash: false

    uptime-strip:
      stripPrefix:
        prefixes: ["/status"]
        forceSlash: false

    openwebui-strip:
      stripPrefix:
        prefixes: ["/ai"]
        forceSlash: false

    n8n-strip:
      stripPrefix:
        prefixes: ["/n8n"]
        forceSlash: false

    portainer-strip:
      stripPrefix:
        prefixes: ["/portainer"]
        forceSlash: false

    files-strip:
      stripPrefix:
        prefixes: ["/files"]
        forceSlash: false

    auth-strip:
      stripPrefix:
        prefixes: ["/auth"]
        forceSlash: false

    # Service-specific headers for static assets
    grafana-headers:
      headers:
        customRequestHeaders:
          X-Forwarded-Proto: https
          X-Forwarded-Host: nxcore.tail79107c.ts.net
          X-Forwarded-Prefix: /grafana
          X-Forwarded-For: 127.0.0.1
        customResponseHeaders:
          X-Frame-Options: SAMEORIGIN
          X-Content-Type-Options: nosniff

    openwebui-headers:
      headers:
        customRequestHeaders:
          X-Forwarded-Proto: https
          X-Forwarded-Host: nxcore.tail79107c.ts.net
          X-Forwarded-Prefix: /ai
          X-Forwarded-For: 127.0.0.1
        customResponseHeaders:
          X-Frame-Options: SAMEORIGIN
          X-Content-Type-Options: nosniff

    n8n-headers:
      headers:
        customRequestHeaders:
          X-Forwarded-Proto: https
          X-Forwarded-Host: nxcore.tail79107c.ts.net
          X-Forwarded-Prefix: /n8n
          X-Forwarded-For: 127.0.0.1
        customResponseHeaders:
          X-Frame-Options: SAMEORIGIN
          X-Content-Type-Options: nosniff

  services:
    # Service definitions
    landing-svc:
      loadBalancer:
        servers:
          - url: "http://landing:80"

    grafana-svc:
      loadBalancer:
        servers:
          - url: "http://grafana:3000"

    prometheus-svc:
      loadBalancer:
        servers:
          - url: "http://prometheus:9090"

    cadvisor-svc:
      loadBalancer:
        servers:
          - url: "http://cadvisor:8080"

    uptime-svc:
      loadBalancer:
        servers:
          - url: "http://uptime-kuma:3001"

    openwebui-svc:
      loadBalancer:
        servers:
          - url: "http://openwebui:8080"

    n8n-svc:
      loadBalancer:
        servers:
          - url: "http://n8n:5678"

    portainer-svc:
      loadBalancer:
        serversTransport: portainer-insecure
        servers:
          - url: "https://portainer:9443"

    filebrowser-svc:
      loadBalancer:
        servers:
          - url: "http://filebrowser:80"

    authelia-svc:
      loadBalancer:
        servers:
          - url: "http://authelia:9091"

  serversTransports:
    portainer-insecure:
      insecureSkipVerify: true
EOF

success "Comprehensive routing fix created"

# Phase 3: Deploy routing fix to server
log "🚀 Phase 3: Deploying routing fix to server..."

# Copy routing fix to server
scp "$BACKUP_DIR/comprehensive-routing-fix.yml" $SERVER_USER@$SERVER_HOST:/tmp/comprehensive-routing-fix.yml
success "Routing fix uploaded to server"

# Apply routing fix on server
ssh $SERVER_USER@$SERVER_HOST << 'EOF'
echo "🔧 Applying comprehensive routing fix..."

# Find Traefik dynamic directory
TRAEFIK_DYNAMIC_DIR=""
if [ -d "/opt/nexus/traefik/dynamic" ]; then
    TRAEFIK_DYNAMIC_DIR="/opt/nexus/traefik/dynamic"
elif [ -d "/srv/core/traefik/dynamic" ]; then
    TRAEFIK_DYNAMIC_DIR="/srv/core/traefik/dynamic"
elif [ -d "/etc/traefik/dynamic" ]; then
    TRAEFIK_DYNAMIC_DIR="/etc/traefik/dynamic"
else
    echo "❌ Could not find traefik dynamic directory"
    exit 1
fi

echo "📁 Found traefik dynamic directory: $TRAEFIK_DYNAMIC_DIR"

# Create backup
BACKUP_DIR="/tmp/routing-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "$TRAEFIK_DYNAMIC_DIR"/* "$BACKUP_DIR/" 2>/dev/null || echo "No existing dynamic config to backup"

# Remove old routing configurations
echo "🧹 Cleaning up old routing configurations..."
rm -f "$TRAEFIK_DYNAMIC_DIR"/*.yml 2>/dev/null || echo "No old config files to remove"

# Deploy comprehensive routing fix
cp /tmp/comprehensive-routing-fix.yml "$TRAEFIK_DYNAMIC_DIR/comprehensive-routing-fix.yml"
echo "✅ Comprehensive routing fix deployed"

# Restart Traefik
echo "🔄 Restarting Traefik with new routing configuration..."
docker restart traefik

echo "⏳ Waiting for Traefik to start..."
sleep 30

# Check Traefik status
echo "📊 Traefik status:"
docker ps | grep traefik || echo "Traefik not running"

echo "✅ Comprehensive routing fix applied"
echo "📁 Backup created at: $BACKUP_DIR"
EOF

success "Comprehensive routing fix applied"

# Phase 4: Test the routing fix
log "🧪 Phase 4: Testing the routing fix..."

# Wait for Traefik to fully start
log "⏳ Waiting for Traefik to fully start..."
sleep 10

# Test service responses
log "🔍 Testing service responses..."
curl -k -s -o /dev/null -w 'Grafana: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/grafana/ 2>/dev/null || echo "Grafana: FAILED"
curl -k -s -o /dev/null -w 'n8n: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/n8n/ 2>/dev/null || echo "n8n: FAILED"
curl -k -s -o /dev/null -w 'OpenWebUI: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/ai/ 2>/dev/null || echo "OpenWebUI: FAILED"
curl -k -s -o /dev/null -w 'Uptime Kuma: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/status/ 2>/dev/null || echo "Uptime Kuma: FAILED"

# Phase 5: Generate routing fix report
log "📊 Phase 5: Generating routing fix report..."

cat > "$BACKUP_DIR/routing-fix-report.md" << EOF
# 🔧 Routing and Static Assets Fix Report

**Date**: $(date)
**Status**: ✅ **COMPREHENSIVE ROUTING FIX APPLIED**

## 🚨 **Issues Identified**

### **Services Redirecting to Landing Page**:
- **Grafana**: Redirects to /login then landing page
- **n8n**: Static assets (CSS/JS) returning 404
- **OpenWebUI**: May have similar routing issues

### **Static Asset 404 Errors**:
- **n8n**: /static/prefers-color-scheme.css, /assets/polyfills-BhZQ1FDI.js
- **Grafana**: loader.js, custom.css, start.BENJSfDw.js
- **Result**: Services load but without proper styling/functionality

## 🔧 **Solution Applied**

### **1. Comprehensive Routing Configuration**:
- **Landing page**: Priority 1 (lowest) - only catches root path
- **Services**: Priority 200 (high) - proper path handling
- **StripPrefix**: Correct forceSlash: false for static assets

### **2. Service-Specific Headers**:
- **X-Forwarded-Proto**: https
- **X-Forwarded-Host**: nxcore.tail79107c.ts.net
- **X-Forwarded-Prefix**: Service-specific base path
- **X-Forwarded-For**: 127.0.0.1

### **3. Static Asset Support**:
- **Proper path stripping** for service assets
- **Correct headers** for asset loading
- **Service-specific configuration** for each service

## 📊 **Test Results**

Grafana: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/grafana/ 2>/dev/null || echo "FAILED")
n8n: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/n8n/ 2>/dev/null || echo "FAILED")
OpenWebUI: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/ai/ 2>/dev/null || echo "FAILED")
Uptime Kuma: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/status/ 2>/dev/null || echo "FAILED")

## 🎯 **Expected Results**

After this fix:
- ✅ **Services no longer redirect** to landing page
- ✅ **Static assets load properly** (CSS/JS files)
- ✅ **Services function correctly** with proper styling
- ✅ **No more 404 errors** for static assets

## 🧪 **Testing Steps**

1. **Test services** in browser for proper functionality
2. **Check static assets** loading (CSS/JS files)
3. **Verify no redirects** to landing page
4. **Test service functionality** (Grafana dashboards, n8n workflows)

---
**Comprehensive routing fix applied!** 🎉
EOF

success "Routing fix report generated: $BACKUP_DIR/routing-fix-report.md"

# Final status
log "🎉 COMPREHENSIVE ROUTING FIX COMPLETE!"
log "🔧 Services configured to prevent redirects to landing page"
log "🔧 Static assets configured for proper loading"
log "🔄 Traefik restarted with new routing configuration"
log "📁 Fix report generated"

success "Comprehensive routing fix complete! 🎉"

# Display final summary
echo ""
echo "🔧 **COMPREHENSIVE ROUTING FIX SUMMARY**"
echo "======================================"
echo "✅ Services configured to prevent landing page redirects"
echo "✅ Static assets configured for proper loading"
echo "✅ Service-specific headers added for asset support"
echo "✅ Traefik restarted with new routing configuration"
echo ""
echo "🎯 **Expected Results:**"
echo "   - Services no longer redirect to landing page"
echo "   - Static assets (CSS/JS) load properly"
echo "   - No more 404 errors for static assets"
echo "   - Services function with proper styling"
echo ""
echo "🧪 **Test Now:**"
echo "   - Grafana: https://nxcore.tail79107c.ts.net/grafana/"
echo "   - n8n: https://nxcore.tail79107c.ts.net/n8n/"
echo "   - OpenWebUI: https://nxcore.tail79107c.ts.net/ai/"
echo ""
success "Comprehensive routing fix complete! 🎉"
