#!/bin/bash
# NXCore Clean Wipe Script
# Run this on NXCore to prepare for clean install
# WARNING: This will stop and remove ALL containers!

set -e

echo "============================================"
echo "NXCore Clean Wipe Script"
echo "============================================"
echo ""
echo "⚠️  WARNING: This will:"
echo "  - Stop ALL Docker containers"
echo "  - Remove ALL Docker containers"
echo "  - Remove custom Docker networks"
echo "  - Clean Docker system (images, cache)"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

echo ""
echo "============================================"
echo "Step 1: Stopping ALL containers..."
echo "============================================"
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || echo "No containers to stop"

echo ""
echo "============================================"
echo "Step 2: Removing ALL containers..."
echo "============================================"
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || echo "No containers to remove"

echo ""
echo "============================================"
echo "Step 3: Removing custom networks..."
echo "============================================"
sudo docker network rm gateway 2>/dev/null || echo "Gateway network not found"
sudo docker network rm backend 2>/dev/null || echo "Backend network not found"
sudo docker network rm observability 2>/dev/null || echo "Observability network not found"

echo ""
echo "============================================"
echo "Step 4: Cleaning Docker system..."
echo "============================================"
sudo docker system prune -af

echo ""
echo "============================================"
echo "Step 5: Verifying clean state..."
echo "============================================"
echo ""
echo "=== Containers (should be empty) ==="
sudo docker ps -a

echo ""
echo "=== Networks (should only show bridge, host, none) ==="
sudo docker network ls

echo ""
echo "=== Volumes ==="
sudo docker volume ls

echo ""
echo "=== Disk usage ==="
sudo docker system df

echo ""
echo "============================================"
echo "Step 6: Creating directory structure..."
echo "============================================"
sudo mkdir -p /srv/core/{data,config,logs,backups,landing}
sudo mkdir -p /opt/nexus/{traefik,authelia,aerocaller}/certs
sudo mkdir -p /opt/nexus/traefik/dynamic
sudo chown -R glyph:glyph /srv/core /opt/nexus

echo ""
echo "=== Directory structure ==="
ls -la /srv/core/
ls -la /opt/nexus/

echo ""
echo "============================================"
echo "Step 7: Verifying Tailscale certs..."
echo "============================================"
if [ -f "/opt/nexus/traefik/certs/fullchain.pem" ] && [ -f "/opt/nexus/traefik/certs/privkey.pem" ]; then
  echo "✅ Tailscale certs found:"
  ls -l /opt/nexus/traefik/certs/
else
  echo "⚠️  Tailscale certs NOT found. Minting now..."
  sudo tailscale cert \
    --cert-file=/opt/nexus/traefik/certs/fullchain.pem \
    --key-file=/opt/nexus/traefik/certs/privkey.pem \
    nxcore.tail79107c.ts.net
  echo "✅ Certs minted:"
  ls -l /opt/nexus/traefik/certs/
fi

echo ""
echo "============================================"
echo "✅ Wipe complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Exit SSH and return to Windows workstation"
echo "2. Run: .\scripts\ps\deploy-containers.ps1 -Service traefik"
echo "3. Follow DEPLOYMENT_CHECKLIST.md for remaining phases"
echo ""
echo "📖 See: docs/DEPLOYMENT_CHECKLIST.md"
echo ""

