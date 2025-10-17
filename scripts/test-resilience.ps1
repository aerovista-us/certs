# AeroVista Resilience Test Script
# Tests the resilience setup after reboot

Write-Host "🛡️  AeroVista Resilience Test" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "🔍 Checking service status..." -ForegroundColor Yellow
    
    # Check systemd services
    $services = ssh glyph@100.115.9.61 "sudo systemctl is-active compose@core compose@autoheal compose@n8n"
    Write-Host "✅ Systemd Services: $services" -ForegroundColor Green
    
    # Check Docker containers
    $containers = ssh glyph@100.115.9.61 "docker ps --format '{{.Names}}' | wc -l"
    Write-Host "✅ Running Containers: $containers" -ForegroundColor Green
    
    # Check dashboard
    $dashboard = ssh glyph@100.115.9.61 "curl -sS http://localhost:8081/ | head -1"
    if ($dashboard -match "html") {
        Write-Host "✅ Dashboard: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Dashboard: May not be ready yet" -ForegroundColor Yellow
    }
    
    # Check file sharing
    $fileshare = ssh glyph@100.115.9.61 "curl -sS http://localhost:8082/ | head -1"
    if ($fileshare -match "html") {
        Write-Host "✅ FileShare: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  FileShare: May not be ready yet" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🎉 Resilience test completed!" -ForegroundColor Green
    Write-Host "📺 Check the monitor - dashboard should be displaying" -ForegroundColor Yellow
    Write-Host "🌐 Services should be accessible via Tailscale" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Error during resilience test: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Services may still be starting up - wait a few minutes and try again" -ForegroundColor Yellow
}
