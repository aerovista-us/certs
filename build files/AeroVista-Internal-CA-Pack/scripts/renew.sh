#!/usr/bin/env bash
set -euo pipefail
# Simple renewal: re-run makecerts.sh with same hosts file.
# This keeps the same SANs but refreshes validity.
HERE="$(cd "$(dirname "$0")" && pwd)"
"$HERE/makecerts.sh" "$HERE/../out" "$HERE/../out/hosts.txt"
echo "[✓] Renewal attempted. Replace files on Traefik and reload."
