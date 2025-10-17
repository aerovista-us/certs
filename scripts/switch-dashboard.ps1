# AeroVista Dashboard Switcher
# Switches dashboard styles on NXCore server

Write-Host "🎛️  AeroVista Dashboard Switcher" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

try {
    $result = ssh glyph@100.115.9.61 'sudo /usr/local/bin/switch-dashboard.sh'
    Write-Host "✅ Dashboard switch completed on NXCore" -ForegroundColor Green
    Write-Host "📺 Check the monitor - new style should be active" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Error connecting to NXCore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Make sure SSH is configured and NXCore is reachable" -ForegroundColor Yellow
}
