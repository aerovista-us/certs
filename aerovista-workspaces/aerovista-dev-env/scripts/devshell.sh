#!/usr/bin/env bash
set -euo pipefail
COMPOSE_FILE="docker-compose.dev.yml"
if ! command -v docker >/dev/null; then
  echo "Docker is required." >&2; exit 1
fi
docker compose -f "$COMPOSE_FILE" run --rm dev
