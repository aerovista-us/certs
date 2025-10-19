# NXCore Multi-PC Certificate Deployment

## Quick Start Guide

### For New PCs

1. **Copy the entire `deployment-package` folder to the new PC**

2. **Run as Administrator:**
   ```powershell
   .\install-openssl-and-setup.ps1
   ```

3. **Generate and deploy certificates:**
   ```powershell
   .\scripts\generate-and-deploy-bundles-fixed.ps1
   ```

### What's Included

- **OpenSSL Installer**: `openssl\Win64OpenSSL_Light-3_6_0.exe`
- **Certificate Scripts**: All PowerShell and Bash scripts
- **Documentation**: Complete installation guides
- **Auto-Installer**: Automated OpenSSL installation

### Prerequisites

- Windows 10/11
- Administrator privileges
- Network access to NXCore server
- SSH access to server (100.115.9.61)

### Server Configuration

The scripts will automatically:
- Generate certificates for all 10 services
- Deploy certificates to `/opt/nexus/traefik/certs/`
- Configure Traefik SSL
- Create client installation packages
- Restart Traefik with new certificates

### Services Covered

| Service | Certificate | Client Package |
|---------|-------------|----------------|
| Landing | ✅ | ✅ |
| Grafana | ✅ | ✅ |
| Prometheus | ✅ | ✅ |
| Portainer | ✅ | ✅ |
| AI Service | ✅ | ✅ |
| FileBrowser | ✅ | ✅ |
| Uptime Kuma | ✅ | ✅ |
| Traefik | ✅ | ✅ |
| AeroCaller | ✅ | ✅ |
| Authelia | ✅ | ✅ |

### Troubleshooting

#### OpenSSL Issues
- Ensure running as Administrator
- Check PATH environment variable
- Verify OpenSSL installation directory

#### Certificate Generation Issues
- Check network connectivity to server
- Verify SSH credentials
- Review server disk space

#### Deployment Issues
- Check Traefik container status
- Review server certificate permissions
- Test SSL connectivity

### Support Files

- **Installation Logs**: Check PowerShell execution logs
- **Server Logs**: `docker logs traefik`
- **Certificate Status**: `ls -la /opt/nexus/traefik/certs/`

---
**Package Version**: 1.0
**Created**: $(Get-Date)
**Status**: Ready for Multi-PC Deployment
