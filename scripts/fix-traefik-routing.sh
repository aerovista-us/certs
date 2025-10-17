#!/usr/bin/env bash
set -euo pipefail

# Fix Traefik Routing Issues
# Addresses container naming and routing conflicts

REPO_DIR="/srv/core/nxcore"
CORE_DIR="/srv/core"

echo "🔧 Fixing Traefik routing issues..."

# 1. Stop all services to avoid conflicts
echo "⏹️ Stopping all services..."
cd "$CORE_DIR"
docker compose -f compose-traefik.yml down || true
docker compose -f compose-landing.yml down || true
docker compose -f compose-n8n.yml down || true
docker compose -f compose-openwebui.yml down || true

# 2. Remove any orphaned containers
echo "🧹 Cleaning up orphaned containers..."
docker container prune -f || true

# 3. Deploy Traefik with fixed configuration
echo "🚀 Deploying Traefik with fixed routing..."
docker compose -f "$REPO_DIR/docker/compose-traefik.yml" up -d

# Wait for Traefik to be ready
echo "⏳ Waiting for Traefik to be ready..."
sleep 10

# 4. Deploy other services with path-based routing
echo "🚀 Deploying services with path-based routing..."

# Deploy landing page (lowest priority)
docker compose -f "$REPO_DIR/docker/compose-landing.yml" up -d

# Deploy n8n with path-based routing
docker compose -f "$REPO_DIR/docker/compose-n8n.yml" up -d

# Deploy OpenWebUI with path-based routing
docker compose -f "$REPO_DIR/docker/compose-openwebui.yml" up -d

# 5. Test the fixes
echo "🧪 Testing Traefik fixes..."

# Test Traefik API
echo "Testing Traefik API..."
if curl -s -k "https://nxcore.tail79107c.ts.net/api/http/routers" | jq -r '.[].rule' >/dev/null 2>&1; then
    echo "✅ Traefik API is working correctly"
else
    echo "❌ Traefik API test failed"
fi

# Test Traefik Dashboard
echo "Testing Traefik Dashboard..."
if curl -s -k -I "https://nxcore.tail79107c.ts.net/dash" | grep -q "200 OK"; then
    echo "✅ Traefik Dashboard is accessible"
else
    echo "❌ Traefik Dashboard test failed"
fi

# Test n8n routing
echo "Testing n8n routing..."
if curl -s -k -I "https://nxcore.tail79107c.ts.net/n8n" | grep -q "200 OK\|302 Found"; then
    echo "✅ n8n routing is working"
else
    echo "❌ n8n routing test failed"
fi

# Test AI routing
echo "Testing AI routing..."
if curl -s -k -I "https://nxcore.tail79107c.ts.net/ai" | grep -q "200 OK\|302 Found"; then
    echo "✅ AI routing is working"
else
    echo "❌ AI routing test failed"
fi

# 6. Show container status
echo "📊 Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(traefik|landing|n8n|openwebui)"

# 7. Show Traefik logs
echo "📋 Recent Traefik logs:"
docker logs traefik --since=2m | tail -10

echo "🎉 Traefik routing fixes complete!"
echo ""
echo "📋 Access Points:"
echo "  Traefik API: https://nxcore.tail79107c.ts.net/api/http/routers"
echo "  Traefik Dashboard: https://nxcore.tail79107c.ts.net/dash"
echo "  Landing Page: https://nxcore.tail79107c.ts.net/"
echo "  n8n: https://nxcore.tail79107c.ts.net/n8n"
echo "  AI: https://nxcore.tail79107c.ts.net/ai"
echo ""
echo "🔍 Debug commands:"
echo "  docker logs traefik -f"
echo "  curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[].rule'"
echo "  docker ps --format 'table {{.Names}}\t{{.Networks}}'"
