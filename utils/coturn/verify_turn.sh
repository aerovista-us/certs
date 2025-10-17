#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-nxcore}"
USER="${2:-auser}"
PASS="${3:-apass}"
MINPORT="${4:-49160}"

if ! command -v turnutils_uclient >/dev/null 2>&1; then
  echo "[i] Installing 'coturn' tools (requires sudo apt)..."
  sudo apt-get update && sudo apt-get install -y coturn
fi

echo "[+] Running TURN allocation test against $HOST:3478 (UDP)..."
turnutils_uclient -L 0.0.0.0 -p $MINPORT -T "$HOST" -u "$USER" -w "$PASS" -z 3 -y || true

echo
echo "[i] Check coturn logs for 'Allocation success' lines."
