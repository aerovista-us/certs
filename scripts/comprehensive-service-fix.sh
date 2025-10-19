#!/usr/bin/env bash
set -euo pipefail

# Comprehensive Service Fix Plan
# Addresses all identified issues from the landing page audit

REPO_DIR="/srv/core/nxcore"
CORE_DIR="/srv/core"

echo "🔧 NXCore Comprehensive Service Fix Plan"
echo "========================================"
echo ""

# Phase 1: Infrastructure Fixes
echo "📋 Phase 1: Infrastructure Fixes"
echo "================================="

# 1.1 Fix Traefik routing
echo "🔧 1.1 Fixing Traefik routing..."
if [ -f "$REPO_DIR/scripts/fix-traefik-routing.sh" ]; then
    chmod +x "$REPO_DIR/scripts/fix-traefik-routing.sh"
    "$REPO_DIR/scripts/fix-traefik-routing.sh"
    echo "✅ Traefik routing fixed"
else
    echo "⚠️ Traefik fix script not found"
fi

# 1.2 Fix Authelia authentication
echo "🔧 1.2 Fixing Authelia authentication..."
if [ -f "$REPO_DIR/scripts/fix-authelia-routing.sh" ]; then
    chmod +x "$REPO_DIR/scripts/fix-authelia-routing.sh"
    "$REPO_DIR/scripts/fix-authelia-routing.sh"
    echo "✅ Authelia routing fixed"
else
    echo "⚠️ Authelia fix script not found"
fi

# 1.3 Fix OpenWebUI AI service
echo "🔧 1.3 Fixing OpenWebUI AI service..."
if [ -f "$REPO_DIR/scripts/fix-openwebui-routing.sh" ]; then
    chmod +x "$REPO_DIR/scripts/fix-openwebui-routing.sh"
    "$REPO_DIR/scripts/fix-openwebui-routing.sh"
    echo "✅ OpenWebUI routing fixed"
else
    echo "⚠️ OpenWebUI fix script not found"
fi

echo ""

# Phase 2: Service Health Checks
echo "📋 Phase 2: Service Health Checks"
echo "================================="

# 2.1 Check container status
echo "🔍 2.1 Checking container status..."
echo "Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(traefik|authelia|openwebui|grafana|prometheus|portainer|n8n|filebrowser|uptime-kuma|ollama)"

# 2.2 Check network connectivity
echo ""
echo "🔍 2.2 Checking network connectivity..."
if docker network ls | grep -q gateway; then
    echo "✅ Gateway network exists"
else
    echo "❌ Gateway network missing - creating..."
    docker network create gateway
fi

if docker network ls | grep -q backend; then
    echo "✅ Backend network exists"
else
    echo "❌ Backend network missing - creating..."
    docker network create backend
fi

# 2.3 Check service endpoints
echo ""
echo "🔍 2.3 Checking service endpoints..."

services=(
    "Traefik API:https://nxcore.tail79107c.ts.net/api/http/routers"
    "Traefik Dashboard:https://nxcore.tail79107c.ts.net/dash"
    "Grafana:https://nxcore.tail79107c.ts.net/grafana/"
    "Prometheus:https://nxcore.tail79107c.ts.net/prometheus/"
    "Portainer:https://nxcore.tail79107c.ts.net/portainer/"
    "AI Service:https://nxcore.tail79107c.ts.net/ai/"
    "FileBrowser:https://nxcore.tail79107c.ts.net/files/"
    "Uptime Kuma:https://nxcore.tail79107c.ts.net/status/"
    "Authelia:https://nxcore.tail79107c.ts.net/auth/"
    "n8n:https://nxcore.tail79107c.ts.net/n8n/"
)

for service_info in "${services[@]}"; do
    name=$(echo "$service_info" | cut -d: -f1)
    url=$(echo "$service_info" | cut -d: -f2-)
    
    if curl -s -k -I "$url" | head -1 | grep -q "200\|302\|301"; then
        echo "✅ $name: Accessible"
    else
        echo "❌ $name: Not accessible"
    fi
done

echo ""

# Phase 3: Service-Specific Fixes
echo "📋 Phase 3: Service-Specific Fixes"
echo "=================================="

# 3.1 Fix Grafana if needed
echo "🔧 3.1 Checking Grafana..."
if ! curl -s -k "https://nxcore.tail79107c.ts.net/grafana/" | grep -q "Grafana"; then
    echo "⚠️ Grafana needs attention - redeploying..."
    cd "$CORE_DIR"
    docker compose -f "$REPO_DIR/docker/compose-grafana.yml" up -d || echo "Grafana compose file not found"
fi

# 3.2 Fix Prometheus if needed
echo "🔧 3.2 Checking Prometheus..."
if ! curl -s -k "https://nxcore.tail79107c.ts.net/prometheus/" | grep -q "Prometheus"; then
    echo "⚠️ Prometheus needs attention - redeploying..."
    cd "$CORE_DIR"
    docker compose -f "$REPO_DIR/docker/compose-prometheus.yml" up -d || echo "Prometheus compose file not found"
fi

# 3.3 Fix Portainer if needed
echo "🔧 3.3 Checking Portainer..."
if ! curl -s -k "https://nxcore.tail79107c.ts.net/portainer/" | grep -q "Portainer"; then
    echo "⚠️ Portainer needs attention - redeploying..."
    cd "$CORE_DIR"
    docker compose -f "$REPO_DIR/docker/compose-portainer.yml" up -d || echo "Portainer compose file not found"
fi

echo ""

# Phase 4: Monitoring Setup
echo "📋 Phase 4: Monitoring Setup"
echo "============================"

# 4.1 Enable AI monitoring
echo "🔧 4.1 Enabling AI monitoring..."
if [ -f "/etc/systemd/system/ai-monitor.timer" ]; then
    sudo systemctl enable ai-monitor.timer
    sudo systemctl start ai-monitor.timer
    echo "✅ AI monitoring enabled"
else
    echo "⚠️ AI monitoring not configured"
fi

# 4.2 Enable exchange monitoring
echo "🔧 4.2 Enabling exchange monitoring..."
if [ -f "/etc/systemd/system/exchange-outbox.timer" ]; then
    sudo systemctl enable exchange-outbox.timer
    sudo systemctl start exchange-outbox.timer
    echo "✅ Exchange monitoring enabled"
else
    echo "⚠️ Exchange monitoring not configured"
fi

echo ""

# Phase 5: Final Verification
echo "📋 Phase 5: Final Verification"
echo "=============================="

echo "🔍 Running final service checks..."

# Test all services again
working_services=0
total_services=0

for service_info in "${services[@]}"; do
    name=$(echo "$service_info" | cut -d: -f1)
    url=$(echo "$service_info" | cut -d: -f2-)
    total_services=$((total_services + 1))
    
    if curl -s -k -I "$url" | head -1 | grep -q "200\|302\|301"; then
        working_services=$((working_services + 1))
    fi
done

echo ""
echo "📊 FINAL RESULTS"
echo "================"
echo "Working Services: $working_services/$total_services"

if [ $working_services -eq $total_services ]; then
    echo "🎉 All services are working correctly!"
else
    echo "⚠️ Some services still need attention"
    echo ""
    echo "🔧 Additional troubleshooting:"
    echo "1. Check container logs: docker logs <container-name>"
    echo "2. Check Traefik logs: docker logs traefik"
    echo "3. Verify network: docker network inspect gateway"
    echo "4. Check SSL certificates: ls -la /opt/nexus/traefik/certs/"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Monitor service logs: journalctl -f"
echo "2. Check service health: curl -k https://nxcore.tail79107c.ts.net/api/http/routers"
echo "3. Test all services manually"
echo "4. Set up automated monitoring"

echo ""
echo "🎯 Service URLs:"
echo "Landing: https://nxcore.tail79107c.ts.net/"
echo "Traefik: https://nxcore.tail79107c.ts.net/dash"
echo "Grafana: https://nxcore.tail79107c.ts.net/grafana/"
echo "AI: https://nxcore.tail79107c.ts.net/ai/"
echo "Auth: https://nxcore.tail79107c.ts.net/auth/"
