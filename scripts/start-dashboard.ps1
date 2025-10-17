# AeroVista Dashboard Starter
# Starts the dashboard on NXCore server

Write-Host "🖥️  Starting AeroVista Dashboard on NXCore..." -ForegroundColor Cyan

try {
    $result = ssh glyph@100.115.9.61 'bash -lc "/usr/local/bin/start-dashboard.sh || true"'
    Write-Host "✅ Dashboard start command sent to NXCore" -ForegroundColor Green
    Write-Host "📺 Check the monitor - dashboard should be starting..." -ForegroundColor Yellow
} catch {
    Write-Host "❌ Error connecting to NXCore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Make sure SSH is configured and NXCore is reachable" -ForegroundColor Yellow
}
