# 🔐 New Self-Signed Certificates Installation Guide

**Date**: Sun Oct 19 05:14:50 PDT 2025
**Status**: ✅ **NEW CERTIFICATES GENERATED AND DEPLOYED**

## 🔐 **Certificate Details**

### **Domain**: nxcore.tail79107c.ts.net
### **Validity**: 365 days
### **Key Size**: 4096 bits
### **Type**: Self-signed with Subject Alternative Names (SAN)

## 📋 **Certificate Information**

### **Subject Alternative Names (SAN)**:
- DNS: nxcore.tail79107c.ts.net
- DNS: *.nxcore.tail79107c.ts.net (wildcard)
- DNS: localhost
- IP: 127.0.0.1
- IP: 100.115.9.61

### **Certificate Fingerprint**:
SHA256 Fingerprint=5D:EE:6C:09:D1:82:5E:C7:65:7D:7B:70:A3:2D:6C:97:F8:C3:4E:49:97:B1:82:80:4F:E2:47:87:54:2A:9C:C3

## 🚀 **Installation Instructions**

### **For Windows (Chrome/Edge)**:
1. Download the certificate: `./backups/20251019_051415/certificates/cert.pem`
2. Open Chrome/Edge settings
3. Go to Privacy and Security > Security > Manage certificates
4. Click "Import" and select the certificate file
5. Choose "Trusted Root Certification Authorities"
6. Restart browser

### **For Windows (Firefox)**:
1. Download the certificate: `./backups/20251019_051415/certificates/cert.pem`
2. Open Firefox settings
3. Go to Privacy & Security > Certificates > View Certificates
4. Click "Import" and select the certificate file
5. Check "Trust this CA to identify websites"
6. Restart browser

### **For macOS (Safari/Chrome)**:
1. Download the certificate: `./backups/20251019_051415/certificates/cert.pem`
2. Double-click the certificate file
3. Add to "System" keychain
4. Double-click the certificate in Keychain Access
5. Expand "Trust" and set to "Always Trust"
6. Restart browser

### **For Linux (Chrome/Firefox)**:
1. Download the certificate: `./backups/20251019_051415/certificates/cert.pem`
2. Copy to system certificate store:
   ```bash
   sudo cp cert.pem /usr/local/share/ca-certificates/nxcore.crt
   sudo update-ca-certificates
   ```
3. Restart browser

## 🧪 **Testing Instructions**

### **1. Test Certificate Installation**:
```bash
# Test certificate validity
openssl s_client -connect nxcore.tail79107c.ts.net:443 -servername nxcore.tail79107c.ts.net < /dev/null 2>/dev/null | openssl x509 -noout -text
```

### **2. Test Service Access**:
- Landing: https://nxcore.tail79107c.ts.net/
- OpenWebUI: https://nxcore.tail79107c.ts.net/ai/
- n8n: https://nxcore.tail79107c.ts.net/n8n/
- Grafana: https://nxcore.tail79107c.ts.net/grafana/
- Prometheus: https://nxcore.tail79107c.ts.net/prometheus/
- Uptime Kuma: https://nxcore.tail79107c.ts.net/status/

## 🔍 **Troubleshooting**

### **If certificate still shows as untrusted**:
1. Clear browser cache and cookies
2. Restart browser completely
3. Check certificate installation in browser settings
4. Verify certificate is in correct keychain/store

### **If services still show certificate errors**:
1. Check Traefik is using new certificates
2. Verify certificate files are in correct location
3. Check Traefik logs for certificate errors

## 📁 **Certificate Files**

- **Private Key**: `./backups/20251019_051415/certificates/privkey.pem`
- **Certificate**: `./backups/20251019_051415/certificates/cert.pem`
- **Full Chain**: `./backups/20251019_051415/certificates/fullchain.pem`
- **Configuration**: `./backups/20251019_051415/certificates/cert.conf`
- **Fingerprint**: `./backups/20251019_051415/certificates/fingerprint.txt`

---
**New certificates generated and deployed!** 🎉
