# AeroVista Dashboard Switcher (Complete Refresh)
# Switches dashboard styles and restarts browser completely on NXCore

Write-Host "🎛️  AeroVista Dashboard Switcher (Complete Refresh)" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

try {
    $result = ssh glyph@100.115.9.61 'sudo /usr/local/bin/switch-dashboard-complete.sh'
    Write-Host "✅ Dashboard switch with complete refresh completed on NXCore" -ForegroundColor Green
    Write-Host "📺 Check the monitor - new style should be active immediately" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Error connecting to NXCore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Make sure SSH is configured and NXCore is reachable" -ForegroundColor Yellow
}
