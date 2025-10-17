# PowerShell script to deploy OpenWebUI routing fix
# Run this from Windows to fix the OpenWebUI path-based routing issue

param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

Write-Host "🤖 Deploying OpenWebUI routing fix to $ServerHost..." -ForegroundColor Blue

# 1. Copy the fixed compose file to the server
Write-Host "📁 Copying fixed OpenWebUI compose file..." -ForegroundColor Yellow
scp docker/compose-openwebui.yml ${Username}@${ServerHost}:/srv/core/compose-openwebui.yml

# 2. Copy the fix script
Write-Host "📄 Copying fix script..." -ForegroundColor Yellow
scp scripts/fix-openwebui-routing.sh ${Username}@${ServerHost}:/srv/core/fix-openwebui-routing.sh

# 3. Execute the fix script on the server
Write-Host "🚀 Executing OpenWebUI fixes on server..." -ForegroundColor Green
ssh ${Username}@${ServerHost} "chmod +x /srv/core/fix-openwebui-routing.sh && sudo /srv/core/fix-openwebui-routing.sh"

Write-Host "✅ OpenWebUI routing fix deployed!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Test the fix:" -ForegroundColor Cyan
Write-Host "  Open: https://nxcore.tail79107c.ts.net/ai"
Write-Host "  Health: curl -k https://nxcore.tail79107c.ts.net/ai/health"
Write-Host "  API: curl -k https://nxcore.tail79107c.ts.net/ai/api/v1/health"
