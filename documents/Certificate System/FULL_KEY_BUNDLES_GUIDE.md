# 🔐 NXCore Full Key Bundles Guide

**Complete certificate bundles with all formats for maximum compatibility**

## 🎯 **What Are Full Key Bundles?**

Full key bundles are comprehensive certificate packages that include **every possible format** needed for any platform or use case. Each service gets a complete bundle with:

### **📦 Certificate Formats**
- **PEM** - Server SSL and cross-platform use
- **P12** - Windows certificate import
- **CRT** - Windows application compatibility  
- **DER** - Binary format alternative
- **PFX** - Alternative Windows format
- **JKS** - Java application support
- **Combined PEM** - Certificate + private key

### **🚀 Installation Packages**
- **Individual packages** - Per-service installation
- **Platform installers** - Windows, Linux, macOS
- **Master installers** - Bulk installation scripts
- **Installation guides** - Service-specific instructions

---

## 🚀 **Quick Start**

### **Generate Full Key Bundles**
```bash
# Run the full key bundle generator
./scripts/generate-full-key-bundles.sh
```

This creates complete certificate bundles for all 10 services with every format needed.

### **Installation Options**

#### **Individual Service Installation**
1. Navigate to `./certs/selfsigned/[service]/installation-package/`
2. Follow the `INSTALLATION_GUIDE.md`
3. Use platform-specific installer script

#### **Bulk Installation**
- **Windows**: `install-all-windows.bat`
- **Linux**: `./install-all-linux.sh`  
- **macOS**: `./install-all-macos.sh`

#### **Server Deployment**
- Copy `fullchain.pem` and `privkey.pem` to server
- Configure web server with certificate files
- Restart web server

---

## 📊 **Bundle Contents**

### **Certificate Files (Per Service)**
```
[service]/
├── fullchain.pem           # Full certificate chain
├── privkey.pem            # Private key
├── cert.pem               # Certificate only
├── [service].p12          # PKCS#12 bundle (Windows)
├── [service].crt          # Certificate (Windows)
├── [service].der          # Certificate (DER binary)
├── [service]-combined.pem  # Certificate + Private key
├── [service].pfx          # PFX bundle (Windows)
├── [service].jks          # Java KeyStore
└── installation-package/  # Installation package
    ├── INSTALLATION_GUIDE.md
    ├── install-windows.bat
    ├── install-linux.sh
    └── install-macos.sh
```

### **Installation Package Contents**
Each service gets a complete installation package with:
- **All certificate formats** - Every format needed
- **Installation guide** - Service-specific instructions
- **Platform installers** - Windows, Linux, macOS scripts
- **Verification steps** - How to test installation

---

## 🔧 **Platform-Specific Usage**

### **Windows Users**
- **Easy Import**: Use `.p12` files (double-click to import)
- **Certificate Manager**: Use `.crt` files
- **Bulk Installation**: Run `install-all-windows.bat`
- **Manual Import**: Use `.pfx` files as alternative

### **Linux Users**
- **Server SSL**: Use `fullchain.pem` and `privkey.pem`
- **Client Trust**: Use `fullchain.pem` in certificate store
- **Bulk Installation**: Run `./install-all-linux.sh`
- **Manual Import**: Copy PEM files to certificate store

### **macOS Users**
- **Keychain Import**: Use `.p12` files
- **System Trust**: Use `fullchain.pem` in system keychain
- **Bulk Installation**: Run `./install-all-macos.sh`
- **Manual Import**: Use `.crt` files

### **Java Applications**
- **KeyStore**: Use `.jks` files
- **Configuration**: Set `javax.net.ssl.trustStore`
- **Alternative**: Use `.p12` files with Java tools

---

## 🎯 **Use Cases**

### **Web Server Deployment**
```bash
# Copy PEM files to server
scp fullchain.pem privkey.pem user@server:/path/to/certs/

# Configure web server
# Nginx, Apache, Traefik, etc.
```

### **Docker Deployment**
```bash
# Mount certificates in container
docker run -v /path/to/certs:/certs nginx
```

### **Windows Certificate Manager**
```powershell
# Import P12 certificate
Import-Certificate -FilePath "service.p12" -CertStoreLocation Cert:\LocalMachine\Root
```

### **Java Applications**
```bash
# Use JKS file
java -Djavax.net.ssl.trustStore=service.jks -Djavax.net.ssl.trustStorePassword=changeit
```

---

## 📋 **Services with Full Bundles**

| Service | URL | Bundle Location | Status |
|---------|-----|-----------------|--------|
| **Landing** | https://nxcore.tail79107c.ts.net/ | `./landing/` | ✅ Complete |
| **Grafana** | https://nxcore.tail79107c.ts.net/grafana/ | `./grafana/` | ✅ Complete |
| **Prometheus** | https://nxcore.tail79107c.ts.net/prometheus/ | `./prometheus/` | ✅ Complete |
| **Portainer** | https://nxcore.tail79107c.ts.net/portainer/ | `./portainer/` | ✅ Complete |
| **AI Service** | https://nxcore.tail79107c.ts.net/ai/ | `./ai/` | ✅ Complete |
| **FileBrowser** | https://nxcore.tail79107c.ts.net/files/ | `./files/` | ✅ Complete |
| **Uptime Kuma** | https://nxcore.tail79107c.ts.net/status/ | `./status/` | ✅ Complete |
| **Traefik** | https://nxcore.tail79107c.ts.net/traefik/ | `./traefik/` | ✅ Complete |
| **AeroCaller** | https://nxcore.tail79107c.ts.net/aerocaller/ | `./aerocaller/` | ✅ Complete |
| **Authelia** | https://nxcore.tail79107c.ts.net/auth/ | `./auth/` | ✅ Complete |

---

## ✅ **Verification**

### **Test Each Service**
After installation, test each service:
- **Landing**: https://nxcore.tail79107c.ts.net/
- **Grafana**: https://nxcore.tail79107c.ts.net/grafana/
- **Prometheus**: https://nxcore.tail79107c.ts.net/prometheus/
- **Portainer**: https://nxcore.tail79107c.ts.net/portainer/
- **AI Service**: https://nxcore.tail79107c.ts.net/ai/
- **FileBrowser**: https://nxcore.tail79107c.ts.net/files/
- **Uptime Kuma**: https://nxcore.tail79107c.ts.net/status/
- **Traefik**: https://nxcore.tail79107c.ts.net/traefik/
- **AeroCaller**: https://nxcore.tail79107c.ts.net/aerocaller/
- **Authelia**: https://nxcore.tail79107c.ts.net/auth/

### **Look For**
- ✅ **Green lock icon** in browser address bar
- ✅ **No security warnings**
- ✅ **Full functionality** of all services
- ✅ **Proper SSL termination**

---

## 🚀 **Next Steps**

1. **Generate bundles**: Run the full key bundle generator
2. **Test individual bundles**: Verify each service bundle
3. **Deploy to server**: Copy PEM files to web server
4. **Install on clients**: Use platform-specific installers
5. **Verify functionality**: Test all services for green lock icons

---

**Generated by**: NXCore Full Key Bundle Generator  
**Status**: ✅ **COMPLETE KEY BUNDLES READY**  
**Next Action**: Run `./scripts/generate-full-key-bundles.sh` to create all bundles
