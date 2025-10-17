# Service Access Guide

**Server:** nxcore.tail79107c.ts.net (100.115.9.61)  
**Last Updated:** October 16, 2025  
**Certificate:** Self-Signed (expires Oct 16, 2026)

---

## ✅ Quick Access

### **Main Landing Page**
🏠 **https://nxcore.tail79107c.ts.net/**

This is your primary dashboard showing all services with live status checks.

---

## 🔐 HTTPS Services

> **Note:** Import the self-signed certificate first to avoid browser warnings!  
> Certificate location: `D:\NeXuS\NXCore-Control\certs\selfsigned\fullchain.pem`

| Service | URL | Status | Notes |
|---------|-----|--------|-------|
| **Landing Page** | https://nxcore.tail79107c.ts.net/ | ✅ Working | Main dashboard |
| **Authelia (SSO)** | https://nxcore.tail79107c.ts.net/auth/ | 🔄 To Configure | Authentication portal |
| **Portainer** | https://nxcore.tail79107c.ts.net/portainer/ | 🔄 To Test | Container management |
| **Grafana** | https://nxcore.tail79107c.ts.net/grafana/ | 🔄 To Deploy | Metrics dashboards |
| **Prometheus** | https://nxcore.tail79107c.ts.net/prometheus/ | 🔄 To Deploy | Metrics collection |
| **FileBrowser** | https://nxcore.tail79107c.ts.net/files/ | 🔄 To Deploy | File management |
| **Uptime Kuma** | https://nxcore.tail79107c.ts.net/status/ | 🔄 To Deploy | Status monitoring |
| **AeroCaller** | https://nxcore.tail79107c.ts.net/aerocaller/ | 🔄 To Deploy | WebRTC calling |
| **n8n** | https://nxcore.tail79107c.ts.net/n8n/ | 🔄 To Deploy | Workflow automation |

---

## 💻 HTTP Services (Direct Access)

**No certificate required - works immediately:**

| Service | URL | Credentials | Status |
|---------|-----|-------------|--------|
| **Code-Server** | http://100.115.9.61:8080/ | `ChangeMe_CodeServerPassword123` | ✅ Working |
| **Jupyter Notebook** | http://100.115.9.61:8888/ | Check logs for token | ✅ Working |
| **RStudio** | http://100.115.9.61:8787/ | Default: rstudio/rstudio | ✅ Working |
| **NoVNC** | http://100.115.9.61:6080/ | VNC password required | ✅ Working |
| **VNC Direct** | http://100.115.9.61:6901/ | VNC password required | ✅ Working |
| **Dashboard** | http://100.115.9.61:8081/ | No auth | ✅ Working |
| **Portainer** | http://100.115.9.61:9444/ | Setup on first visit | ✅ Working |
| **Traefik API** | http://100.115.9.61:8083/api/ | API endpoints | ✅ Working |

---

## 📋 Prerequisites

### 1. **Tailscale DNS Resolution** ✅ COMPLETE

Your Windows PC already has:
- ✓ Tailscale DNS enabled
- ✓ `nxcore.tail79107c.ts.net` resolves to `100.115.9.61`

### 2. **Certificate Import** ⏳ PENDING

**To remove browser security warnings:**

```powershell
# Open certificate file
Start-Process "D:\NeXuS\NXCore-Control\certs\selfsigned\fullchain.pem"
```

**Then:**
1. Click "Install Certificate"
2. Select "Local Machine" → Next (requires admin)
3. Select "Place all certificates in the following store"
4. Browse → "Trusted Root Certification Authorities" → OK
5. Next → Finish → Yes

**Restart your browser** after importing!

---

## 🚀 Deployment Commands

### Deploy Individual Services

```powershell
# From D:\NeXuS\NXCore-Control

# Monitoring stack
.\scripts\ps\deploy-containers.ps1 -Service monitoring

# File services
.\scripts\ps\deploy-containers.ps1 -Service files

# n8n automation
.\scripts\ps\deploy-containers.ps1 -Service n8n

# All services
.\scripts\ps\deploy-containers.ps1 -Service all
```

### Check Service Status

```powershell
# View running containers
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}'"

# Check specific service logs
ssh glyph@100.115.9.61 "sudo docker logs <service-name> --tail 50"

# Check Traefik routing
ssh glyph@100.115.9.61 "sudo docker logs traefik --tail 50"
```

---

## 🔍 Troubleshooting

### Issue: "This site can't be reached"

**Solution:**
1. Verify Tailscale is running on Windows
2. Check DNS resolution: `nslookup nxcore.tail79107c.ts.net`
3. Should return: `100.115.9.61`

### Issue: "Your connection is not private" (ERR_CERT_AUTHORITY_INVALID)

**Solution:**
- Import the self-signed certificate (see step 2 above)
- Restart your browser

### Issue: Service shows 502 Bad Gateway

**Possible causes:**
1. Service not deployed yet
2. Service crashed/unhealthy
3. Incorrect routing configuration

**Check:**
```powershell
# Is the service running?
ssh glyph@100.115.9.61 "sudo docker ps | grep <service-name>"

# Check service logs
ssh glyph@100.115.9.61 "sudo docker logs <service-name>"
```

### Issue: 404 Not Found on HTTPS path

**Possible causes:**
1. Path-based route not configured
2. Middleware stripping prefix incorrectly
3. Service requires specific base URL

**Check:**
- Review `docker/tailnet-routes.yml` for route definition
- Verify service-specific base URL configuration

---

## 🔑 Default Credentials

### Code-Server
- **URL:** http://100.115.9.61:8080/
- **Password:** `ChangeMe_CodeServerPassword123`

### Jupyter Notebook
- **URL:** http://100.115.9.61:8888/
- **Token:** Run `ssh glyph@100.115.9.61 "sudo docker logs jupyter 2>&1 | grep token"`

### RStudio
- **URL:** http://100.115.9.61:8787/
- **Username:** `rstudio`
- **Password:** `rstudio` (or check container env vars)

### Portainer
- **URL:** https://nxcore.tail79107c.ts.net/portainer/ or http://100.115.9.61:9444/
- **Setup:** Create admin account on first visit

### Authelia
- **URL:** https://nxcore.tail79107c.ts.net/auth/
- **Users:** Edit `/opt/nexus/authelia/users_database.yml` on server
- **Default:** See `configs/authelia/users_database.yml` template

---

## 📊 Service Categories

### **Foundation (Currently Running)**
- ✅ Traefik (reverse proxy)
- ✅ PostgreSQL (database)
- ✅ Redis (cache)
- ✅ Authelia (authentication)
- ✅ Landing Page
- ✅ Docker Socket Proxy

### **Development Tools (Currently Running)**
- ✅ Code-Server
- ✅ Jupyter Notebook
- ✅ RStudio
- ✅ VNC Server
- ✅ NoVNC

### **Management (Currently Running)**
- ✅ Portainer
- ✅ Dashboard
- ✅ Autoheal

### **To Deploy**
- 📦 Grafana (monitoring)
- 📦 Prometheus (metrics)
- 📦 Uptime Kuma (status)
- 📦 FileBrowser (files)
- 📦 n8n (automation)
- 📦 Dozzle (logs)
- 📦 AeroCaller (calling)
- 📦 Open WebUI (AI)
- 📦 Ollama (LLM)

---

## 🛠️ Quick Commands

```powershell
# Test HTTPS (skip cert verification)
curl.exe -k https://nxcore.tail79107c.ts.net/

# Test specific service
curl.exe -k https://nxcore.tail79107c.ts.net/portainer/

# Check all running services
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}'"

# Restart a service
ssh glyph@100.115.9.61 "sudo docker restart <service-name>"

# View Traefik routes
ssh glyph@100.115.9.61 "curl -s http://localhost:8083/api/http/routers | jq"

# Regenerate certificates (yearly)
.\scripts\ps\generate-selfsigned-certs.ps1
.\scripts\ps\deploy-selfsigned-certs.ps1
```

---

## 📚 Related Documentation

- **Certificate Setup:** [SELFSIGNED_CERTIFICATES.md](SELFSIGNED_CERTIFICATES.md)
- **Deployment Summary:** [SELFSIGNED_CERT_DEPLOYMENT_SUMMARY.md](SELFSIGNED_CERT_DEPLOYMENT_SUMMARY.md)
- **Project Map:** [PROJECT_MAP.md](../PROJECT_MAP.md)
- **Deployment Checklist:** [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

---

## ✅ Next Steps

1. **Import certificate to browser** (instructions above)
2. **Restart browser** to trust the certificate
3. **Access landing page:** https://nxcore.tail79107c.ts.net/
4. **Deploy additional services** as needed
5. **Configure Authelia** for SSO protection
6. **Set up monitoring stack** (Grafana/Prometheus)

---

**Need Help?**  
Check logs: `ssh glyph@100.115.9.61 "sudo docker logs <service-name>"`  
View all services: `ssh glyph@100.115.9.61 "sudo docker ps"`  
Review documentation: `D:\NeXuS\NXCore-Control\docs\`

