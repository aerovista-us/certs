#!/usr/bin/env bash
# clean-wipe-nxcore.sh
# Nuclear option: wipe all Docker containers, networks, and optionally volumes
# Run this on NXCore directly via SSH

set -euo pipefail

echo "========================================="
echo "NXCore Clean Wipe Script"
echo "========================================="
echo ""
echo "⚠️  WARNING: This will remove:"
echo "  - All Docker containers (running and stopped)"
echo "  - All custom Docker networks"
echo "  - Optionally: All Docker volumes (DATA LOSS!)"
echo ""
read -p "Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "1️⃣  Stopping all containers..."
if [ "$(sudo docker ps -aq)" ]; then
  sudo docker stop $(sudo docker ps -aq)
  echo "   ✅ Stopped all containers"
else
  echo "   ℹ️  No containers running"
fi

echo ""
echo "2️⃣  Removing all containers..."
if [ "$(sudo docker ps -aq)" ]; then
  sudo docker rm $(sudo docker ps -aq)
  echo "   ✅ Removed all containers"
else
  echo "   ℹ️  No containers to remove"
fi

echo ""
echo "3️⃣  Removing custom networks..."
# Remove all networks except default ones (bridge, host, none)
sudo docker network ls --filter type=custom -q | while read net; do
  sudo docker network rm "$net" 2>/dev/null || true
done
echo "   ✅ Removed custom networks"

echo ""
read -p "4️⃣  Remove ALL volumes (⚠️ DATA LOSS - n8n, portainer, etc.)? (yes/no): " vol_confirm
if [[ "$vol_confirm" == "yes" ]]; then
  if [ "$(sudo docker volume ls -q)" ]; then
    sudo docker volume rm $(sudo docker volume ls -q)
    echo "   ✅ Removed all volumes"
  else
    echo "   ℹ️  No volumes to remove"
  fi
else
  echo "   ⏭️  Skipped volume removal"
fi

echo ""
echo "5️⃣  Docker system prune..."
sudo docker system prune -af --volumes
echo "   ✅ Pruned system"

echo ""
echo "========================================="
echo "✅ Clean wipe complete!"
echo "========================================="
echo ""
echo "Current state:"
sudo docker ps -a
sudo docker network ls
sudo docker volume ls
echo ""
echo "Next steps:"
echo "  1. Exit this SSH session"
echo "  2. From Windows: .\\scripts\\ps\\deploy-containers.ps1 -Service traefik"
echo "  3. Follow: docs/CLEAN_INSTALL_GUIDE.md"

