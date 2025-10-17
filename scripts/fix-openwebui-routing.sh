#!/usr/bin/env bash
set -euo pipefail

# Fix OpenWebUI Path-Based Routing
# Addresses the "frontend only" error when accessing /ai

REPO_DIR="/srv/core/nxcore"
CORE_DIR="/srv/core"

echo "🤖 Fixing OpenWebUI path-based routing..."

# 1. Stop OpenWebUI
echo "⏹️ Stopping OpenWebUI..."
cd "$CORE_DIR"
docker compose -f compose-openwebui.yml down || true

# 2. Deploy with fixed configuration
echo "🚀 Deploying OpenWebUI with proper base path configuration..."
docker compose -f "$REPO_DIR/docker/compose-openwebui.yml" up -d

# Wait for OpenWebUI to be ready
echo "⏳ Waiting for OpenWebUI to be ready..."
sleep 15

# 3. Test the fix
echo "🧪 Testing OpenWebUI routing..."

# Test main page
echo "Testing main page..."
if curl -s -k "https://nxcore.tail79107c.ts.net/ai" | grep -q "Open WebUI\|AeroVista AI"; then
    echo "✅ OpenWebUI main page is accessible"
else
    echo "❌ OpenWebUI main page test failed"
fi

# Test health endpoint
echo "Testing health endpoint..."
if curl -s -k "https://nxcore.tail79107c.ts.net/ai/health" | grep -q "ok\|healthy"; then
    echo "✅ OpenWebUI health endpoint is working"
else
    echo "❌ OpenWebUI health endpoint test failed"
fi

# Test API endpoint
echo "Testing API endpoint..."
if curl -s -k "https://nxcore.tail79107c.ts.net/ai/api/v1/health" | grep -q "ok\|healthy"; then
    echo "✅ OpenWebUI API endpoint is working"
else
    echo "❌ OpenWebUI API endpoint test failed"
fi

# 4. Show container status
echo "📊 OpenWebUI container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep openwebui

# 5. Show recent logs
echo "📋 Recent OpenWebUI logs:"
docker logs openwebui --since=2m | tail -10

echo "🎉 OpenWebUI routing fix complete!"
echo ""
echo "🌐 Access OpenWebUI at: https://nxcore.tail79107c.ts.net/ai"
echo ""
echo "🔍 If issues persist, check:"
echo "  docker logs openwebui -f"
echo "  curl -k https://nxcore.tail79107c.ts.net/ai/health"
