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
