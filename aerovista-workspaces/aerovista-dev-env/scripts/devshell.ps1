# PowerShell dev shell launcher
param(
  [string]$ComposeFile = "docker-compose.dev.yml"
)
docker compose -f $ComposeFile run --rm dev
