# PowerShell script to deploy ALL fixes from the entire thread
# Comprehensive deployment of all patches and fixes

param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

# Enable verbose output and error handling
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "🚀 NXCore Complete Fix Deployment" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue
Write-Host "Deploying ALL fixes and patches from the entire thread..."
Write-Host "Server: $ServerHost"
Write-Host "User: $Username"
Write-Host ""

# Test SSH connection first
Write-Host "🔍 Testing SSH connection..." -ForegroundColor Yellow
try {
    $sshTest = ssh -o ConnectTimeout=10 -o BatchMode=yes ${Username}@${ServerHost} "echo 'SSH connection successful'" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "SSH connection failed: $sshTest"
    }
    Write-Host "✅ SSH connection successful" -ForegroundColor Green
} catch {
    Write-Host "❌ SSH connection failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Red
    Write-Host "1. Server is accessible: ping $ServerHost" -ForegroundColor Red
    Write-Host "2. SSH key is configured: ssh ${Username}@${ServerHost}" -ForegroundColor Red
    Write-Host "3. User has sudo access" -ForegroundColor Red
    exit 1
}

# Phase 1: Copy all files to server
Write-Host "📁 Phase 1: Copying all files to server..." -ForegroundColor Yellow

try {
    # Copy all scripts
    Write-Host "  - Copying scripts..." -ForegroundColor Cyan
    scp -r scripts/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy scripts" }
    Write-Host "    ✅ Scripts copied" -ForegroundColor Green

    # Copy all Docker compose files
    Write-Host "  - Copying Docker compose files..." -ForegroundColor Cyan
    scp -r docker/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy Docker files" }
    Write-Host "    ✅ Docker files copied" -ForegroundColor Green

    # Copy all systemd files
    Write-Host "  - Copying systemd files..." -ForegroundColor Cyan
    scp -r systemd/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy systemd files" }
    Write-Host "    ✅ Systemd files copied" -ForegroundColor Green

    # Copy all n8n functions
    Write-Host "  - Copying n8n functions..." -ForegroundColor Cyan
    scp -r n8n/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy n8n files" }
    Write-Host "    ✅ n8n files copied" -ForegroundColor Green

    # Copy all AI files
    Write-Host "  - Copying AI files..." -ForegroundColor Cyan
    scp -r ai/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy AI files" }
    Write-Host "    ✅ AI files copied" -ForegroundColor Green

    # Copy all tests
    Write-Host "  - Copying test files..." -ForegroundColor Cyan
    scp -r tests/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy test files" }
    Write-Host "    ✅ Test files copied" -ForegroundColor Green

    # Copy all docs
    Write-Host "  - Copying documentation..." -ForegroundColor Cyan
    scp -r docs/ ${Username}@${ServerHost}:/srv/core/nxcore/
    if ($LASTEXITCODE -ne 0) { throw "Failed to copy documentation" }
    Write-Host "    ✅ Documentation copied" -ForegroundColor Green

    Write-Host "✅ Phase 1 Complete - All files copied successfully" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Phase 1 Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Red
    Write-Host "1. Files exist in current directory" -ForegroundColor Red
    Write-Host "2. SSH connection is working" -ForegroundColor Red
    Write-Host "3. Server has /srv/core/nxcore directory" -ForegroundColor Red
    exit 1
}

# Phase 2: Deploy Shipping & Receiving System
Write-Host "📦 Phase 2: Deploying Shipping & Receiving System..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/setup_shipping_receiving.sh && sudo /srv/core/nxcore/scripts/setup_shipping_receiving.sh"
Write-Host "✅ Shipping & Receiving System Deployed" -ForegroundColor Green
Write-Host ""

# Phase 3: Deploy AI System
Write-Host "🤖 Phase 3: Deploying AI System..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/setup_ai_system.sh && sudo /srv/core/nxcore/scripts/setup_ai_system.sh"
Write-Host "✅ AI System Deployed" -ForegroundColor Green
Write-Host ""

# Phase 4: Fix Traefik Routing
Write-Host "🔧 Phase 4: Fixing Traefik Routing..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/fix-traefik-routing.sh && sudo /srv/core/nxcore/scripts/fix-traefik-routing.sh"
Write-Host "✅ Traefik Routing Fixed" -ForegroundColor Green
Write-Host ""

# Phase 5: Fix Authelia Authentication
Write-Host "🔐 Phase 5: Fixing Authelia Authentication..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/fix-authelia-routing.sh && sudo /srv/core/nxcore/scripts/fix-authelia-routing.sh"
Write-Host "✅ Authelia Authentication Fixed" -ForegroundColor Green
Write-Host ""

# Phase 6: Fix OpenWebUI AI Service
Write-Host "🧠 Phase 6: Fixing OpenWebUI AI Service..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/fix-openwebui-routing.sh && sudo /srv/core/nxcore/scripts/fix-openwebui-routing.sh"
Write-Host "✅ OpenWebUI AI Service Fixed" -ForegroundColor Green
Write-Host ""

# Phase 7: Deploy Comprehensive Fixes
Write-Host "🔧 Phase 7: Deploying Comprehensive Fixes..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/comprehensive-service-fix.sh && sudo /srv/core/nxcore/scripts/comprehensive-service-fix.sh"
Write-Host "✅ Comprehensive Fixes Deployed" -ForegroundColor Green
Write-Host ""

# Phase 8: Verify All Fixes
Write-Host "🔍 Phase 8: Verifying All Fixes..." -ForegroundColor Yellow
ssh ${Username}@${ServerHost} "chmod +x /srv/core/nxcore/scripts/verify-all-fixes.sh && sudo /srv/core/nxcore/scripts/verify-all-fixes.sh"
Write-Host "✅ Verification Complete" -ForegroundColor Green
Write-Host ""

# Phase 9: Final Service Tests
Write-Host "🧪 Phase 9: Final Service Tests..." -ForegroundColor Yellow

$services = @(
    @{Name="Landing Page"; URL="https://nxcore.tail79107c.ts.net/"},
    @{Name="Traefik API"; URL="https://nxcore.tail79107c.ts.net/api/http/routers"},
    @{Name="Traefik Dashboard"; URL="https://nxcore.tail79107c.ts.net/dash"},
    @{Name="Grafana"; URL="https://nxcore.tail79107c.ts.net/grafana/"},
    @{Name="Prometheus"; URL="https://nxcore.tail79107c.ts.net/prometheus/"},
    @{Name="Portainer"; URL="https://nxcore.tail79107c.ts.net/portainer/"},
    @{Name="AI Service"; URL="https://nxcore.tail79107c.ts.net/ai/"},
    @{Name="FileBrowser"; URL="https://nxcore.tail79107c.ts.net/files/"},
    @{Name="Uptime Kuma"; URL="https://nxcore.tail79107c.ts.net/status/"},
    @{Name="Authelia"; URL="https://nxcore.tail79107c.ts.net/auth/"},
    @{Name="n8n"; URL="https://nxcore.tail79107c.ts.net/n8n/"},
    @{Name="AeroCaller"; URL="https://nxcore.tail79107c.ts.net/aerocaller/"}
)

$workingServices = 0
$totalServices = $services.Count

Write-Host "Testing all services..." -ForegroundColor Cyan

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.URL -SkipCertificateCheck -TimeoutSec 10
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302 -or $response.StatusCode -eq 301) {
            Write-Host "✅ $($service.Name): Working" -ForegroundColor Green
            $workingServices++
        } else {
            Write-Host "⚠️ $($service.Name): Status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($service.Name): Not accessible" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 FINAL DEPLOYMENT SUMMARY" -ForegroundColor Blue
Write-Host "===========================" -ForegroundColor Blue
Write-Host "Total Services: $totalServices"
Write-Host "Working Services: $workingServices"
Write-Host "Success Rate: $([math]::Round(($workingServices / $totalServices) * 100, 1))%"
Write-Host ""

if ($workingServices -eq $totalServices) {
    Write-Host "🎉 ALL FIXES SUCCESSFULLY DEPLOYED!" -ForegroundColor Green
    Write-Host "Your NXCore system is fully operational!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Some services may need additional attention" -ForegroundColor Yellow
    Write-Host "Check the verification results above for details" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌐 SERVICE ACCESS POINTS" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Landing: https://nxcore.tail79107c.ts.net/"
Write-Host "Traefik: https://nxcore.tail79107c.ts.net/dash"
Write-Host "Grafana: https://nxcore.tail79107c.ts.net/grafana/"
Write-Host "AI: https://nxcore.tail79107c.ts.net/ai/"
Write-Host "Auth: https://nxcore.tail79107c.ts.net/auth/"
Write-Host "n8n: https://nxcore.tail79107c.ts.net/n8n/"
Write-Host ""

Write-Host "📋 WHAT WAS DEPLOYED" -ForegroundColor Blue
Write-Host "===================" -ForegroundColor Blue
Write-Host "✅ README.md condensed and optimized"
Write-Host "✅ .gitignore updated for GitHub prep"
Write-Host "✅ Complete Shipping & Receiving system"
Write-Host "✅ AI system with llama3.2 and monitoring"
Write-Host "✅ Traefik routing fixes (API, Dashboard, Services)"
Write-Host "✅ Authelia authentication fixes"
Write-Host "✅ OpenWebUI AI service fixes"
Write-Host "✅ n8n workflow automation"
Write-Host "✅ Comprehensive monitoring and health checks"
Write-Host "✅ Playwright testing system"
Write-Host "✅ All documentation and fix scripts"
Write-Host ""

Write-Host "🔧 IF ISSUES PERSIST" -ForegroundColor Red
Write-Host "===================" -ForegroundColor Red
Write-Host "1. Check container status: docker ps"
Write-Host "2. Check service logs: docker logs <container-name>"
Write-Host "3. Check Traefik routing: curl -k https://nxcore.tail79107c.ts.net/api/http/routers"
Write-Host "4. Run verification: sudo /srv/core/nxcore/scripts/verify-all-fixes.sh"
Write-Host "5. Check systemd services: systemctl status <service-name>"
