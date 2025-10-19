# SSL Certificate Strategy for NXCore Subdomains

**Last Updated**: October 15, 2025  
**Status**: ✅ **IMPLEMENTATION READY**  
**Scope**: Self-signed certificates for subdomain access

---

## 🎯 **Problem Statement**

### **Current Issue**
- **Tailscale certificates**: Only support main domain (`nxcore.tail79107c.ts.net`)
- **Subdomain limitation**: Cannot generate wildcard certificates via Tailscale
- **Result**: All subdomains return 404/SSL errors
- **Impact**: Phase B deployment blocked

### **Affected Services**
- `grafana.nxcore.tail79107c.ts.net`
- `prometheus.nxcore.tail79107c.ts.net`
- `status.nxcore.tail79107c.ts.net`
- `logs.nxcore.tail79107c.ts.net`
- `files.nxcore.tail79107c.ts.net`
- `auth.nxcore.tail79107c.ts.net`
- All Phase B subdomains (vnc, code, jupyter, etc.)

---

## 🔐 **Solution: Self-Signed Certificate Strategy**

### **Why Self-Signed Certificates Work**

1. **Private Network**: All access through Tailscale (trusted environment)
2. **Internal Use**: No external validation required
3. **Full Control**: Generate certificates for any subdomain
4. **User Acceptance**: One-time browser acceptance per user
5. **Cost Effective**: No external CA costs

### **Certificate Strategy**

#### **Mixed Certificate Approach**
- **Main Domain**: Keep Tailscale certificate (`nxcore.tail79107c.ts.net`)
- **Subdomains**: Use self-signed wildcard certificate (`*.nxcore.tail79107c.ts.net`)

---

## 🛠️ **Implementation Steps**

### **Step 1: Generate Self-Signed Wildcard Certificate**

```bash
# SSH to NXCore
ssh glyph@100.115.9.61

# Create certificate directory
sudo mkdir -p /opt/nexus/traefik/certs
cd /opt/nexus/traefik/certs

# Generate self-signed wildcard certificate
sudo openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"

# Set proper permissions
sudo chown root:root self-signed.*
sudo chmod 600 self-signed.key
sudo chmod 644 self-signed.crt
```

### **Step 2: Update Traefik Configuration**

Create or update `/opt/nexus/traefik/dynamic/traefik-dynamic.yml`:

```yaml
tls:
  certificates:
    # Tailscale certificate for main domain
    - certFile: /certs/fullchain.pem
      keyFile: /certs/privkey.pem
      stores:
        - default
    # Self-signed certificate for subdomains
    - certFile: /certs/self-signed.crt
      keyFile: /certs/self-signed.key
      stores:
        - default

  stores:
    default:
      defaultCertificate:
        certFile: /certs/fullchain.pem
        keyFile: /certs/privkey.pem
```

### **Step 3: Restart Traefik**

```bash
sudo docker restart traefik
```

### **Step 4: Verify Certificate**

```bash
# Check certificate details
openssl x509 -in /opt/nexus/traefik/certs/self-signed.crt -text -noout | grep -A 5 'Subject Alternative Name'

# Test subdomain access
curl -k https://grafana.nxcore.tail79107c.ts.net/
```

---

## 🔍 **Certificate Details**

### **Self-Signed Certificate Specifications**

- **Type**: X.509 Self-Signed Certificate
- **Key Size**: 4096-bit RSA
- **Validity**: 365 days
- **Subject**: `*.nxcore.tail79107c.ts.net`
- **SAN**: `*.nxcore.tail79107c.ts.net`, `nxcore.tail79107c.ts.net`
- **Organization**: NXCore

### **Certificate Chain**

```
Self-Signed Root CA
└── *.nxcore.tail79107c.ts.net (Wildcard Certificate)
    ├── grafana.nxcore.tail79107c.ts.net
    ├── prometheus.nxcore.tail79107c.ts.net
    ├── status.nxcore.tail79107c.ts.net
    ├── logs.nxcore.tail79107c.ts.net
    ├── files.nxcore.tail79107c.ts.net
    ├── auth.nxcore.tail79107c.ts.net
    └── [All Phase B subdomains]
```

---

## ⚠️ **User Experience Considerations**

### **Option 1: Pre-Install Certificate (Recommended)**

**Best Practice**: Install the certificate on client PCs before deployment to eliminate all browser warnings.

#### **Windows Certificate Installation**

```powershell
# Download certificate from server
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./

# Install in Windows Certificate Store
certlm.msc
# Navigate to: Trusted Root Certification Authorities > Certificates
# Right-click > All Tasks > Import
# Select self-signed.crt
# Place in: Trusted Root Certification Authorities
```

#### **macOS Certificate Installation**

```bash
# Download certificate
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./

# Install in macOS Keychain
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain self-signed.crt
```

#### **Linux Certificate Installation**

```bash
# Download certificate
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./

# Install in system certificate store
sudo cp self-signed.crt /usr/local/share/ca-certificates/nxcore-self-signed.crt
sudo update-ca-certificates
```

### **Option 2: Browser Warnings (Fallback)**

If certificate pre-installation isn't possible, users will see security warnings:
- **Chrome**: "Your connection is not private"
- **Firefox**: "Warning: Potential Security Risk Ahead"
- **Safari**: "This Connection Is Not Private"

#### **User Instructions**

1. **Click "Advanced"** on the security warning
2. **Click "Proceed to [site] (unsafe)"**
3. **Accept the certificate** in the browser
4. **Future visits** will work normally

---

## 🔄 **Certificate Renewal**

### **Automatic Renewal Script**

Create `/opt/nexus/scripts/renew-cert.sh`:

```bash
#!/bin/bash
# Certificate renewal script

cd /opt/nexus/traefik/certs

# Generate new certificate
openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"

# Set permissions
chown root:root self-signed.*
chmod 600 self-signed.key
chmod 644 self-signed.crt

# Restart Traefik
docker restart traefik

echo "Certificate renewed successfully"
```

### **Cron Job Setup**

```bash
# Add to crontab for automatic renewal (30 days before expiry)
0 2 1 * * /opt/nexus/scripts/renew-cert.sh
```

---

## 📊 **Testing & Verification**

### **Certificate Validation**

```bash
# Check certificate validity
openssl x509 -in /opt/nexus/traefik/certs/self-signed.crt -text -noout

# Test HTTPS connectivity
curl -k -I https://grafana.nxcore.tail79107c.ts.net/
curl -k -I https://prometheus.nxcore.tail79107c.ts.net/
curl -k -I https://status.nxcore.tail79107c.ts.net/
```

### **Browser Testing**

1. **Chrome**: Navigate to subdomain, accept certificate
2. **Firefox**: Navigate to subdomain, accept certificate
3. **Safari**: Navigate to subdomain, accept certificate
4. **Mobile**: Test on mobile browsers

---

## 🚀 **Phase B Deployment Impact**

### **Before SSL Fix**
- ❌ All subdomains return 404/SSL errors
- ❌ Phase B deployment blocked
- ❌ User experience degraded

### **After SSL Fix**
- ✅ All subdomains accessible via HTTPS
- ✅ Phase B deployment unblocked
- ✅ Professional HTTPS experience
- ✅ One-time certificate acceptance per user

---

## 📋 **Implementation Checklist**

### **Server-Side Setup**
- [ ] Generate self-signed wildcard certificate
- [ ] Update Traefik configuration
- [ ] Restart Traefik service
- [ ] Test subdomain access
- [ ] Verify certificate details
- [ ] Set up certificate renewal

### **Client-Side Setup (Recommended)**
- [ ] Download certificate from server
- [ ] Install certificate on Windows PCs (certlm.msc)
- [ ] Install certificate on macOS systems (Keychain)
- [ ] Install certificate on Linux systems (ca-certificates)
- [ ] Test HTTPS access without warnings
- [ ] Document installation process for users

### **Documentation & Deployment**
- [ ] Update deployment documentation
- [ ] Create certificate installation guide
- [ ] Test Phase B deployment readiness
- [ ] Verify all subdomains work with HTTPS

---

## 🔗 **Related Documentation**

- [Phase B Browser Workspaces Plan](./PHASE_B_BROWSER_WORKSPACES_PLAN.md)
- [Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)
- [Quick Reference](./QUICK_REFERENCE.md)
- [Critical Issues Resolution](./CRITICAL_ISSUES_RESOLUTION_2025-10-15.md)

---

*This document provides a comprehensive guide for implementing self-signed certificates to resolve subdomain SSL issues and enable Phase B deployment.*
