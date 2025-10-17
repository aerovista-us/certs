#!/usr/bin/env bash
set -euo pipefail

# Fix Authelia Path-Based Routing
# Addresses the 502 Bad Gateway error when accessing /auth/

REPO_DIR="/srv/core/nxcore"
CORE_DIR="/srv/core"

echo "🔐 Fixing Authelia path-based routing..."

# 1. Check if Authelia container exists and stop it
echo "⏹️ Stopping existing Authelia containers..."
cd "$CORE_DIR"

# Stop any existing Authelia containers
docker stop authelia 2>/dev/null || true
docker rm authelia 2>/dev/null || true

# 2. Check if Authelia configuration exists
echo "📁 Checking Authelia configuration..."
if [ ! -d "/opt/nexus/authelia" ]; then
    echo "⚠️ Authelia configuration directory not found at /opt/nexus/authelia"
    echo "Creating basic configuration..."
    sudo mkdir -p /opt/nexus/authelia
    sudo chown -R 1000:1000 /opt/nexus/authelia
fi

# 3. Deploy Authelia with fixed configuration
echo "🚀 Deploying Authelia with proper routing..."
docker compose -f "$REPO_DIR/docker/compose-authelia.yml" up -d

# Wait for Authelia to be ready
echo "⏳ Waiting for Authelia to be ready..."
sleep 15

# 4. Test the fix
echo "🧪 Testing Authelia routing..."

# Test main page
echo "Testing main page..."
if curl -s -k "https://nxcore.tail79107c.ts.net/auth" | grep -q "Authelia\|Login\|Sign in"; then
    echo "✅ Authelia main page is accessible"
else
    echo "❌ Authelia main page test failed"
fi

# Test health endpoint
echo "Testing health endpoint..."
if curl -s -k "https://nxcore.tail79107c.ts.net/auth/api/health" | grep -q "ok\|healthy"; then
    echo "✅ Authelia health endpoint is working"
else
    echo "❌ Authelia health endpoint test failed"
fi

# Test direct container access
echo "Testing direct container access..."
if curl -s "http://localhost:9091/api/health" | grep -q "ok\|healthy"; then
    echo "✅ Authelia container is responding directly"
else
    echo "❌ Authelia container direct access test failed"
fi

# 5. Show container status
echo "📊 Authelia container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep authelia || echo "No Authelia container found"

# 6. Show recent logs
echo "📋 Recent Authelia logs:"
docker logs authelia --since=2m | tail -10 2>/dev/null || echo "No logs available"

# 7. Check network connectivity
echo "🌐 Checking network connectivity..."
if docker network ls | grep -q gateway; then
    echo "✅ Gateway network exists"
else
    echo "❌ Gateway network not found"
fi

if docker network ls | grep -q backend; then
    echo "✅ Backend network exists"
else
    echo "❌ Backend network not found"
fi

echo "🎉 Authelia routing fix complete!"
echo ""
echo "🌐 Access Authelia at: https://nxcore.tail79107c.ts.net/auth"
echo ""
echo "🔍 If issues persist, check:"
echo "  docker logs authelia -f"
echo "  curl -k https://nxcore.tail79107c.ts.net/auth/api/health"
echo "  docker network inspect gateway"
echo "  docker network inspect backend"
