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
