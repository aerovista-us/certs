# Windows Certificate Installation

## EXE Installer (Recommended)

1. Download the `cert-installer.exe` file
2. Right-click and select "Run as Administrator"
3. Follow the installation wizard
4. Accept the license agreement
5. Complete the installation

## Manual Installation

If the EXE installer doesn't work, you can install certificates manually:

1. Download the certificate files
2. Double-click the certificate file
3. Click "Install Certificate"
4. Select "Local Machine" and click Next
5. Choose "Place all certificates in the following store"
6. Click "Browse" and select "Trusted Root Certification Authorities"
7. Complete the installation

## PowerShell Installation

For advanced users, you can install certificates using PowerShell:

```powershell
# Install Root CA Certificate
Import-Certificate -FilePath "AeroVista-RootCA.cer" -CertStoreLocation "Cert:\LocalMachine\Root"

# Install Client Certificate
Import-PfxCertificate -FilePath "User-Gold.p12" -CertStoreLocation "Cert:\LocalMachine\My"
```

## Troubleshooting

- **Access denied**: Run as Administrator
- **Certificate not trusted**: Install the root CA certificate first
- **PowerShell execution policy**: Set execution policy to allow scripts

## Support

For additional help, contact the NXCore support team.
