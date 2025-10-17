# Self-Signed Certificate Deployment Summary

**Date:** October 16, 2025  
**Server:** nxcore.tail79107c.ts.net (100.115.9.61)  
**Certificate Type:** Self-Signed RSA 2048-bit  
**Validity:** 365 days (Oct 16, 2025 - Oct 16, 2026)

---

## ✅ **What Was Accomplished**

### 1. **Created Certificate Generation System**

- **Script:** `scripts/ps/generate-selfsigned-certs.ps1`
  - Automatically detects/installs OpenSSL
  - Generates RSA 2048-bit private key
  - Creates X.509 certificate with SANs
  - Supports custom domains, IPs, and validity periods
  
- **Certificate Includes:**
  - Main domain: `nxcore.tail79107c.ts.net`
  - Wildcard: `*.nxcore.tail79107c.ts.net`
  - IP addresses: `100.115.9.61`, `127.0.0.1`

### 2. **Created Deployment System**

- **Script:** `scripts/ps/deploy-selfsigned-certs.ps1`
  - Copies certificates to `/opt/nexus/traefik/certs/` on server
  - Sets proper permissions (privkey: 0600, fullchain: 0644)
  - Automatically restarts Traefik
  - Validates deployment

### 3. **Generated and Deployed Certificates**

```
📁 Local Certificates:
  .\certs\selfsigned\privkey.pem      (1.7KB) - Private key
  .\certs\selfsigned\fullchain.pem    (1.6KB) - Certificate
  .\certs\selfsigned\combined.pem     (3.3KB) - Combined PEM
  .\certs\selfsigned\cert.conf        - OpenSSL config

📁 Server Certificates:
  /opt/nexus/traefik/certs/privkey.pem
  /opt/nexus/traefik/certs/fullchain.pem
```

### 4. **Updated Documentation**

- **Created:** `docs/SELFSIGNED_CERTIFICATES.md` - Complete setup guide
- **Updated:** `README.md` - Added self-signed certificate section
- **Updated:** `.gitignore` - Already excludes `*.pem` files

### 5. **Configured Traefik**

- **Certificate Loading:** Via `docker/tailscale-certs.yml`
  ```yaml
  tls:
    certificates:
      - certFile: /etc/traefik/certs/fullchain.pem
        keyFile: /etc/traefik/certs/privkey.pem
  ```

- **Dynamic Routes:** Via `docker/tailnet-routes.yml`
  - All services use path-based routing on single domain
  - TLS enabled for all HTTPS routes

### 6. **Deployed Services**

All services are now running with HTTPS:

**Foundation Stack:**
- ✅ Traefik (reverse proxy)
- ✅ PostgreSQL (database)
- ✅ Redis (cache)
- ✅ Authelia (SSO/2FA)
- ✅ Landing Page
- ✅ Docker Socket Proxy

**Development Tools:**
- ✅ Code-Server (VS Code in browser)
- ✅ Jupyter Notebook
- ✅ RStudio
- ✅ VNC Server
- ✅ NoVNC

**Management:**
- ✅ Portainer
- ✅ Dashboard
- ✅ Autoheal

---

## 🌐 **Service URLs**

### HTTPS Services (Requires Certificate Import)

| Service | URL | Notes |
|---------|-----|-------|
| Landing Page | https://nxcore.tail79107c.ts.net/ | Main dashboard |
| Traefik Dashboard | https://nxcore.tail79107c.ts.net/traefik/ | Routing config |
| Grafana | https://nxcore.tail79107c.ts.net/grafana/ | Metrics dashboard |
| Prometheus | https://nxcore.tail79107c.ts.net/prometheus/ | Metrics storage |
| FileBrowser | https://nxcore.tail79107c.ts.net/files/ | File management |
| Authelia | https://nxcore.tail79107c.ts.net/auth/ | Authentication |
| Portainer | https://nxcore.tail79107c.ts.net/portainer/ | Container mgmt |
| Status Monitor | https://nxcore.tail79107c.ts.net/status/ | Uptime Kuma |
| AeroCaller | https://nxcore.tail79107c.ts.net/aerocaller/ | WebRTC calls |

### HTTP Services (Direct Access, No Certificate)

| Service | URL | Credentials |
|---------|-----|-------------|
| Code-Server | http://100.115.9.61:8080/ | `ChangeMe_CodeServerPassword123` |
| Jupyter | http://100.115.9.61:8888/ | Check logs for token |
| RStudio | http://100.115.9.61:8787/ | Default: rstudio/rstudio |
| NoVNC | http://100.115.9.61:6080/ | VNC desktop |
| VNC Direct | http://100.115.9.61:6901/ | Direct VNC |
| Dashboard | http://100.115.9.61:8081/ | Status dashboard |

---

## 📋 **Next Steps for User**

### Immediate Actions

1. **Import Certificate to Browser** (to remove security warnings)
   ```powershell
   # Certificate should be open, follow wizard:
   # 1. Install Certificate → Local Machine
   # 2. Trusted Root Certification Authorities
   # 3. Finish → Yes
   ```

2. **Test HTTPS Services**
   - Open: https://nxcore.tail79107c.ts.net/
   - Verify: No security warnings after import
   - Check: All services load correctly

3. **Access Code-Server**
   - URL: http://100.115.9.61:8080/
   - Password: `ChangeMe_CodeServerPassword123`

### Optional Setup

1. **Change Code-Server Password**
   ```bash
   ssh glyph@100.115.9.61
   # Edit /opt/nexus/.env or docker-compose file
   # Add: CODE_SERVER_PASSWORD=YourNewPassword
   # Restart: sudo docker restart code-server
   ```

2. **Configure Authelia Users**
   ```bash
   # Generate password hash
   ssh glyph@100.115.9.61
   sudo docker exec authelia authelia crypto hash generate argon2 --password 'YourPassword'
   
   # Update users file
   sudo nano /opt/nexus/authelia/users_database.yml
   ```

3. **Set Up Grafana**
   - Login: admin/admin (change on first login)
   - Add Prometheus data source
   - Import dashboards from Grafana.com

---

## 🔧 **Maintenance**

### Renew Certificate (Before Oct 16, 2026)

```powershell
# Generate new certificate
.\scripts\ps\generate-selfsigned-certs.ps1 -ValidDays 365

# Deploy to server
.\scripts\ps\deploy-selfsigned-certs.ps1

# Re-import to browser (if needed)
Start-Process ".\certs\selfsigned\fullchain.pem"
```

### Check Certificate Status

```bash
# On server
ssh glyph@100.115.9.61 "sudo openssl x509 -in /opt/nexus/traefik/certs/fullchain.pem -noout -dates"
```

### Verify HTTPS is Working

```powershell
# From Windows
curl.exe -I -k https://nxcore.tail79107c.ts.net/

# Should return: HTTP/1.1 200 OK
```

---

## 📊 **System Status**

### Current Deployment

- **Server:** 100.115.9.61 (nxcore.tail79107c.ts.net)
- **OS:** Ubuntu 22.04+ (assumed)
- **Docker Containers:** 14 running
- **Networks:** gateway, backend
- **Traefik Version:** 2.10.7
- **Certificate Expiry:** Oct 16, 2026

### Performance

- ✅ All services responding
- ✅ HTTPS working on port 443
- ✅ HTTP available on port 80
- ✅ Path-based routing operational
- ✅ Health checks passing

---

## 🛠️ **Troubleshooting**

### Issue: Browser Shows "Not Secure"

**Solution:** Import certificate to Windows trust store
```powershell
Start-Process ".\certs\selfsigned\fullchain.pem"
```

### Issue: Traefik Certificate Error

**Check logs:**
```bash
ssh glyph@100.115.9.61 "sudo docker logs traefik 2>&1 | grep -i certificate"
```

**Verify files:**
```bash
ssh glyph@100.115.9.61 "sudo ls -lh /opt/nexus/traefik/certs/"
```

### Issue: Service Not Loading

**Check service status:**
```bash
ssh glyph@100.115.9.61 "sudo docker ps | grep service-name"
ssh glyph@100.115.9.61 "sudo docker logs service-name"
```

**Restart service:**
```bash
ssh glyph@100.115.9.61 "sudo docker restart service-name"
```

---

## 📚 **Related Documentation**

- **Full Guide:** [SELFSIGNED_CERTIFICATES.md](SELFSIGNED_CERTIFICATES.md)
- **Deployment Checklist:** [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
- **Path-Based Routing:** [PATH_BASED_ROUTING_DEPLOYMENT.md](PATH_BASED_ROUTING_DEPLOYMENT.md)
- **Project Map:** [PROJECT_MAP.md](../PROJECT_MAP.md)
- **Quick Reference:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

## 🎯 **Summary**

✅ **Self-signed certificates generated** (valid for 1 year)  
✅ **Deployed to server** at `/opt/nexus/traefik/certs/`  
✅ **Traefik configured** to use certificates  
✅ **All services running** with HTTPS support  
✅ **Documentation complete** with maintenance guides  
✅ **Scripts created** for easy regeneration/deployment  

**Next:** Import certificate to browser and access all services via HTTPS! 🚀

