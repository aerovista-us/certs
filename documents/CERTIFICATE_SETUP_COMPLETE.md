# NXCore Certificate Setup Complete

## ✅ What We've Accomplished

### 1. Individual Service Certificates Created
- **10 services** with individual certificate packages
- **Multiple formats** for different browsers and use cases
- **Browser-specific installation guides** for each service

### 2. Certificate Files Generated
Each service directory contains:
- `fullchain.pem` - Main certificate file (use this for browser import)
- `privkey.pem` - Private key
- `combined.pem` - Certificate + private key combined
- `[service].der` - DER format certificate
- `[service].p12` - PKCS#12 format (placeholder with instructions)
- `CHROME_INSTALL.md` - Chrome/Edge specific instructions
- `FIREFOX_INSTALL.md` - Firefox specific instructions
- `INSTALL_INSTRUCTIONS.md` - General installation instructions

### 3. Services with Certificates
| Service | URL | Certificate Location |
|---------|-----|---------------------|
| ✅ Landing Dashboard | https://nxcore.tail79107c.ts.net/ | `.\certs\selfsigned\landing\` |
| ✅ Grafana | https://nxcore.tail79107c.ts.net/grafana/ | `.\certs\selfsigned\grafana\` |
| ✅ Prometheus | https://nxcore.tail79107c.ts.net/prometheus/ | `.\certs\selfsigned\prometheus\` |
| ✅ Portainer | https://nxcore.tail79107c.ts.net/portainer/ | `.\certs\selfsigned\portainer\` |
| ✅ AI Service | https://nxcore.tail79107c.ts.net/ai/ | `.\certs\selfsigned\ai\` |
| ✅ FileBrowser | https://nxcore.tail79107c.ts.net/files/ | `.\certs\selfsigned\files\` |
| ✅ Uptime Kuma | https://nxcore.tail79107c.ts.net/status/ | `.\certs\selfsigned\status\` |
| ✅ Traefik Dashboard | https://nxcore.tail79107c.ts.net/traefik/ | `.\certs\selfsigned\traefik\` |
| ✅ AeroCaller | https://nxcore.tail79107c.ts.net/aerocaller/ | `.\certs\selfsigned\aerocaller\` |
| ✅ Authelia | https://nxcore.tail79107c.ts.net/auth/ | `.\certs\selfsigned\auth\` |

### 4. Installation Tools Created
- `INSTALL_ALL_CERTIFICATES.ps1` - Master installation script
- `TEST_SERVICES.ps1` - Service testing script
- `CERTIFICATE_INSTALLATION_GUIDE.md` - Comprehensive installation guide

## 🚀 Next Steps for Testing

### Step 1: Install Landing Dashboard Certificate
1. Navigate to `.\certs\selfsigned\landing\`
2. Follow the `CHROME_INSTALL.md` or `FIREFOX_INSTALL.md` instructions
3. Test by visiting `https://nxcore.tail79107c.ts.net/`

### Step 2: Verify Certificate Works
- Look for **green lock icon** in browser address bar
- No security warnings should appear
- Services should load without certificate errors

### Step 3: Install Additional Service Certificates
- Install certificates for services you use frequently
- Each service has its own certificate package
- Follow the same installation process

### Step 4: Test Service Functionality
- Use the `TEST_SERVICES.ps1` script to verify all services
- Test actual functionality (not just accessibility)
- Verify login credentials work where applicable

## 🔧 Installation Methods

### Quick Method (Chrome/Edge)
1. Open `certlm.msc`
2. Navigate to **Trusted Root Certification Authorities** → **Certificates**
3. Right-click → **All Tasks** → **Import**
4. Select `fullchain.pem` from the service directory
5. Click **Next** → **Finish**

### Firefox Method
1. Open Firefox → **Settings** → **Privacy & Security**
2. Scroll to **Certificates** → **View Certificates**
3. **Authorities** tab → **Import**
4. Select `fullchain.pem` from the service directory
5. Check **Trust this CA to identify websites** → **OK**

## 📋 Testing Checklist

- [ ] Landing Dashboard certificate installed and working
- [ ] Green lock icon appears in browser
- [ ] No security warnings
- [ ] Services load properly
- [ ] Static assets load correctly (especially for AI service)
- [ ] Login functionality works where applicable
- [ ] All services accessible via path-based routing

## 🎯 Expected Results

After certificate installation:
- **No more security warnings** in browsers
- **Green lock icons** in address bars
- **Full functionality** of all services
- **Proper static asset loading** for SPAs like Open WebUI
- **Working authentication** for services that require it

## 📁 File Structure
```
.\certs\selfsigned\
├── landing\          # Landing Dashboard certificates
├── grafana\          # Grafana certificates
├── prometheus\       # Prometheus certificates
├── portainer\        # Portainer certificates
├── ai\              # AI Service certificates
├── files\           # FileBrowser certificates
├── status\          # Uptime Kuma certificates
├── traefik\         # Traefik Dashboard certificates
├── aerocaller\      # AeroCaller certificates
├── auth\            # Authelia certificates
├── INSTALL_ALL_CERTIFICATES.ps1
├── TEST_SERVICES.ps1
└── CERTIFICATE_SUMMARY.md
```

## 🔍 Troubleshooting

If certificates don't work:
1. **Clear browser cache** and restart
2. **Verify certificate store** - must be in "Trusted Root Certification Authorities"
3. **Check URL** - use `https://nxcore.tail79107c.ts.net/` (not subdomains)
4. **Try different browser** to isolate issues
5. **Import to correct store** - system vs user certificate store

## 📞 Support

- Check `CERTIFICATE_INSTALLATION_GUIDE.md` for detailed instructions
- Each service directory has browser-specific installation guides
- Use the test scripts to verify functionality

---

**Setup Complete**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Ready for Testing**: All certificate packages created and ready for installation  
**Next Action**: Install Landing Dashboard certificate and test functionality
