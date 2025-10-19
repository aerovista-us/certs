# 🔐 CRT Certificate Installation Guide

**Date**: October 19, 2025  
**Status**: ✅ **CRT CERTIFICATE READY FOR INSTALLATION**  
**Format**: .crt (Windows-compatible)

---

## 🔐 **Certificate Details**

### **Domain**: nxcore.tail79107c.ts.net
### **Validity**: 365 days (until October 19, 2026)
### **Key Size**: 4096 bits
### **Format**: CRT (Windows-compatible)
### **Type**: Self-signed with Subject Alternative Names (SAN)

---

## 📁 **Certificate Files**

### **Primary Certificate File**:
- **File**: `nxcore.crt`
- **Location**: `./backups/20251019_051415/certificates/nxcore.crt`
- **Format**: CRT (Windows-compatible)

### **Additional Files**:
- **Private Key**: `privkey.pem`
- **Full Chain**: `fullchain.pem`
- **Original PEM**: `cert.pem`

---

## 🚀 **Installation Instructions**

### **For Windows (Chrome/Edge)**:
1. **Download**: `nxcore.crt` from `./backups/20251019_051415/certificates/`
2. **Right-click** the `nxcore.crt` file
3. **Select**: "Install Certificate"
4. **Choose**: "Current User" or "Local Machine"
5. **Select**: "Place all certificates in the following store"
6. **Browse**: Select "Trusted Root Certification Authorities"
7. **Click**: "Next" → "Finish"
8. **Restart** Chrome/Edge

### **For Windows (Firefox)**:
1. **Download**: `nxcore.crt` from `./backups/20251019_051415/certificates/`
2. **Open Firefox** → Settings
3. **Go to**: Privacy & Security → Certificates → View Certificates
4. **Click**: "Import"
5. **Select**: `nxcore.crt` file
6. **Check**: "Trust this CA to identify websites"
7. **Click**: "OK"
8. **Restart** Firefox

### **For Windows (Internet Explorer)**:
1. **Download**: `nxcore.crt` from `./backups/20251019_051415/certificates/`
2. **Double-click** the `nxcore.crt` file
3. **Click**: "Install Certificate"
4. **Choose**: "Current User" or "Local Machine"
5. **Select**: "Place all certificates in the following store"
6. **Browse**: Select "Trusted Root Certification Authorities"
7. **Click**: "Next" → "Finish"
8. **Restart** Internet Explorer

---

## 🧪 **Testing Instructions**

### **1. Test Certificate Installation**:
After installation, test these URLs:
- **Landing**: https://nxcore.tail79107c.ts.net/
- **OpenWebUI**: https://nxcore.tail79107c.ts.net/ai/
- **n8n**: https://nxcore.tail79107c.ts.net/n8n/
- **Grafana**: https://nxcore.tail79107c.ts.net/grafana/
- **Prometheus**: https://nxcore.tail79107c.ts.net/prometheus/
- **Uptime Kuma**: https://nxcore.tail79107c.ts.net/status/

### **2. Verify Certificate Trust**:
- **No certificate warnings** should appear
- **Green lock icon** should show in browser
- **Services should load** without certificate errors

---

## 🔍 **Troubleshooting**

### **If certificate still shows as untrusted**:
1. **Clear browser cache** and cookies
2. **Restart browser** completely
3. **Check certificate installation** in browser settings
4. **Verify certificate** is in "Trusted Root Certification Authorities"

### **If services still show certificate errors**:
1. **Check Traefik** is using new certificates
2. **Verify certificate files** are in correct location
3. **Check Traefik logs** for certificate errors

### **Alternative Installation Method**:
If the above doesn't work, try:
1. **Open Command Prompt as Administrator**
2. **Run**: `certlm.msc`
3. **Navigate**: Trusted Root Certification Authorities → Certificates
4. **Right-click**: "All Tasks" → "Import"
5. **Select**: `nxcore.crt` file
6. **Follow**: Import wizard

---

## 📊 **Certificate Information**

### **Subject Alternative Names (SAN)**:
- DNS: nxcore.tail79107c.ts.net
- DNS: *.nxcore.tail79107c.ts.net (wildcard)
- DNS: localhost
- IP: 127.0.0.1
- IP: 100.115.9.61

### **Certificate Fingerprint**:
SHA256: 5D:EE:6C:09:D1:82:5E:C7:65:7D:7B:70:A3:2D:6C:97:F8:C3:4E:49:97:B1:82:80:4F:E2:47:87:54:2A:9C:C3

---

## 🎉 **Expected Results**

After successful certificate installation:
- ✅ **No certificate warnings** in browser
- ✅ **Green lock icon** shows in address bar
- ✅ **All services accessible** without certificate errors
- ✅ **OpenWebUI, n8n, Grafana** all working properly
- ✅ **Full browser functionality** restored

---

**CRT Certificate ready for installation!** 🎉

*Install the certificate in your browser to resolve all certificate trust issues and enable full access to all services.*
