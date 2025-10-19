<# 
Install the AeroVista Root CA into Windows LocalMachine Root store.
Use during imaging or via GPO/Intune.
#>

param(
  [string]$CertPath = "C:\AeroVista\certs\av-root-ca.crt"
)

Write-Host "[i] Installing Root CA from $CertPath"
if (!(Test-Path $CertPath)) {
  Write-Error "Certificate file not found: $CertPath"
  exit 1
}

# Install to Trusted Root Certification Authorities (Local Machine)
Import-Certificate -FilePath $CertPath -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Write-Host "[✓] Installed Root CA into LocalMachine\Root"

# Optional: If you distribute an intermediate, you can add it as well:
# Import-Certificate -FilePath "C:\AeroVista\certs\av-int-ca.crt" -CertStoreLocation Cert:\LocalMachine\CA | Out-Null
# Write-Host "[✓] Installed Intermediate CA into LocalMachine\CA"

# Firefox note: recommend setting security.enterprise_roots.enabled = true via policy.
