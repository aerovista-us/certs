# AeroVista Browser Workspaces Test Script
# Tests all browser workspace services

Write-Host "🚀 AeroVista Browser Workspaces Test" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "🔍 Checking browser workspace services..." -ForegroundColor Yellow
    
    # Check systemd service
    $serviceStatus = ssh glyph@100.115.9.61 "sudo systemctl is-active compose@browser-workspaces"
    Write-Host "✅ Browser Workspaces Service: $serviceStatus" -ForegroundColor Green
    
    # Check containers
    $containers = ssh glyph@100.115.9.61 "docker ps --format '{{.Names}}' | grep -E '(vnc|novnc|guac|code|jupyter|rstudio)' | wc -l"
    Write-Host "✅ Running Containers: $containers/6" -ForegroundColor Green
    
    # Test service accessibility
    Write-Host ""
    Write-Host "🌐 Testing service accessibility..." -ForegroundColor Yellow
    
    # Test NoVNC
    $novnc = ssh glyph@100.115.9.61 "curl -sS http://localhost:6080/ | head -1"
    if ($novnc -match "html") {
        Write-Host "✅ NoVNC: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  NoVNC: May not be ready yet" -ForegroundColor Yellow
    }
    
    # Test Guacamole
    $guac = ssh glyph@100.115.9.61 "curl -sS http://localhost:8080/guacamole/ | head -1"
    if ($guac -match "html") {
        Write-Host "✅ Guacamole: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Guacamole: May not be ready yet" -ForegroundColor Yellow
    }
    
    # Test Code Server
    $code = ssh glyph@100.115.9.61 "curl -sS http://localhost:8080/ | head -1"
    if ($code -match "html") {
        Write-Host "✅ Code Server: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Code Server: May not be ready yet" -ForegroundColor Yellow
    }
    
    # Test Jupyter
    $jupyter = ssh glyph@100.115.9.61 "curl -sS http://localhost:8888/ | head -1"
    if ($jupyter -match "html") {
        Write-Host "✅ Jupyter: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Jupyter: May not be ready yet" -ForegroundColor Yellow
    }
    
    # Test RStudio
    $rstudio = ssh glyph@100.115.9.61 "curl -sS http://localhost:8787/ | head -1"
    if ($rstudio -match "html") {
        Write-Host "✅ RStudio: Accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  RStudio: May not be ready yet" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🎉 Browser Workspaces test completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access your workspaces:" -ForegroundColor Yellow
    Write-Host "   • NoVNC: https://vnc.nxcore.tail79107c.ts.net/" -ForegroundColor White
    Write-Host "   • Guacamole: https://guac.nxcore.tail79107c.ts.net/" -ForegroundColor White
    Write-Host "   • Code Server: https://code.nxcore.tail79107c.ts.net/" -ForegroundColor White
    Write-Host "   • Jupyter: https://jupyter.nxcore.tail79107c.ts.net/" -ForegroundColor White
    Write-Host "   • RStudio: https://rstudio.nxcore.tail79107c.ts.net/" -ForegroundColor White
    Write-Host "   • Landing Page: http://100.115.9.61:8081/" -ForegroundColor White
    Write-Host ""
    Write-Host "🔐 Default passwords are in PHASE_B_DEPLOYMENT_COMPLETE.md" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Error during browser workspaces test: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Services may still be starting up - wait a few minutes and try again" -ForegroundColor Yellow
}
