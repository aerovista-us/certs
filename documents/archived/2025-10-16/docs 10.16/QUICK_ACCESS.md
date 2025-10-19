# 🚀 NXCore Quick Access Card

## 🌐 Main URLs

### **Landing Page (Start Here!)**
```
https://nxcore.tail79107c.ts.net/
```

### **Development (No Cert Required)**
```
Code-Server:  http://100.115.9.61:8080/  Password: ChangeMe_CodeServerPassword123
Jupyter:      http://100.115.9.61:8888/
RStudio:      http://100.115.9.61:8787/
Dashboard:    http://100.115.9.61:8081/
```

### **Management (HTTPS)**
```
Portainer:    https://nxcore.tail79107c.ts.net/portainer/
Authelia:     https://nxcore.tail79107c.ts.net/auth/
```

---

## 📜 Quick Commands

### Import Certificate (One-Time)
```powershell
Start-Process ".\certs\selfsigned\fullchain.pem"
```
Then: Install → Local Machine → Trusted Root CA → Finish

### Test Services
```powershell
curl.exe -k https://nxcore.tail79107c.ts.net/
```

### Check Status
```powershell
ssh glyph@100.115.9.61 "sudo docker ps"
```

### Deploy Services
```powershell
.\scripts\ps\deploy-containers.ps1 -Service all
```

### Renew Certificate (Before Oct 2026)
```powershell
.\scripts\ps\generate-selfsigned-certs.ps1
.\scripts\ps\deploy-selfsigned-certs.ps1
```

---

## 🔑 Default Passwords

| Service | Credentials |
|---------|-------------|
| Code-Server | `ChangeMe_CodeServerPassword123` |
| RStudio | rstudio / rstudio |
| Portainer | Setup on first visit |
| Jupyter | Check logs for token |

---

## 📚 Documentation

- **Setup Guide:** `SETUP_COMPLETE.md`
- **Access Guide:** `docs/SERVICE_ACCESS_GUIDE.md`
- **Cert Guide:** `docs/SELFSIGNED_CERTIFICATES.md`
- **Project Map:** `PROJECT_MAP.md`

---

## ⚡ Troubleshooting

**Browser warning?** → Import certificate  
**Can't resolve hostname?** → Check Tailscale DNS (should be enabled ✅)  
**Service down?** → `ssh glyph@100.115.9.61 "sudo docker restart <service>"`

---

**Certificate Valid Until:** October 16, 2026  
**Server:** 100.115.9.61 (nxcore.tail79107c.ts.net)

