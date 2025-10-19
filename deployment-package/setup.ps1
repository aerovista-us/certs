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
