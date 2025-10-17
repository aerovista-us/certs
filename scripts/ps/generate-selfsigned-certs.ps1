# Generate Self-Signed Certificates for NXCore
# This script creates self-signed certificates for all NXCore services

param(
    [string]$Domain = "nxcore.tail79107c.ts.net",
    [string]$IP = "100.115.9.61",
    [string]$OutputDir = ".\certs\selfsigned",
    [int]$ValidDays = 365
)

# Create output directory
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "🔐 Generating Self-Signed Certificates" -ForegroundColor Cyan
Write-Host "Domain: $Domain" -ForegroundColor Yellow
Write-Host "IP: $IP" -ForegroundColor Yellow
Write-Host "Valid for: $ValidDays days" -ForegroundColor Yellow
Write-Host ""

# Define Subject Alternative Names (SANs)
$sans = @(
    "DNS:$Domain",
    "DNS:*.$Domain",  # Wildcard for subdomains
    "IP:$IP",
    "IP:127.0.0.1",
    "IP:100.115.9.61"
)

# Create certificate request configuration
$certConfig = @"
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
IP.3 = 100.115.9.61
"@

$configFile = Join-Path $OutputDir "cert.conf"
$certConfig | Out-File -FilePath $configFile -Encoding ASCII

# Check if OpenSSL is available
$opensslPath = $null
$opensslLocations = @(
    "C:\Program Files\Git\usr\bin\openssl.exe",
    "C:\Program Files\OpenSSL\bin\openssl.exe",
    "C:\OpenSSL\bin\openssl.exe",
    "openssl.exe"
)

foreach ($loc in $opensslLocations) {
    if (Get-Command $loc -ErrorAction SilentlyContinue) {
        $opensslPath = $loc
        break
    }
}

if (-not $opensslPath) {
    Write-Host "❌ OpenSSL not found. Installing via Chocolatey..." -ForegroundColor Red
    
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    Write-Host "Installing OpenSSL..." -ForegroundColor Yellow
    choco install openssl -y
    
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Try to find OpenSSL again
    foreach ($loc in $opensslLocations) {
        if (Get-Command $loc -ErrorAction SilentlyContinue) {
            $opensslPath = $loc
            break
        }
    }
}

if (-not $opensslPath) {
    Write-Host "❌ Could not install OpenSSL. Please install it manually." -ForegroundColor Red
    Write-Host "Download from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Using OpenSSL: $opensslPath" -ForegroundColor Green

# Generate private key
$keyFile = Join-Path $OutputDir "privkey.pem"
Write-Host "🔑 Generating private key..." -ForegroundColor Cyan
& $opensslPath genrsa -out $keyFile 2048 2>$null

# Generate certificate
$certFile = Join-Path $OutputDir "fullchain.pem"
Write-Host "📜 Generating certificate..." -ForegroundColor Cyan
& $opensslPath req -new -x509 -key $keyFile -out $certFile -days $ValidDays -config $configFile 2>$null

# Verify the certificate
Write-Host ""
Write-Host "✅ Certificate generated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Certificate Details:" -ForegroundColor Cyan
& $opensslPath x509 -in $certFile -text -noout | Select-String -Pattern "Subject:|Issuer:|Not Before|Not After|DNS:|IP Address:" -Context 0,0

Write-Host ""
Write-Host "📁 Certificate files created:" -ForegroundColor Cyan
Write-Host "  Private Key: $keyFile" -ForegroundColor Yellow
Write-Host "  Certificate: $certFile" -ForegroundColor Yellow
Write-Host "  Config: $configFile" -ForegroundColor Yellow

# Create combined PEM file (some applications need this)
$combinedFile = Join-Path $OutputDir "combined.pem"
Get-Content $certFile, $keyFile | Set-Content $combinedFile
Write-Host "  Combined: $combinedFile" -ForegroundColor Yellow

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Deploy certificates to NXCore server:" -ForegroundColor White
Write-Host "   .\scripts\ps\deploy-selfsigned-certs.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Import certificate to your browser/system:" -ForegroundColor White
Write-Host "   - Windows: Double-click $certFile and install to 'Trusted Root Certification Authorities'" -ForegroundColor Yellow
Write-Host "   - Chrome: Settings > Privacy and security > Security > Manage certificates" -ForegroundColor Yellow
Write-Host "   - Firefox: Settings > Privacy & Security > Certificates > View Certificates > Import" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Self-signed certificates will show security warnings until imported!" -ForegroundColor Yellow

