#!/usr/bin/env bash
set -e
echo "[*] Install NXCore bootstrap"
( cd "$(dirname "$0")/nxcore_bootstrap" && sudo bash bootstrap_nxcore.sh || true )
echo "[*] Start Fleet Layer"
( cd "$(dirname "$0")/fleet_layer" && docker compose up -d )
echo "[*] coturn (optional): cd server/aerocaller_coturn_pack && docker compose up -d"
