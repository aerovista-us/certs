# Check Service Status Script
# Tests all services to verify they're accessible

Write-Host "🔍 Checking NXCore Service Status..." -ForegroundColor Cyan
Write-Host "Domain: https://nxcore.tail79107c.ts.net" -ForegroundColor Yellow
Write-Host ""

$services = @(
    @{ Name = "Landing Dashboard"; Url = "https://nxcore.tail79107c.ts.net/" },
    @{ Name = "Grafana"; Url = "https://nxcore.tail79107c.ts.net/grafana/" },
    @{ Name = "Prometheus"; Url = "https://nxcore.tail79107c.ts.net/prometheus/" },
    @{ Name = "Portainer"; Url = "https://nxcore.tail79107c.ts.net/portainer/" },
    @{ Name = "AI Service"; Url = "https://nxcore.tail79107c.ts.net/ai/" },
    @{ Name = "FileBrowser"; Url = "https://nxcore.tail79107c.ts.net/files/" },
    @{ Name = "Uptime Kuma"; Url = "https://nxcore.tail79107c.ts.net/status/" },
    @{ Name = "Traefik Dashboard"; Url = "https://nxcore.tail79107c.ts.net/traefik/" },
    @{ Name = "AeroCaller"; Url = "https://nxcore.tail79107c.ts.net/aerocaller/" }
)

$onlineCount = 0
$totalCount = $services.Count

foreach ($service in $services) {
    try {
        Write-Host "Testing $($service.Name)..." -NoNewline
        $response = Invoke-WebRequest -Uri $service.Url -Method Head -SkipCertificateCheck -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302 -or $response.StatusCode -eq 404) {
            Write-Host " ✅ ONLINE" -ForegroundColor Green
            $onlineCount++
        } else {
            Write-Host " ⚠️  RESPONDING ($($response.StatusCode))" -ForegroundColor Yellow
            $onlineCount++
        }
    } catch {
        Write-Host " ❌ OFFLINE" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 Summary: $onlineCount/$totalCount services responding" -ForegroundColor Cyan

if ($onlineCount -eq $totalCount) {
    Write-Host "🎉 All services are accessible!" -ForegroundColor Green
} elseif ($onlineCount -gt ($totalCount / 2)) {
    Write-Host "⚠️  Most services are accessible, some may have issues" -ForegroundColor Yellow
} else {
    Write-Host "❌ Many services are not accessible" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 Note: Self-signed certificate warnings are normal" -ForegroundColor Gray
Write-Host "   Import the certificate to your browser for full functionality" -ForegroundColor Gray
