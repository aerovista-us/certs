# NXCore Certificate Installation Guide

## Overview
This guide will help you install self-signed certificates for all NXCore services to eliminate browser security warnings and enable full functionality.

## Quick Start
1. **Start with Landing Dashboard**: Navigate to `.\certs\selfsigned\landing\`
2. **Choose your browser**: Follow the appropriate installation method below
3. **Test**: Visit `https://nxcore.tail79107c.ts.net/` to verify the certificate works
4. **Repeat**: Install certificates for other services as needed

## Available Services
| Service | URL | Certificate Location |
|---------|-----|---------------------|
| Landing Dashboard | https://nxcore.tail79107c.ts.net/ | `.\certs\selfsigned\landing\` |
| Grafana | https://nxcore.tail79107c.ts.net/grafana/ | `.\certs\selfsigned\grafana\` |
| Prometheus | https://nxcore.tail79107c.ts.net/prometheus/ | `.\certs\selfsigned\prometheus\` |
| Portainer | https://nxcore.tail79107c.ts.net/portainer/ | `.\certs\selfsigned\portainer\` |
| AI Service | https://nxcore.tail79107c.ts.net/ai/ | `.\certs\selfsigned\ai\` |
| FileBrowser | https://nxcore.tail79107c.ts.net/files/ | `.\certs\selfsigned\files\` |
| Uptime Kuma | https://nxcore.tail79107c.ts.net/status/ | `.\certs\selfsigned\status\` |
| Traefik Dashboard | https://nxcore.tail79107c.ts.net/traefik/ | `.\certs\selfsigned\traefik\` |
| AeroCaller | https://nxcore.tail79107c.ts.net/aerocaller/ | `.\certs\selfsigned\aerocaller\` |
| Authelia | https://nxcore.tail79107c.ts.net/auth/ | `.\certs\selfsigned\auth\` |

## Installation Methods

### Method 1: Chrome/Edge (Windows) - Recommended

#### Option A: Certificate Manager (Easiest)
1. Open `certlm.msc` (Local Machine) or `certmgr.msc` (Current User)
2. Navigate to **Trusted Root Certification Authorities** → **Certificates**
3. Right-click → **All Tasks** → **Import**
4. Browse to the service directory (e.g., `.\certs\selfsigned\landing\`)
5. Select `fullchain.pem`
6. Click **Next** → **Finish**

#### Option B: Browser Settings
1. Open Chrome/Edge
2. Go to **Settings** → **Privacy and Security** → **Security**
3. Click **Manage certificates**
4. Go to **Trusted Root Certification Authorities** tab
5. Click **Import**
6. Select the `fullchain.pem` file from the service directory
7. Check **Place all certificates in the following store**
8. Select **Trusted Root Certification Authorities**
9. Click **Next** and **Finish**

### Method 2: Firefox

1. Open Firefox
2. Go to **Settings** → **Privacy & Security**
3. Scroll to **Certificates** section
4. Click **View Certificates**
5. Go to **Authorities** tab
6. Click **Import**
7. Select the `fullchain.pem` file from the service directory
8. Check **Trust this CA to identify websites**
9. Click **OK**

### Method 3: Safari (macOS)

1. Double-click the `fullchain.pem` file
2. Keychain Access will open
3. Find the certificate and double-click it
4. Expand **Trust** section
5. Set **When using this certificate** to **Always Trust**
6. Close and enter your password

### Method 4: PowerShell Bulk Import (Advanced)

```powershell
# Import all certificates at once
Get-ChildItem ".\certs\selfsigned\*\fullchain.pem" | ForEach-Object {
    Import-Certificate -FilePath $_.FullName -CertStoreLocation Cert:\LocalMachine\Root
}
```

## Testing Certificate Installation

### Quick Test
1. Open your browser
2. Navigate to `https://nxcore.tail79107c.ts.net/`
3. Look for a **green lock icon** in the address bar
4. If you see the lock, the certificate is working!

### Comprehensive Test
Run the test script:
```powershell
powershell -ExecutionPolicy Bypass -File .\certs\selfsigned\TEST_SERVICES.ps1
```

## Troubleshooting

### Certificate Not Working
1. **Clear browser cache** and restart the browser
2. **Try a different browser** to isolate the issue
3. **Check certificate store**: Ensure the certificate is in "Trusted Root Certification Authorities"
4. **Verify file format**: Make sure you're using `fullchain.pem` (not `privkey.pem`)

### Still Getting Security Warnings
1. **Check the URL**: Make sure you're using `https://nxcore.tail79107c.ts.net/` (not a subdomain)
2. **Import to correct store**: Certificate must be in "Trusted Root Certification Authorities"
3. **Restart browser**: Some browsers require a restart after certificate import

### Browser-Specific Issues

#### Chrome/Edge
- Use `certlm.msc` for system-wide installation
- Use `certmgr.msc` for user-only installation
- Make sure to import to "Trusted Root Certification Authorities"

#### Firefox
- Firefox has its own certificate store
- Must import through Firefox settings, not Windows certificate manager
- Use the "Authorities" tab, not "Your Certificates"

#### Safari
- Uses macOS Keychain
- Must set trust level to "Always Trust"
- May require admin password

## Certificate Files Explained

Each service directory contains:
- `fullchain.pem` - The certificate file (use this for import)
- `privkey.pem` - Private key (not needed for browser import)
- `combined.pem` - Certificate + private key combined
- `[service].der` - DER format certificate
- `[service].p12` - PKCS#12 format (placeholder)
- `CHROME_INSTALL.md` - Chrome/Edge specific instructions
- `FIREFOX_INSTALL.md` - Firefox specific instructions
- `INSTALL_INSTRUCTIONS.md` - General installation instructions

## Security Notes

- These are **self-signed certificates** for internal use only
- They provide **encryption** but not **identity verification**
- **Do not use** these certificates for public-facing services
- The certificates are valid for **1 year** from generation date

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify the certificate is in the correct store
3. Try importing to a different certificate store
4. Test with a different browser
5. Clear browser cache and restart

## Next Steps

After installing certificates:
1. **Test all services** to ensure they work properly
2. **Bookmark the services** you use frequently
3. **Set up monitoring** to track service availability
4. **Configure authentication** for services that require it

---

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Domain**: nxcore.tail79107c.ts.net  
**Services**: 10 services with individual certificates
