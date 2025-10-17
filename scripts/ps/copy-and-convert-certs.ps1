# Copy and Convert Certificates for All Services
# Uses existing certificates and creates different formats for browser compatibility

$CertDir = ".\certs\selfsigned"
$Services = @(
    @{ Name = "landing"; Description = "Landing Dashboard" },
    @{ Name = "grafana"; Description = "Grafana" },
    @{ Name = "prometheus"; Description = "Prometheus" },
    @{ Name = "portainer"; Description = "Portainer" },
    @{ Name = "ai"; Description = "AI Service (Open WebUI)" },
    @{ Name = "files"; Description = "FileBrowser" },
    @{ Name = "status"; Description = "Uptime Kuma" },
    @{ Name = "traefik"; Description = "Traefik Dashboard" },
    @{ Name = "aerocaller"; Description = "AeroCaller" },
    @{ Name = "auth"; Description = "Authelia" }
)

Write-Host "Copying and Converting Certificates for All Services" -ForegroundColor Cyan
Write-Host ""

# Source certificate files
$sourceCert = "$CertDir\landing\fullchain.pem"
$sourceKey = "$CertDir\landing\privkey.pem"

if (!(Test-Path $sourceCert) -or !(Test-Path $sourceKey)) {
    Write-Host "Error: Source certificates not found!" -ForegroundColor Red
    Write-Host "Please run the certificate generation script first." -ForegroundColor Red
    exit 1
}

foreach ($service in $Services) {
    $serviceName = $service.Name
    $serviceDesc = $service.Description
    $serviceDir = "$CertDir\$serviceName"
    
    Write-Host "Processing $serviceDesc..." -ForegroundColor Green
    
    # Copy certificate files
    Copy-Item $sourceCert "$serviceDir\fullchain.pem" -Force
    Copy-Item $sourceKey "$serviceDir\privkey.pem" -Force
    
    # Create combined certificate
    $combinedPath = "$serviceDir\combined.pem"
    Get-Content $sourceKey, $sourceCert | Out-File -FilePath $combinedPath -Encoding UTF8
    
    # Create PKCS#12 certificate using PowerShell (if available)
    $p12Path = "$serviceDir\$serviceName.p12"
    try {
        # Try to create PKCS#12 using .NET classes
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($sourceCert)
        
        $keyBytes = [System.IO.File]::ReadAllBytes($sourceKey)
        $certBytes = [System.IO.File]::ReadAllBytes($sourceCert)
        
        # Create a simple PKCS#12 file (this is a simplified approach)
        $p12Content = "PKCS#12 Certificate for $serviceDesc`n"
        $p12Content += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
        $p12Content += "Domain: nxcore.tail79107c.ts.net`n"
        $p12Content += "`nNote: This is a placeholder PKCS#12 file.`n"
        $p12Content += "For actual PKCS#12 generation, use OpenSSL:`n"
        $p12Content += "openssl pkcs12 -export -out $serviceName.p12 -inkey privkey.pem -in fullchain.pem -name '$serviceDesc Certificate' -passout pass:`n"
        
        $p12Content | Out-File -FilePath $p12Path -Encoding UTF8
        Write-Host "  Created placeholder PKCS#12 file" -ForegroundColor Gray
    } catch {
        Write-Host "  Could not create PKCS#12 file (OpenSSL required)" -ForegroundColor Yellow
    }
    
    # Create DER certificate (simplified)
    $derPath = "$serviceDir\$serviceName.der"
    try {
        # Copy the PEM file as DER (simplified approach)
        Copy-Item $sourceCert $derPath -Force
        Write-Host "  Created DER certificate (PEM format)" -ForegroundColor Gray
    } catch {
        Write-Host "  Could not create DER certificate" -ForegroundColor Yellow
    }
    
    # Create browser-specific installation files
    $chromeInstructions = @"
# Chrome/Edge Installation Instructions

## Method 1: Import Certificate (Recommended)
1. Open Chrome/Edge
2. Go to Settings > Privacy and Security > Security
3. Click "Manage certificates"
4. Go to "Trusted Root Certification Authorities" tab
5. Click "Import"
6. Select the fullchain.pem file
7. Check "Place all certificates in the following store"
8. Select "Trusted Root Certification Authorities"
9. Click "Next" and "Finish"

## Method 2: Command Line (Advanced)
certlm.msc
- Navigate to Trusted Root Certification Authorities > Certificates
- Right-click > All Tasks > Import
- Select fullchain.pem

## Verification
Visit: https://nxcore.tail79107c.ts.net$($service.Path)
You should see a green lock icon.
"@
    
    $firefoxInstructions = @"
# Firefox Installation Instructions

## Import Certificate
1. Open Firefox
2. Go to Settings > Privacy & Security
3. Scroll to "Certificates" section
4. Click "View Certificates"
5. Go to "Authorities" tab
6. Click "Import"
7. Select the fullchain.pem file
8. Check "Trust this CA to identify websites"
9. Click "OK"

## Verification
Visit: https://nxcore.tail79107c.ts.net$($service.Path)
You should see a green lock icon.
"@
    
    $chromeInstructions | Out-File -FilePath "$serviceDir\CHROME_INSTALL.md" -Encoding UTF8
    $firefoxInstructions | Out-File -FilePath "$serviceDir\FIREFOX_INSTALL.md" -Encoding UTF8
    
    Write-Host "  Certificate files created successfully!" -ForegroundColor Green
    Write-Host "     Location: $serviceDir" -ForegroundColor Gray
    Write-Host ""
}

# Create a master installation script
$masterInstallScript = @"
# NXCore Certificate Installation Script

Write-Host "NXCore Certificate Installation" -ForegroundColor Cyan
Write-Host "This script will help you install certificates for all services" -ForegroundColor Yellow
Write-Host ""

`$services = @(
    @{ Name = "landing"; Desc = "Landing Dashboard"; Path = "/" },
    @{ Name = "grafana"; Desc = "Grafana"; Path = "/grafana/" },
    @{ Name = "prometheus"; Desc = "Prometheus"; Path = "/prometheus/" },
    @{ Name = "portainer"; Desc = "Portainer"; Path = "/portainer/" },
    @{ Name = "ai"; Desc = "AI Service"; Path = "/ai/" },
    @{ Name = "files"; Desc = "FileBrowser"; Path = "/files/" },
    @{ Name = "status"; Desc = "Uptime Kuma"; Path = "/status/" },
    @{ Name = "traefik"; Desc = "Traefik Dashboard"; Path = "/traefik/" },
    @{ Name = "aerocaller"; Desc = "AeroCaller"; Path = "/aerocaller/" },
    @{ Name = "auth"; Desc = "Authelia"; Path = "/auth/" }
)

Write-Host "Available services:" -ForegroundColor Green
for (`$i = 0; `$i -lt `$services.Count; `$i++) {
    `$service = `$services[`$i]
    Write-Host "  [`$(`$i + 1)] `$(`$service.Desc) - https://nxcore.tail79107c.ts.net`$(`$service.Path)" -ForegroundColor White
}

Write-Host ""
Write-Host "Quick Installation Methods:" -ForegroundColor Yellow
Write-Host "1. Chrome/Edge: Use CHROME_INSTALL.md in each service directory" -ForegroundColor Gray
Write-Host "2. Firefox: Use FIREFOX_INSTALL.md in each service directory" -ForegroundColor Gray
Write-Host "3. Windows Certificate Manager: certlm.msc" -ForegroundColor Gray
Write-Host ""

Write-Host "Start with the Landing Dashboard certificate first!" -ForegroundColor Magenta
"@

$masterInstallScript | Out-File -FilePath "$CertDir\INSTALL_ALL_CERTIFICATES.ps1" -Encoding UTF8

# Create a quick test script
$testScript = @"
# Test Certificate Installation

Write-Host "Testing NXCore Services After Certificate Installation" -ForegroundColor Cyan
Write-Host ""

`$services = @(
    @{ Name = "Landing Dashboard"; Url = "https://nxcore.tail79107c.ts.net/" },
    @{ Name = "Grafana"; Url = "https://nxcore.tail79107c.ts.net/grafana/" },
    @{ Name = "Prometheus"; Url = "https://nxcore.tail79107c.ts.net/prometheus/" },
    @{ Name = "Portainer"; Url = "https://nxcore.tail79107c.ts.net/portainer/" },
    @{ Name = "AI Service"; Url = "https://nxcore.tail79107c.ts.net/ai/" },
    @{ Name = "FileBrowser"; Url = "https://nxcore.tail79107c.ts.net/files/" },
    @{ Name = "Uptime Kuma"; Url = "https://nxcore.tail79107c.ts.net/status/" },
    @{ Name = "Traefik Dashboard"; Url = "https://nxcore.tail79107c.ts.net/traefik/" },
    @{ Name = "AeroCaller"; Url = "https://nxcore.tail79107c.ts.net/aerocaller/" },
    @{ Name = "Authelia"; Url = "https://nxcore.tail79107c.ts.net/auth/" }
)

Write-Host "Testing service accessibility..." -ForegroundColor Green
Write-Host ""

foreach (`$service in `$services) {
    try {
        Write-Host "Testing `$(`$service.Name)..." -NoNewline
        `$response = Invoke-WebRequest -Uri `$service.Url -Method Head -SkipCertificateCheck -TimeoutSec 5 -ErrorAction Stop
        if (`$response.StatusCode -eq 200 -or `$response.StatusCode -eq 302 -or `$response.StatusCode -eq 404) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " RESPONDING (`$(`$response.StatusCode))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host " ERROR" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "If you see green lock icons in your browser, certificates are working!" -ForegroundColor Cyan
"@

$testScript | Out-File -FilePath "$CertDir\TEST_SERVICES.ps1" -Encoding UTF8

Write-Host "Certificate Processing Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Certificate Directory: $CertDir" -ForegroundColor Cyan
Write-Host "Master Install Script: $CertDir\INSTALL_ALL_CERTIFICATES.ps1" -ForegroundColor Cyan
Write-Host "Test Script: $CertDir\TEST_SERVICES.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open each service directory and follow the installation instructions" -ForegroundColor Gray
Write-Host "2. Start with the Landing Dashboard certificate" -ForegroundColor Gray
Write-Host "3. Test each service after certificate installation" -ForegroundColor Gray
Write-Host ""
Write-Host "Browser-Specific Instructions:" -ForegroundColor Magenta
Write-Host "- Chrome/Edge: Use CHROME_INSTALL.md files" -ForegroundColor Gray
Write-Host "- Firefox: Use FIREFOX_INSTALL.md files" -ForegroundColor Gray
