# Deploy Self-Signed Certificates to NXCore Server

param(
    [string]$Server = "glyph@100.115.9.61",
    [string]$CertDir = ".\certs\selfsigned",
    [string]$RemoteCertDir = "/opt/nexus/traefik/certs"
)

$ErrorActionPreference = "Stop"

# Helper function to run SSH commands
function Run-SSH {
    param([string]$Command)
    ssh $Server $Command
    if ($LASTEXITCODE -ne 0) {
        throw "SSH command failed: $Command"
    }
}

# Helper function to copy files via SCP
function Push-File {
    param(
        [string]$LocalPath,
        [string]$RemotePath
    )
    
    $tempPath = "/tmp/$(Split-Path -Leaf $LocalPath)"
    
    Write-Host "  📤 Copying $(Split-Path -Leaf $LocalPath)..." -ForegroundColor Cyan
    scp $LocalPath "${Server}:${tempPath}"
    if ($LASTEXITCODE -ne 0) {
        throw "SCP failed for $LocalPath"
    }
    
    Run-SSH "sudo install -m 0644 -o root -g root $tempPath $RemotePath && rm $tempPath"
}

Write-Host "🚀 Deploying Self-Signed Certificates to NXCore" -ForegroundColor Cyan
Write-Host ""

# Check if certificates exist
$keyFile = Join-Path $CertDir "privkey.pem"
$certFile = Join-Path $CertDir "fullchain.pem"

if (-not (Test-Path $keyFile)) {
    Write-Host "❌ Private key not found: $keyFile" -ForegroundColor Red
    Write-Host "Run: .\scripts\ps\generate-selfsigned-certs.ps1" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $certFile)) {
    Write-Host "❌ Certificate not found: $certFile" -ForegroundColor Red
    Write-Host "Run: .\scripts\ps\generate-selfsigned-certs.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found certificates locally" -ForegroundColor Green
Write-Host ""

# Create remote certificate directory
Write-Host "📁 Creating remote certificate directory..." -ForegroundColor Cyan
Run-SSH "sudo mkdir -p $RemoteCertDir"

# Deploy certificates
Write-Host "🔐 Deploying certificates..." -ForegroundColor Cyan
Push-File $keyFile "$RemoteCertDir/privkey.pem"
Push-File $certFile "$RemoteCertDir/fullchain.pem"

# Set proper permissions
Write-Host "🔒 Setting permissions..." -ForegroundColor Cyan
Run-SSH "sudo chown -R root:root $RemoteCertDir && sudo chmod 0600 $RemoteCertDir/privkey.pem && sudo chmod 0644 $RemoteCertDir/fullchain.pem"

# Verify certificates on server
Write-Host ""
Write-Host "🔍 Verifying certificates on server..." -ForegroundColor Cyan
Run-SSH "sudo ls -lh $RemoteCertDir/"

# Check if Traefik is running
Write-Host ""
Write-Host "🔄 Restarting Traefik..." -ForegroundColor Cyan
$traefikStatus = ssh $Server "sudo docker ps -q -f name=traefik" 2>$null

if ($traefikStatus) {
    Run-SSH "sudo docker restart traefik"
    Write-Host "✅ Traefik restarted" -ForegroundColor Green
    
    # Wait for Traefik to start
    Write-Host "⏳ Waiting for Traefik to start..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    
    # Check Traefik logs
    Write-Host ""
    Write-Host "📋 Traefik logs (last 20 lines):" -ForegroundColor Cyan
    Run-SSH "sudo docker logs --tail 20 traefik"
} else {
    Write-Host "⚠️  Traefik is not running. Start it with:" -ForegroundColor Yellow
    Write-Host "  .\scripts\ps\deploy-containers.ps1 -Service traefik" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Certificates deployed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Test your services:" -ForegroundColor Cyan
Write-Host "  https://nxcore.tail79107c.ts.net/traefik/" -ForegroundColor Yellow
Write-Host "  https://nxcore.tail79107c.ts.net/grafana/" -ForegroundColor Yellow
Write-Host "  https://nxcore.tail79107c.ts.net/prometheus/" -ForegroundColor Yellow
Write-Host "  https://nxcore.tail79107c.ts.net/files/" -ForegroundColor Yellow
Write-Host "  http://100.115.9.61:8080/ (code-server)" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Remember to import the certificate to your browser!" -ForegroundColor Yellow
Write-Host "  Certificate location: $certFile" -ForegroundColor Yellow

