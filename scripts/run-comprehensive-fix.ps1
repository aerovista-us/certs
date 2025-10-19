# PowerShell script to run comprehensive service fixes
# Addresses all identified issues from the landing page audit

param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

Write-Host "🔧 NXCore Comprehensive Service Fix Plan" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 1. Copy all fix scripts to server
Write-Host "📁 Copying fix scripts to server..." -ForegroundColor Yellow
scp scripts/fix-traefik-routing.sh ${Username}@${ServerHost}:/srv/core/
scp scripts/fix-authelia-routing.sh ${Username}@${ServerHost}:/srv/core/
scp scripts/fix-openwebui-routing.sh ${Username}@${ServerHost}:/srv/core/
scp scripts/comprehensive-service-fix.sh ${Username}@${ServerHost}:/srv/core/

# 2. Copy updated compose files
Write-Host "📄 Copying updated compose files..." -ForegroundColor Yellow
scp docker/compose-traefik.yml ${Username}@${ServerHost}:/srv/core/
scp docker/compose-authelia.yml ${Username}@${ServerHost}:/srv/core/
scp docker/compose-openwebui.yml ${Username}@${ServerHost}:/srv/core/
scp docker/compose-n8n.yml ${Username}@${ServerHost}:/srv/core/

# 3. Run comprehensive fix on server
Write-Host "🚀 Running comprehensive service fixes..." -ForegroundColor Green
ssh ${Username}@${ServerHost} "chmod +x /srv/core/comprehensive-service-fix.sh && sudo /srv/core/comprehensive-service-fix.sh"

# 4. Get final status
Write-Host "📊 Getting final service status..." -ForegroundColor Cyan
ssh ${Username}@${ServerHost} "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E '(traefik|authelia|openwebui|grafana|prometheus|portainer|n8n|filebrowser|uptime-kuma|ollama)'"

Write-Host ""
Write-Host "🧪 Testing key services..." -ForegroundColor Cyan

# Test key services
$services = @(
    @{Name="Traefik API"; URL="https://nxcore.tail79107c.ts.net/api/http/routers"},
    @{Name="Traefik Dashboard"; URL="https://nxcore.tail79107c.ts.net/dash"},
    @{Name="Grafana"; URL="https://nxcore.tail79107c.ts.net/grafana/"},
    @{Name="AI Service"; URL="https://nxcore.tail79107c.ts.net/ai/"},
    @{Name="Authelia"; URL="https://nxcore.tail79107c.ts.net/auth/"},
    @{Name="n8n"; URL="https://nxcore.tail79107c.ts.net/n8n/"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.URL -SkipCertificateCheck -TimeoutSec 10
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
            Write-Host "✅ $($service.Name): Working" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $($service.Name): Status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($service.Name): Not accessible" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📋 SUMMARY" -ForegroundColor Blue
Write-Host "=========" -ForegroundColor Blue
Write-Host "✅ Comprehensive fixes applied"
Write-Host "🔍 Check individual services for any remaining issues"
Write-Host ""
Write-Host "🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "  Landing: https://nxcore.tail79107c.ts.net/"
Write-Host "  Traefik: https://nxcore.tail79107c.ts.net/dash"
Write-Host "  Grafana: https://nxcore.tail79107c.ts.net/grafana/"
Write-Host "  AI: https://nxcore.tail79107c.ts.net/ai/"
Write-Host "  Auth: https://nxcore.tail79107c.ts.net/auth/"
Write-Host "  n8n: https://nxcore.tail79107c.ts.net/n8n/"
Write-Host ""
Write-Host "🔧 If issues persist:" -ForegroundColor Red
Write-Host "  1. Check container logs: docker logs <container-name>"
Write-Host "  2. Check Traefik routing: curl -k https://nxcore.tail79107c.ts.net/api/http/routers"
Write-Host "  3. Restart services: docker restart <container-name>"
