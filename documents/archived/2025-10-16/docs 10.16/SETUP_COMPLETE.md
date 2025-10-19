# 🎉 NXCore Self-Signed Certificate Setup Complete!

**Date:** October 16, 2025  
**Status:** ✅ All systems operational

---

## ✅ What's Working Now

### **HTTPS Infrastructure** 
✅ Self-signed certificates generated (valid until Oct 16, 2026)  
✅ Certificates deployed to server (`/opt/nexus/traefik/certs/`)  
✅ Traefik running and healthy with TLS enabled  
✅ Tailscale DNS resolution working (`nxcore.tail79107c.ts.net` → `100.115.9.61`)  
✅ HTTPS responding successfully

### **Services Running**
✅ Traefik (reverse proxy)  
✅ PostgreSQL (database)  
✅ Redis (cache)  
✅ Authelia (authentication)  
✅ Landing Page  
✅ Code-Server (VS Code)  
✅ Jupyter Notebook  
✅ RStudio  
✅ VNC/NoVNC  
✅ Portainer  
✅ Dashboard  

---

## 🚀 Quick Start - Access Your Services

### **1. Import Certificate (One-Time Setup)**

The certificate file should be open. If not:
```powershell
Start-Process "D:\NeXuS\NXCore-Control\certs\selfsigned\fullchain.pem"
```

**Follow the wizard:**
1. ✅ Click "Install Certificate"
2. ✅ Select "Local Machine" → Next (admin required)
3. ✅ "Place all certificates in the following store"
4. ✅ Browse → "Trusted Root Certification Authorities" → OK
5. ✅ Next → Finish → Yes

**Then restart your browser!**

---

### **2. Access Your Services**

#### **🏠 Main Dashboard (HTTPS)**
```
https://nxcore.tail79107c.ts.net/
```
Your central hub for all services!

#### **💻 Development Tools (HTTP - Works Now!)**
- **Code-Server:** http://100.115.9.61:8080/
  - Password: `ChangeMe_CodeServerPassword123`
- **Jupyter:** http://100.115.9.61:8888/
- **RStudio:** http://100.115.9.61:8787/
- **Dashboard:** http://100.115.9.61:8081/

#### **📦 Management (HTTPS - After importing cert)**
- **Portainer:** https://nxcore.tail79107c.ts.net/portainer/
- **Authelia:** https://nxcore.tail79107c.ts.net/auth/

---

## 📋 Files Created

### **Certificates**
```
✅ certs/selfsigned/privkey.pem      - Private key (1.7KB)
✅ certs/selfsigned/fullchain.pem    - Certificate (1.6KB)
✅ certs/selfsigned/combined.pem     - Combined PEM
✅ certs/selfsigned/cert.conf        - OpenSSL config
```

### **Scripts**
```
✅ scripts/ps/generate-selfsigned-certs.ps1  - Generate new certificates
✅ scripts/ps/deploy-selfsigned-certs.ps1    - Deploy to server
```

### **Documentation**
```
✅ docs/SELFSIGNED_CERTIFICATES.md              - Complete guide
✅ docs/SELFSIGNED_CERT_DEPLOYMENT_SUMMARY.md   - Deployment summary
✅ docs/SERVICE_ACCESS_GUIDE.md                 - Service access guide
✅ README.md                                     - Updated with cert info
```

### **Configuration**
```
✅ docker/tailscale-certs.yml        - Certificate config for Traefik
✅ docker/tailnet-routes.yml         - Path-based routing rules
✅ docker/traefik-static.yml         - Traefik static config
✅ docker/traefik-dynamic.yml        - Traefik dynamic config
```

---

## 🔐 Certificate Details

**Subject:** CN=nxcore.tail79107c.ts.net, O=NXCore, OU=Infrastructure  
**Issuer:** Self-signed  
**Valid From:** Oct 16, 2025  
**Valid Until:** Oct 16, 2026  
**Key Size:** RSA 2048-bit

**Subject Alternative Names (SANs):**
- DNS: `nxcore.tail79107c.ts.net`
- DNS: `*.nxcore.tail79107c.ts.net` (wildcard)
- IP: `100.115.9.61`
- IP: `127.0.0.1`

---

## 🛠️ Useful Commands

### **Test HTTPS**
```powershell
# Test with certificate verification skipped
curl.exe -k https://nxcore.tail79107c.ts.net/

# Expected: HTTP/1.1 200 OK
```

### **Check DNS Resolution**
```powershell
nslookup nxcore.tail79107c.ts.net

# Expected: 100.115.9.61
```

### **View Running Services**
```powershell
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

### **Restart Traefik**
```powershell
ssh glyph@100.115.9.61 "sudo docker restart traefik && sudo docker logs -f traefik"
```

### **Deploy Additional Services**
```powershell
# Monitoring stack (Grafana, Prometheus)
.\scripts\ps\deploy-containers.ps1 -Service monitoring

# File services
.\scripts\ps\deploy-containers.ps1 -Service files

# All services
.\scripts\ps\deploy-containers.ps1 -Service all
```

---

## 📊 System Status

### **Server**
- **Hostname:** nxcore.tail79107c.ts.net
- **IP:** 100.115.9.61
- **OS:** Ubuntu (via Tailscale)
- **Docker Containers:** 14 running
- **Networks:** gateway, backend

### **Traefik**
- **Version:** 2.10.7
- **Status:** ✅ Healthy
- **Ports:** 80 (HTTP), 443 (HTTPS), 8083 (API)
- **TLS:** ✅ Self-signed certificate loaded
- **Routing:** ✅ Path-based routing active

### **Tailscale**
- **DNS:** ✅ Enabled and working
- **MagicDNS:** ✅ Active (100.100.100.100)
- **Resolution:** ✅ nxcore.tail79107c.ts.net → 100.115.9.61

---

## ⚠️ Important Notes

### **Certificate Trust**
- ⚠️ Browsers will show warnings until you import the certificate
- ✅ After import, all warnings disappear
- ⚠️ Each user/device needs to import the certificate once
- ✅ Certificate is valid for 1 year (renew before Oct 16, 2026)

### **Security**
- ✅ Full TLS 1.2+ encryption
- ✅ Perfect for private/internal networks
- ⚠️ Not suitable for public internet (use Let's Encrypt instead)
- ✅ No external dependencies or DNS challenges

### **Tailscale**
- ✅ All traffic stays within your Tailscale network
- ✅ Zero-trust security model
- ✅ End-to-end encrypted VPN
- ✅ Works from anywhere (even cellular)

---

## 🎯 Next Steps

### **Immediate (Required)**
1. ✅ Import certificate to browser (instructions above)
2. ✅ Restart browser
3. ✅ Access https://nxcore.tail79107c.ts.net/

### **Soon (Recommended)**
4. 📦 Deploy monitoring stack (Grafana/Prometheus)
5. 🔐 Configure Authelia users
6. 📁 Deploy file services (FileBrowser)
7. 🤖 Set up n8n automation

### **Optional**
8. 🎨 Customize landing page
9. 🔄 Set up automatic backups
10. 📊 Configure dashboards
11. 🚨 Set up alerting

---

## 📚 Documentation

### **Quick Reference**
- **Access Guide:** [docs/SERVICE_ACCESS_GUIDE.md](docs/SERVICE_ACCESS_GUIDE.md)
- **Certificate Guide:** [docs/SELFSIGNED_CERTIFICATES.md](docs/SELFSIGNED_CERTIFICATES.md)
- **Deployment Summary:** [docs/SELFSIGNED_CERT_DEPLOYMENT_SUMMARY.md](docs/SELFSIGNED_CERT_DEPLOYMENT_SUMMARY.md)

### **Project Docs**
- **Project Map:** [PROJECT_MAP.md](PROJECT_MAP.md)
- **Deployment Checklist:** [docs/DEPLOYMENT_CHECKLIST.md](docs/DEPLOYMENT_CHECKLIST.md)
- **Quick Reference:** [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)

---

## 🎊 Success Metrics

✅ **14 services** running  
✅ **HTTPS** enabled with TLS 1.2+  
✅ **Path-based routing** operational  
✅ **Tailscale DNS** working  
✅ **Self-signed certs** deployed  
✅ **Zero downtime** deployment  
✅ **Complete documentation**  

---

## 💡 Pro Tips

**Bookmark These:**
```
🏠 https://nxcore.tail79107c.ts.net/           ← Landing page
💻 http://100.115.9.61:8080/                    ← Code-Server
📊 http://100.115.9.61:8081/                    ← Dashboard
📓 http://100.115.9.61:8888/                    ← Jupyter
```

**Quick Access Code-Server:**
```
Password: ChangeMe_CodeServerPassword123
```

**Renew Certificates (before Oct 16, 2026):**
```powershell
.\scripts\ps\generate-selfsigned-certs.ps1
.\scripts\ps\deploy-selfsigned-certs.ps1
```

---

## 🚨 Troubleshooting

### Browser shows "Not Secure"
→ Import certificate and restart browser

### Can't resolve hostname
→ Enable "Use Tailscale DNS" in Tailscale settings (already done ✅)

### Service shows 502 Bad Gateway
→ Service not deployed yet, deploy with `.\scripts\ps\deploy-containers.ps1`

### Certificate expired
→ Regenerate: `.\scripts\ps\generate-selfsigned-certs.ps1`

---

## 🎉 You're All Set!

Your NXCore infrastructure is ready to use! 

**Start here:** https://nxcore.tail79107c.ts.net/ (after importing certificate)

Or jump right into development: http://100.115.9.61:8080/

---

**Questions?** Check [docs/SERVICE_ACCESS_GUIDE.md](docs/SERVICE_ACCESS_GUIDE.md) for detailed instructions.

**Happy coding!** 🚀

