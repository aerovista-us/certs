# NXCore Service Status

**Last Updated:** October 16, 2025, 14:25 UTC

---

## ✅ **Working Services**

### **HTTPS (Path-Based Routing)**

| Service | URL | Status | Notes |
|---------|-----|--------|-------|
| **Landing Page** | https://nxcore.tail79107c.ts.net/ | ✅ Working | Main dashboard |
| **Grafana** | https://nxcore.tail79107c.ts.net/grafana/ | ✅ Working | Redirects to /grafana/login |
| **Prometheus** | https://nxcore.tail79107c.ts.net/prometheus/ | ✅ Working | Metrics (doesn't support HEAD) |
| **Uptime Kuma** | https://nxcore.tail79107c.ts.net/status/ | ✅ Working | Redirects to /dashboard |
| **FileBrowser** | https://nxcore.tail79107c.ts.net/files/ | ⚠️ 404 | Routing works, needs config |
| **AeroCaller** | https://nxcore.tail79107c.ts.net/aerocaller/ | ⚠️ 502 | Routing works, unhealthy |

### **HTTP (Direct Access)**

| Service | URL | Credentials | Status |
|---------|-----|-------------|--------|
| **Code-Server** | http://100.115.9.61:8080/ | `ChangeMe_CodeServerPassword123` | ✅ Working |
| **Jupyter** | http://100.115.9.61:8888/ | Token in logs | ✅ Working |
| **RStudio** | http://100.115.9.61:8787/ | rstudio/rstudio | ✅ Working |
| **Dashboard** | http://100.115.9.61:8081/ | None | ✅ Working |
| **Portainer** | http://100.115.9.61:9444/ | Setup on first visit | ✅ Working |
| **Grafana Direct** | http://100.115.9.61:3000/ | admin/admin | ✅ Working |
| **Uptime Kuma Direct** | http://100.115.9.61:3001/ | Setup on first visit | ✅ Working |

---

## 🔧 **Services Needing Attention**

### **FileBrowser (404)**

**Issue:** Returns 404 Not Found

**Possible Causes:**
- Needs database/config initialization
- Missing default user
- Incorrect root path configuration

**Fix:**
```bash
ssh glyph@100.115.9.61 "sudo docker logs filebrowser"
# Check for initialization errors
```

### **AeroCaller (502 Bad Gateway / Unhealthy)**

**Issue:** Container marked as unhealthy, returns 502

**Current Status:**
- Listening on https://0.0.0.0:4443
- Base path: '/'  
- Needs: Base path '/aerocaller'

**Fix:** Update AeroCaller configuration to handle `/aerocaller` base path

---

## 📊 **Container Status**

```
aerocaller      Up 8 minutes (unhealthy)
filebrowser     Up 9 minutes (healthy)
uptime-kuma     Up 9 minutes (healthy)
grafana         Up 9 minutes (healthy)
prometheus      Up 2 minutes (healthy)
landing         Up 2 minutes (healthy)
```

---

## 🎯 **Routing Configuration**

### **File-Based Routes (tailnet-routes.yml)**
- ✅ Priority: 100 (higher than Docker labels)
- ✅ TLS enabled for all routes
- ✅ Path stripping configured
- ✅ Services properly mapped

### **Docker Labels**
- ✅ Landing page: Priority 1 (fallback)
- ✅ Other services use file-based routing

---

## 🚀 **Access URLs**

### **Working Now:**
```
✅ https://nxcore.tail79107c.ts.net/          → Landing Page
✅ https://nxcore.tail79107c.ts.net/grafana/  → Grafana
✅ https://nxcore.tail79107c.ts.net/prometheus/ → Prometheus  
✅ https://nxcore.tail79107c.ts.net/status/   → Uptime Kuma
```

### **Need Configuration:**
```
⚠️  https://nxcore.tail79107c.ts.net/files/      → FileBrowser (404)
⚠️  https://nxcore.tail79107c.ts.net/aerocaller/ → AeroCaller (502)
```

---

## 📝 **Next Steps**

### **1. Fix FileBrowser**
```bash
# Check logs
ssh glyph@100.115.9.61 "sudo docker logs filebrowser"

# May need to initialize database
ssh glyph@100.115.9.61 "sudo docker exec filebrowser filebrowser config init"
```

### **2. Fix AeroCaller Base Path**
- Update `app.staff.js` to handle `/aerocaller` base path
- Or update `server.staff.js` to serve at subpath
- Redeploy container

### **3. Configure Default Credentials**
- **Grafana:** http://100.115.9.61:3000/ (admin/admin)
- **Uptime Kuma:** http://100.115.9.61:3001/ (setup on first visit)
- **FileBrowser:** Will need initial setup once working

---

## ✅ **Major Achievements**

1. ✅ Self-signed certificates deployed and working
2. ✅ Path-based routing operational
3. ✅ Route priorities fixed (specific paths > landing page)
4. ✅ Grafana, Prometheus, Uptime Kuma accessible via HTTPS
5. ✅ All foundation services running
6. ✅ Container names corrected in routing config
7. ✅ Prometheus permission issues resolved

---

## 🔍 **Troubleshooting Commands**

### **Check Service Status**
```bash
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

### **View Service Logs**
```bash
ssh glyph@100.115.9.61 "sudo docker logs <service-name> --tail 50"
```

### **Check Traefik Routes**
```bash
ssh glyph@100.115.9.61 "curl -s http://localhost:8083/api/http/routers | jq"
```

### **Test HTTPS**
```powershell
curl.exe -k https://nxcore.tail79107c.ts.net/<path>/
```

---

## 📚 **Related Documentation**

- [SETUP_COMPLETE.md](SETUP_COMPLETE.md) - Setup guide
- [QUICK_ACCESS.md](QUICK_ACCESS.md) - Quick reference
- [SERVICE_ACCESS_GUIDE.md](docs/SERVICE_ACCESS_GUIDE.md) - Detailed guide
- [SELFSIGNED_CERTIFICATES.md](docs/SELFSIGNED_CERTIFICATES.md) - Certificate guide

---

**Summary:** 4/6 path-based routes working, 2 need configuration fixes. Core infrastructure operational!

