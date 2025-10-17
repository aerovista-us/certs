# PowerShell script to deploy Traefik routing fixes
# Run this from Windows to fix the Traefik issues on the server

param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

Write-Host "🔧 Deploying Traefik routing fixes to $ServerHost..." -ForegroundColor Blue

# 1. Copy the fixed compose files to the server
Write-Host "📁 Copying fixed compose files..." -ForegroundColor Yellow
scp docker/compose-traefik.yml ${Username}@${ServerHost}:/srv/core/compose-traefik.yml
scp docker/compose-n8n.yml ${Username}@${ServerHost}:/srv/core/compose-n8n.yml
scp docker/compose-openwebui.yml ${Username}@${ServerHost}:/srv/core/compose-openwebui.yml

# 2. Copy the fix script
Write-Host "📄 Copying fix script..." -ForegroundColor Yellow
scp scripts/fix-traefik-routing.sh ${Username}@${ServerHost}:/srv/core/fix-traefik-routing.sh

# 3. Execute the fix script on the server
Write-Host "🚀 Executing Traefik fixes on server..." -ForegroundColor Green
ssh ${Username}@${ServerHost} "chmod +x /srv/core/fix-traefik-routing.sh && sudo /srv/core/fix-traefik-routing.sh"

Write-Host "✅ Traefik routing fixes deployed!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Test the fixes:" -ForegroundColor Cyan
Write-Host "  curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[].rule'"
Write-Host "  curl -kI https://nxcore.tail79107c.ts.net/dash"
Write-Host "  curl -kI https://nxcore.tail79107c.ts.net/n8n"
Write-Host "  curl -kI https://nxcore.tail79107c.ts.net/ai"
