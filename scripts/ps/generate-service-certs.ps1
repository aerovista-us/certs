# Generate Self-Signed Certificates for Each Service
# Creates individual certificates for better browser compatibility

param(
    [string]$Domain = "nxcore.tail79107c.ts.net",
    [string]$IP = "100.115.9.61"
)

$CertDir = ".\certs\selfsigned"
$Services = @(
    @{ Name = "landing"; Path = "/"; Description = "Landing Dashboard" },
    @{ Name = "grafana"; Path = "/grafana/"; Description = "Grafana" },
    @{ Name = "prometheus"; Path = "/prometheus/"; Description = "Prometheus" },
    @{ Name = "portainer"; Path = "/portainer/"; Description = "Portainer" },
    @{ Name = "ai"; Path = "/ai/"; Description = "AI Service (Open WebUI)" },
    @{ Name = "files"; Path = "/files/"; Description = "FileBrowser" },
    @{ Name = "status"; Path = "/status/"; Description = "Uptime Kuma" },
    @{ Name = "traefik"; Path = "/traefik/"; Description = "Traefik Dashboard" },
    @{ Name = "aerocaller"; Path = "/aerocaller/"; Description = "AeroCaller" },
    @{ Name = "auth"; Path = "/auth/"; Description = "Authelia" }
)

Write-Host "🔐 Generating Self-Signed Certificates for NXCore Services" -ForegroundColor Cyan
Write-Host "Domain: $Domain" -ForegroundColor Yellow
Write-Host "IP: $IP" -ForegroundColor Yellow
Write-Host ""

# Create certificate directory structure
if (!(Test-Path $CertDir)) {
    New-Item -ItemType Directory -Path $CertDir -Force | Out-Null
}

foreach ($service in $Services) {
    $serviceName = $service.Name
    $servicePath = $service.Path
    $serviceDesc = $service.Description
    
    Write-Host "📋 Generating certificate for $serviceDesc..." -ForegroundColor Green
    
    # Create service-specific directory
    $serviceDir = "$CertDir\$serviceName"
    if (!(Test-Path $serviceDir)) {
        New-Item -ItemType Directory -Path $serviceDir -Force | Out-Null
    }
    
    # Create certificate configuration
    $certConf = @"
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
x509_extensions = v3_ca

[dn]
C=US
ST=California
L=San Francisco
O=NXCore
OU=Infrastructure
CN=$Domain

[v3_req]
keyUsage = keyEncipherment, dataEncipherment, digitalSignature
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[v3_ca]
keyUsage = keyEncipherment, dataEncipherment, digitalSignature
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
basicConstraints = CA:FALSE

[alt_names]
DNS.1 = $Domain
DNS.2 = *.$Domain
IP.1 = $IP
IP.2 = 127.0.0.1
"@
    
    $certConfPath = "$serviceDir\cert.conf"
    $certConf | Out-File -FilePath $certConfPath -Encoding UTF8
    
    # Generate private key
    $privateKeyPath = "$serviceDir\privkey.pem"
    Write-Host "  🔑 Generating private key..." -ForegroundColor Gray
    & openssl genrsa -out $privateKeyPath 2048 2>$null
    
    # Generate certificate
    $certPath = "$serviceDir\fullchain.pem"
    Write-Host "  📜 Generating certificate..." -ForegroundColor Gray
    & openssl req -new -x509 -key $privateKeyPath -out $certPath -days 365 -config $certConfPath -extensions v3_ca 2>$null
    
    # Create combined certificate (for some browsers)
    $combinedPath = "$serviceDir\combined.pem"
    Write-Host "  🔗 Creating combined certificate..." -ForegroundColor Gray
    Get-Content $privateKeyPath, $certPath | Out-File -FilePath $combinedPath -Encoding UTF8
    
    # Create PKCS#12 certificate (for Windows/Chrome)
    $p12Path = "$serviceDir\$serviceName.p12"
    Write-Host "  📦 Creating PKCS#12 certificate..." -ForegroundColor Gray
    & openssl pkcs12 -export -out $p12Path -inkey $privateKeyPath -in $certPath -name "$serviceDesc Certificate" -passout pass: 2>$null
    
    # Create DER certificate (for some browsers)
    $derPath = "$serviceDir\$serviceName.der"
    Write-Host "  🔄 Creating DER certificate..." -ForegroundColor Gray
    & openssl x509 -outform DER -in $certPath -out $derPath 2>$null
    
    # Create installation instructions
    $installInstructions = @"
# $serviceDesc Certificate Installation Instructions

## Certificate Files Generated:
- Private Key: privkey.pem
- Certificate: fullchain.pem  
- Combined: combined.pem
- PKCS#12: $serviceName.p12 (Windows/Chrome)
- DER: $serviceName.der (Some browsers)

## Browser Installation:

### Chrome/Edge (Windows):
1. Double-click $serviceName.p12
2. Select Current User or Local Machine
3. Click Next through the wizard
4. Enter password: (leave blank)
5. Select Place all certificates in the following store
6. Click Browse and select Trusted Root Certification Authorities
7. Click Next and Finish

### Firefox:
1. Open Firefox Settings Privacy and Security
2. Scroll to Certificates and click View Certificates
3. Click Import and select fullchain.pem
4. Check Trust this CA to identify websites
5. Click OK

### Safari (macOS):
1. Double-click fullchain.pem
2. Keychain Access will open
3. Find the certificate and double-click it
4. Expand Trust and set When using this certificate to Always Trust
5. Close and enter password

## Service URL:
https://$Domain$servicePath

## Verification:
After installation, visit the service URL. You should see a green lock icon instead of security warnings.

---
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Domain: $Domain
Service: $serviceDesc
"@
    
    $installPath = "$serviceDir\INSTALL_INSTRUCTIONS.md"
    $installInstructions | Out-File -FilePath $installPath -Encoding UTF8
    
    Write-Host "  ✅ Certificate generated successfully!" -ForegroundColor Green
    Write-Host "     📁 Location: $serviceDir" -ForegroundColor Gray
    Write-Host "     📖 Instructions: $installPath" -ForegroundColor Gray
    Write-Host ""
}

# Create master installation script
$masterScript = @"
# NXCore Certificate Installation Master Script

Write-Host "🔐 NXCore Certificate Installation" -ForegroundColor Cyan
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
    Write-Host "  [`$(`$i + 1)] `$(`$service.Desc) - https://$Domain`$(`$service.Path)" -ForegroundColor White
}

Write-Host ""
Write-Host "To install certificates:" -ForegroundColor Yellow
Write-Host "1. Navigate to the service directory: .\certs\selfsigned\[service-name]\" -ForegroundColor Gray
Write-Host "2. Follow the INSTALL_INSTRUCTIONS.md file" -ForegroundColor Gray
Write-Host "3. Or use the PKCS#12 files (.p12) for Windows browsers" -ForegroundColor Gray
Write-Host ""

Write-Host "Quick Windows Installation:" -ForegroundColor Cyan
Write-Host "Run this command for each service:" -ForegroundColor Gray
Write-Host "certlm.msc" -ForegroundColor White
Write-Host "Then import the .p12 files to 'Trusted Root Certification Authorities'" -ForegroundColor Gray
"@

$masterScriptPath = "$CertDir\INSTALL_ALL_CERTIFICATES.ps1"
$masterScript | Out-File -FilePath $masterScriptPath -Encoding UTF8

# Create summary report
$summaryReport = @"
# NXCore Certificate Generation Summary

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Domain:** $Domain  
**IP:** $IP  

## Generated Certificates:

| Service | Description | URL | Certificate Files |
|---------|-------------|-----|-------------------|
"@

foreach ($service in $Services) {
    $serviceName = $service.Name
    $serviceDesc = $service.Description
    $servicePath = $service.Path
    $summaryReport += "`n| $serviceName | $serviceDesc | https://$Domain$servicePath | $serviceName.p12, fullchain.pem, privkey.pem |"
}

$summaryReport += @"

## Installation Methods:

### Method 1: Individual Service Installation
1. Navigate to `.\certs\selfsigned\[service-name]\`
2. Follow the `INSTALL_INSTRUCTIONS.md` file
3. Use the appropriate certificate format for your browser

### Method 2: Windows Certificate Manager
1. Open certlm.msc (Local Machine) or certmgr.msc (Current User)
2. Navigate to Trusted Root Certification Authorities and Certificates
3. Right-click and select All Tasks and Import
4. Import each .p12 file with blank password

### Method 3: PowerShell Bulk Import
Get-ChildItem ".\certs\selfsigned\*\*.p12" | ForEach-Object {
    Import-Certificate -FilePath `$_.FullName -CertStoreLocation Cert:\LocalMachine\Root
}

## Verification:
After installation, all services should show green lock icons:
https://$Domain/
https://$Domain/grafana/
https://$Domain/prometheus/
https://$Domain/portainer/
https://$Domain/ai/
https://$Domain/files/
https://$Domain/status/
https://$Domain/traefik/
https://$Domain/aerocaller/
https://$Domain/auth/

## Troubleshooting:
* If certificates don't work, try importing the .der files instead
* For Firefox, use the .pem files
* For Safari, use the .pem files
* Clear browser cache after installation
"@

$summaryPath = "$CertDir\CERTIFICATE_SUMMARY.md"
$summaryReport | Out-File -FilePath $summaryPath -Encoding UTF8

Write-Host "🎉 Certificate Generation Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Certificate Directory: $CertDir" -ForegroundColor Cyan
Write-Host "📖 Summary Report: $summaryPath" -ForegroundColor Cyan
Write-Host "🚀 Master Install Script: $masterScriptPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review the certificate files in each service directory" -ForegroundColor Gray
Write-Host "2. Follow installation instructions for your browser" -ForegroundColor Gray
Write-Host "3. Test service functionality after certificate installation" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tip: Start with the Landing Dashboard certificate first!" -ForegroundColor Magenta
