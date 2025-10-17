# PowerShell script to deploy Authelia routing fix
# Run this from Windows to fix the Authelia 502 Bad Gateway issue

param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

Write-Host "🔐 Deploying Authelia routing fix to $ServerHost..." -ForegroundColor Blue

# 1. Copy the fixed compose file to the server
Write-Host "📁 Copying fixed Authelia compose file..." -ForegroundColor Yellow
scp docker/compose-authelia.yml ${Username}@${ServerHost}:/srv/core/compose-authelia.yml

# 2. Copy the fix script
Write-Host "📄 Copying fix script..." -ForegroundColor Yellow
scp scripts/fix-authelia-routing.sh ${Username}@${ServerHost}:/srv/core/fix-authelia-routing.sh

# 3. Execute the fix script on the server
Write-Host "🚀 Executing Authelia fixes on server..." -ForegroundColor Green
ssh ${Username}@${ServerHost} "chmod +x /srv/core/fix-authelia-routing.sh && sudo /srv/core/fix-authelia-routing.sh"

Write-Host "✅ Authelia routing fix deployed!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Test the fix:" -ForegroundColor Cyan
Write-Host "  Open: https://nxcore.tail79107c.ts.net/auth"
Write-Host "  Health: curl -k https://nxcore.tail79107c.ts.net/auth/api/health"
Write-Host "  Direct: curl http://localhost:9091/api/health"
