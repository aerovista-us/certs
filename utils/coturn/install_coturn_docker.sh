#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "[+] Installing Docker..."
  curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker compose >/dev/null 2>&1; then
  echo "[+] Installing docker compose plugin..."
  DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/lib/docker}
  # On many modern distros Docker Compose plugin is bundled; otherwise fallback:
  if ! command -v curl >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y curl; fi
  sudo mkdir -p /usr/libexec/docker/cli-plugins || true
  sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)     -o /usr/libexec/docker/cli-plugins/docker-compose
  sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose || true
fi

echo "[+] Creating coturn directory /opt/coturn"
sudo mkdir -p /opt/coturn
sudo cp .env docker-compose.yml /opt/coturn/
cd /opt/coturn

echo "[+] Bringing up coturn (host network)..."
sudo --preserve-env=REALM,TURN_USER,TURN_PASS,UDP_MIN_PORT,UDP_MAX_PORT,USE_TLS,TLS_CERT_PATH,TLS_KEY_PATH,STATIC_AUTH_SECRET   docker compose up -d

echo "[✓] coturn is up. Logs:"
sudo docker logs -n 50 coturn || true

echo
echo "Next steps:"
echo "  - Ensure ports 3478/udp,3478/tcp and ${UDP_MIN_PORT}-${UDP_MAX_PORT}/udp are allowed locally (tailnet only is fine)."
echo "  - If you enabled TLS, also allow 5349/tcp."
echo "  - Configure your WebRTC clients with:"
echo "      stun:${TURN_HOST:-nxcore}:3478"
echo "      turn:${TURN_HOST:-nxcore}:3478?transport=udp (username/password in .env)"
