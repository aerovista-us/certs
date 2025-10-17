#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This helper targets Ubuntu/Debian. For other distros, install 'coturn' via your package manager."
  exit 1
fi

sudo apt-get update
sudo apt-get install -y coturn

# Enable service
sudo sed -i 's/^TURNSERVER_ENABLED=.*/TURNSERVER_ENABLED=1/' /etc/default/coturn

# Write config
sudo tee /etc/turnserver.conf >/dev/null <<'CONF'
listening-port=3478
min-port=49160
max-port=49200
fingerprint
realm=nxcore.tail
lt-cred-mech
user=auser:apass
simple-log
# TLS (optional):
# tls-listening-port=5349
# cert=/etc/ssl/certs/nxcore.crt
# pkey=/etc/ssl/private/nxcore.key
CONF

sudo systemctl enable --now coturn
sudo systemctl status coturn --no-pager
echo "[✓] coturn (native) started."
