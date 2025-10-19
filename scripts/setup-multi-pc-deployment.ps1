# setup-multi-pc-deployment.ps1
# Create deployment package for multiple PCs with OpenSSL and certificate generation

param(
    [string]$DeploymentDir = ".\deployment-package",
    [string]$OpenSSLSource = ".\documents\Certificate System\Win64OpenSSL_Light-3_6_0.exe"
)

# Simple logging functions
function Log($message) { 
    Write-Host "LOG: $message" -ForegroundColor Blue 
}

function Success($message) { 
    Write-Host "SUCCESS: $message" -ForegroundColor Green 
}

function Warning($message) { 
    Write-Host "WARNING: $message" -ForegroundColor Yellow 
}

function Error($message) { 
    Write-Host "ERROR: $message" -ForegroundColor Red 
}

Log "Creating Multi-PC Deployment Package..."

# Create deployment directory structure
$DeploymentDir = ".\deployment-package"
$OpenSSLDir = Join-Path $DeploymentDir "openssl"
$ScriptsDir = Join-Path $DeploymentDir "scripts"
$DocsDir = Join-Path $DeploymentDir "docs"
$CertsDir = Join-Path $DeploymentDir "certs"

# Create directories
New-Item -ItemType Directory -Path $DeploymentDir -Force | Out-Null
New-Item -ItemType Directory -Path $OpenSSLDir -Force | Out-Null
New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
New-Item -ItemType Directory -Path $DocsDir -Force | Out-Null
New-Item -ItemType Directory -Path $CertsDir -Force | Out-Null

# Copy OpenSSL installer
if (Test-Path $OpenSSLSource) {
    Copy-Item $OpenSSLSource -Destination $OpenSSLDir
    Success "OpenSSL installer copied to deployment package"
} else {
    Error "OpenSSL installer not found at: $OpenSSLSource"
    Error "Please ensure the OpenSSL installer is in the correct location"
    exit 1
}

# Copy certificate generation scripts
$ScriptsToCopy = @(
    "generate-and-deploy-bundles-fixed.ps1",
    "generate-full-key-bundles.sh",
    "fix-certificate-system.sh"
)

foreach ($Script in $ScriptsToCopy) {
    $SourceScript = ".\scripts\$Script"
    if (Test-Path $SourceScript) {
        Copy-Item $SourceScript -Destination $ScriptsDir
        Success "Copied $Script to deployment package"
    } else {
        Warning "Script not found: $SourceScript"
    }
}

# Copy documentation
$DocsToCopy = @(
    "Certificate System\FULL_KEY_BUNDLES_GUIDE.md",
    "Certificate System\CERTIFICATE_SETUP_COMPLETE.md",
    "Certificate System\CERTIFICATE_INSTALLATION_GUIDE.md"
)

foreach ($Doc in $DocsToCopy) {
    $SourceDoc = ".\documents\$Doc"
    if (Test-Path $SourceDoc) {
        $DocDir = Split-Path $Doc -Parent
        $TargetDocDir = Join-Path $DocsDir $DocDir
        New-Item -ItemType Directory -Path $TargetDocDir -Force | Out-Null
        Copy-Item $SourceDoc -Destination $TargetDocDir
        Success "Copied $Doc to deployment package"
    } else {
        Warning "Documentation not found: $SourceDoc"
    }
}

# Create installation script for new PCs
$InstallScript = @'
# install-openssl-and-setup.ps1
# Install OpenSSL and set up certificate generation on new PC

param(
    [string]$OpenSSLPath = ".\openssl\Win64OpenSSL_Light-3_6_0.exe",
    [string]$InstallPath = "C:\OpenSSL-Win64"
)

Write-Host "Installing OpenSSL on Windows..." -ForegroundColor Yellow

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
}

# Install OpenSSL silently
if (Test-Path $OpenSSLPath) {
    Write-Host "Installing OpenSSL from: $OpenSSLPath" -ForegroundColor Green
    
    # Run OpenSSL installer silently
    $InstallArgs = @(
        "/S",                    # Silent install
        "/D=$InstallPath"        # Installation directory
    )
    
    Start-Process -FilePath $OpenSSLPath -ArgumentList $InstallArgs -Wait
    
    # Add OpenSSL to PATH
    $OpenSSLBin = Join-Path $InstallPath "bin"
    $CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($CurrentPath -notlike "*$OpenSSLBin*") {
        [Environment]::SetEnvironmentVariable("PATH", "$CurrentPath;$OpenSSLBin", "Machine")
        Write-Host "Added OpenSSL to system PATH" -ForegroundColor Green
    }
    
    # Verify installation
    try {
        $null = & "$OpenSSLBin\openssl.exe" version
        Write-Host "OpenSSL installed successfully!" -ForegroundColor Green
        Write-Host "Version: $(& "$OpenSSLBin\openssl.exe" version)" -ForegroundColor Cyan
    } catch {
        Write-Host "OpenSSL installation verification failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "OpenSSL installer not found at: $OpenSSLPath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "OpenSSL Installation Complete!" -ForegroundColor Green
Write-Host "You can now run the certificate generation scripts." -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\scripts\generate-and-deploy-bundles-fixed.ps1" -ForegroundColor White
Write-Host "2. Follow the prompts to generate certificates" -ForegroundColor White
Write-Host "3. Deploy certificates to your NXCore server" -ForegroundColor White
'@

Set-Content -Path (Join-Path $DeploymentDir "install-openssl-and-setup.ps1") -Value $InstallScript

# Create quick start guide
$QuickStartGuide = @'
# NXCore Multi-PC Certificate Deployment

## Quick Start Guide

### For New PCs

1. **Copy the entire `deployment-package` folder to the new PC**

2. **Run as Administrator:**
   ```powershell
   .\install-openssl-and-setup.ps1
   ```

3. **Generate and deploy certificates:**
   ```powershell
   .\scripts\generate-and-deploy-bundles-fixed.ps1
   ```

### What's Included

- **OpenSSL Installer**: `openssl\Win64OpenSSL_Light-3_6_0.exe`
- **Certificate Scripts**: All PowerShell and Bash scripts
- **Documentation**: Complete installation guides
- **Auto-Installer**: Automated OpenSSL installation

### Prerequisites

- Windows 10/11
- Administrator privileges
- Network access to NXCore server
- SSH access to server (100.115.9.61)

### Server Configuration

The scripts will automatically:
- Generate certificates for all 10 services
- Deploy certificates to `/opt/nexus/traefik/certs/`
- Configure Traefik SSL
- Create client installation packages
- Restart Traefik with new certificates

### Services Covered

| Service | Certificate | Client Package |
|---------|-------------|----------------|
| Landing | ✅ | ✅ |
| Grafana | ✅ | ✅ |
| Prometheus | ✅ | ✅ |
| Portainer | ✅ | ✅ |
| AI Service | ✅ | ✅ |
| FileBrowser | ✅ | ✅ |
| Uptime Kuma | ✅ | ✅ |
| Traefik | ✅ | ✅ |
| AeroCaller | ✅ | ✅ |
| Authelia | ✅ | ✅ |

### Troubleshooting

#### OpenSSL Issues
- Ensure running as Administrator
- Check PATH environment variable
- Verify OpenSSL installation directory

#### Certificate Generation Issues
- Check network connectivity to server
- Verify SSH credentials
- Review server disk space

#### Deployment Issues
- Check Traefik container status
- Review server certificate permissions
- Test SSL connectivity

### Support Files

- **Installation Logs**: Check PowerShell execution logs
- **Server Logs**: `docker logs traefik`
- **Certificate Status**: `ls -la /opt/nexus/traefik/certs/`

---
**Package Version**: 1.0
**Created**: $(Get-Date)
**Status**: Ready for Multi-PC Deployment
'@

Set-Content -Path (Join-Path $DeploymentDir "README.md") -Value $QuickStartGuide

# Create deployment checklist
$Checklist = @'
# NXCore Multi-PC Deployment Checklist

## Pre-Deployment
- [ ] Copy deployment package to target PC
- [ ] Ensure Administrator privileges
- [ ] Verify network connectivity to server
- [ ] Confirm SSH access to 100.115.9.61

## Installation
- [ ] Run `install-openssl-and-setup.ps1` as Administrator
- [ ] Verify OpenSSL installation
- [ ] Check OpenSSL is in system PATH
- [ ] Test OpenSSL command: `openssl version`

## Certificate Generation
- [ ] Run `generate-and-deploy-bundles-fixed.ps1`
- [ ] Verify certificate generation for all services
- [ ] Check server deployment success
- [ ] Confirm Traefik restart
- [ ] Validate SSL configuration

## Post-Deployment
- [ ] Test all services for green lock icons
- [ ] Verify client installation packages
- [ ] Check server certificate permissions
- [ ] Review Traefik logs for errors
- [ ] Test certificate connectivity

## Services to Verify
- [ ] https://nxcore.tail79107c.ts.net/ (Landing)
- [ ] https://nxcore.tail79107c.ts.net/grafana/
- [ ] https://nxcore.tail79107c.ts.net/prometheus/
- [ ] https://nxcore.tail79107c.ts.net/portainer/
- [ ] https://nxcore.tail79107c.ts.net/ai/
- [ ] https://nxcore.tail79107c.ts.net/files/
- [ ] https://nxcore.tail79107c.ts.net/status/
- [ ] https://nxcore.tail79107c.ts.net/traefik/
- [ ] https://nxcore.tail79107c.ts.net/aerocaller/
- [ ] https://nxcore.tail79107c.ts.net/auth/

## Success Criteria
- [ ] All services show green lock icons
- [ ] No certificate errors in browser
- [ ] Traefik logs show no SSL errors
- [ ] Client installation packages ready
- [ ] Server certificates properly deployed

---
**Checklist Version**: 1.0
**Last Updated**: $(Get-Date)
'@

Set-Content -Path (Join-Path $DeploymentDir "DEPLOYMENT_CHECKLIST.md") -Value $Checklist

# Create batch file for easy execution
$BatchFile = @'
@echo off
echo NXCore Multi-PC Certificate Deployment
echo =====================================
echo.
echo This will install OpenSSL and set up certificate generation.
echo.
echo Prerequisites:
echo - Administrator privileges required
echo - Network access to NXCore server
echo - SSH access to 100.115.9.61
echo.
pause
echo.
echo Installing OpenSSL...
powershell -ExecutionPolicy Bypass -File "install-openssl-and-setup.ps1"
echo.
echo OpenSSL installation complete!
echo.
echo Next: Run certificate generation
echo powershell -ExecutionPolicy Bypass -File "scripts\generate-and-deploy-bundles-fixed.ps1"
echo.
pause
'@

Set-Content -Path (Join-Path $DeploymentDir "setup.bat") -Value $BatchFile

# Create PowerShell execution policy bypass script
$PowerShellScript = @'
# NXCore Multi-PC Setup Script
# This script handles execution policy and runs the installation

Write-Host "NXCore Multi-PC Certificate Deployment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Running OpenSSL installation..." -ForegroundColor Yellow
& ".\install-openssl-and-setup.ps1"

Write-Host ""
Write-Host "OpenSSL installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run certificate generation:" -ForegroundColor White
Write-Host "   .\scripts\generate-and-deploy-bundles-fixed.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Follow the prompts to generate certificates" -ForegroundColor White
Write-Host "3. Deploy certificates to your NXCore server" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"
'@

Set-Content -Path (Join-Path $DeploymentDir "setup.ps1") -Value $PowerShellScript

# Create deployment summary
$DeploymentSummary = @'
# NXCore Multi-PC Deployment Package

## Package Contents

### Core Files
- `Win64OpenSSL_Light-3_6_0.exe` - OpenSSL installer
- `install-openssl-and-setup.ps1` - Automated OpenSSL installation
- `setup.bat` - Windows batch file for easy execution
- `setup.ps1` - PowerShell setup script

### Certificate Scripts
- `generate-and-deploy-bundles-fixed.ps1` - Main certificate generation
- `generate-full-key-bundles.sh` - Bash alternative
- `fix-certificate-system.sh` - Certificate system repair

### Documentation
- `README.md` - Quick start guide
- `DEPLOYMENT_CHECKLIST.md` - Step-by-step checklist
- `FULL_KEY_BUNDLES_GUIDE.md` - Certificate format guide
- `CERTIFICATE_SETUP_COMPLETE.md` - Complete setup guide
- `CERTIFICATE_INSTALLATION_GUIDE.md` - Client installation guide

### Directory Structure
```
deployment-package/
├── openssl/
│   └── Win64OpenSSL_Light-3_6_0.exe
├── scripts/
│   ├── generate-and-deploy-bundles-fixed.ps1
│   ├── generate-full-key-bundles.sh
│   └── fix-certificate-system.sh
├── docs/
│   └── Certificate System/
│       ├── FULL_KEY_BUNDLES_GUIDE.md
│       ├── CERTIFICATE_SETUP_COMPLETE.md
│       └── CERTIFICATE_INSTALLATION_GUIDE.md
├── certs/
│   └── (generated certificates)
├── install-openssl-and-setup.ps1
├── setup.bat
├── setup.ps1
├── README.md
└── DEPLOYMENT_CHECKLIST.md
```

## Quick Start

### For New PCs
1. Copy entire `deployment-package` folder
2. Run `setup.bat` as Administrator
3. Follow prompts to install OpenSSL
4. Run certificate generation script

### For Existing PCs
1. Ensure OpenSSL is installed
2. Run `scripts\generate-and-deploy-bundles-fixed.ps1`
3. Follow prompts to generate certificates

## Server Configuration

The scripts automatically configure:
- **Server**: 100.115.9.61 (glyph@100.115.9.61)
- **Domain**: nxcore.tail79107c.ts.net
- **Certificate Path**: /opt/nexus/traefik/certs/
- **Services**: 10 services with full SSL coverage

## Services Covered

| Service | Path | SSL Status |
|---------|------|------------|
| Landing | / | ✅ |
| Grafana | /grafana/ | ✅ |
| Prometheus | /prometheus/ | ✅ |
| Portainer | /portainer/ | ✅ |
| AI Service | /ai/ | ✅ |
| FileBrowser | /files/ | ✅ |
| Uptime Kuma | /status/ | ✅ |
| Traefik | /traefik/ | ✅ |
| AeroCaller | /aerocaller/ | ✅ |
| Authelia | /auth/ | ✅ |

## Certificate Formats Generated

- **PEM**: Server SSL certificates
- **P12**: Windows client import
- **CRT**: Windows applications
- **DER**: Binary format
- **PFX**: Alternative Windows format
- **Combined PEM**: Server deployment

## Client Installation Packages

Each service gets a complete installation package with:
- All certificate formats
- Platform-specific installers (Windows, Linux, macOS)
- Installation guides
- Verification instructions

---
**Package Version**: 1.0
**Created**: $(Get-Date)
**Status**: Ready for Multi-PC Deployment
'@

Set-Content -Path (Join-Path $DeploymentDir "DEPLOYMENT_SUMMARY.md") -Value $DeploymentSummary

Success "Multi-PC deployment package created successfully!"
Success "Package location: $DeploymentDir"

Write-Host ""
Write-Host "DEPLOYMENT PACKAGE CREATED" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package Location: $DeploymentDir" -ForegroundColor Green
Write-Host ""
Write-Host "Contents:" -ForegroundColor Yellow
Write-Host "• OpenSSL installer" -ForegroundColor White
Write-Host "• Certificate generation scripts" -ForegroundColor White
Write-Host "• Complete documentation" -ForegroundColor White
Write-Host "• Auto-installer for new PCs" -ForegroundColor White
Write-Host "• Deployment checklist" -ForegroundColor White
Write-Host ""
Write-Host "For New PCs:" -ForegroundColor Yellow
Write-Host "1. Copy entire deployment-package folder" -ForegroundColor White
Write-Host "2. Run setup.bat as Administrator" -ForegroundColor White
Write-Host "3. Follow prompts to install OpenSSL" -ForegroundColor White
Write-Host "4. Run certificate generation script" -ForegroundColor White
Write-Host ""
Write-Host "For Existing PCs:" -ForegroundColor Yellow
Write-Host "1. Ensure OpenSSL is installed" -ForegroundColor White
Write-Host "2. Run scripts\generate-and-deploy-bundles-fixed.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Package is ready for distribution to multiple PCs!" -ForegroundColor Green
