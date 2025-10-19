# PowerShell script to run comprehensive landing page audit
# Tests all service links and generates fix recommendations

param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

Write-Host "🔍 Starting NXCore Landing Page Service Audit..." -ForegroundColor Blue

# 1. Copy test files to server
Write-Host "📁 Copying test files to server..." -ForegroundColor Yellow
scp -r tests/ ${Username}@${ServerHost}:/srv/core/nxcore/
scp scripts/run-landing-audit.sh ${Username}@${ServerHost}:/srv/core/run-landing-audit.sh

# 2. Run the audit on the server
Write-Host "🧪 Running service audit on server..." -ForegroundColor Green
ssh ${Username}@${ServerHost} "chmod +x /srv/core/run-landing-audit.sh && sudo /srv/core/run-landing-audit.sh"

# 3. Copy results back to Windows
Write-Host "📄 Copying audit results..." -ForegroundColor Yellow
scp -r ${Username}@${ServerHost}:/srv/core/nxcore/test-results/ ./test-results/

# 4. Display results
Write-Host "📊 AUDIT RESULTS" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan

if (Test-Path "./test-results/fix-recommendations.md") {
    Write-Host "✅ Fix recommendations generated" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Key Recommendations:" -ForegroundColor Yellow
    Get-Content "./test-results/fix-recommendations.md" | Select-Object -First 20
} else {
    Write-Host "⚠️ Fix recommendations not found" -ForegroundColor Yellow
}

if (Test-Path "./test-results/landing-page-audit-report.html") {
    Write-Host "✅ HTML report generated" -ForegroundColor Green
    Write-Host "📄 Open report: ./test-results/landing-page-audit-report.html" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ HTML report not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 QUICK FIXES" -ForegroundColor Red
Write-Host "==============" -ForegroundColor Red
Write-Host "1. Fix Traefik routing: sudo /srv/core/fix-traefik-routing.sh"
Write-Host "2. Fix Authelia auth: sudo /srv/core/fix-authelia-routing.sh"
Write-Host "3. Fix OpenWebUI AI: sudo /srv/core/fix-openwebui-routing.sh"
Write-Host ""
Write-Host "📁 Results saved to: ./test-results/" -ForegroundColor Green
