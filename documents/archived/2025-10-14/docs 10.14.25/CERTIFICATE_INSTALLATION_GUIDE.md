# NXCore Certificate Installation Guide

**Last Updated**: October 15, 2025  
**Purpose**: Install NXCore self-signed certificate on client systems  
**Result**: Eliminate browser security warnings for all NXCore subdomains

---

## 🎯 **Overview**

This guide provides step-by-step instructions for installing the NXCore self-signed certificate on various operating systems. Once installed, all NXCore subdomains will work seamlessly without browser security warnings.

### **Benefits of Pre-Installation**
- ✅ **No browser warnings** on first visit
- ✅ **Professional user experience** 
- ✅ **Seamless HTTPS access** to all services
- ✅ **One-time setup** per client system

---

## 📋 **Prerequisites**

### **Required Files**
- **Certificate File**: `self-signed.crt` (from NXCore server)
- **Server Access**: Ability to download certificate from NXCore

### **Download Certificate**
```bash
# From any client system with SSH access
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./

# Or download via web browser (after server setup)
# https://nxcore.tail79107c.ts.net/certs/self-signed.crt
```

---

## 🖥️ **Windows Installation**

### **Method 1: Certificate Manager (Recommended)**

1. **Open Certificate Manager**
   ```cmd
   certlm.msc
   ```

2. **Navigate to Trusted Root Certification Authorities**
   - Expand `Trusted Root Certification Authorities`
   - Click on `Certificates`

3. **Import Certificate**
   - Right-click in the right panel
   - Select `All Tasks` → `Import...`
   - Click `Next`

4. **Select Certificate File**
   - Click `Browse...`
   - Select `self-signed.crt`
   - Click `Next`

5. **Certificate Store**
   - Select `Place all certificates in the following store`
   - Store: `Trusted Root Certification Authorities`
   - Click `Next`

6. **Complete Import**
   - Click `Finish`
   - Click `OK` on success message

### **Method 2: PowerShell (Automated)**

```powershell
# Run as Administrator
Import-Certificate -FilePath "self-signed.crt" -CertStoreLocation "Cert:\LocalMachine\Root"
```

### **Method 3: Command Line**

```cmd
# Run as Administrator
certutil -addstore -user Root self-signed.crt
```

### **Verification (Windows)**

```cmd
# Check if certificate is installed
certutil -store -user Root | findstr "nxcore"
```

---

## 🍎 **macOS Installation**

### **Method 1: Keychain Access (GUI)**

1. **Open Keychain Access**
   - Applications → Utilities → Keychain Access

2. **Import Certificate**
   - File → Import Items...
   - Select `self-signed.crt`
   - Click `Open`

3. **Trust Settings**
   - Double-click the imported certificate
   - Expand `Trust` section
   - Set `When using this certificate` to `Always Trust`
   - Close the window

4. **Enter Password**
   - Enter your macOS user password
   - Click `Update Settings`

### **Method 2: Command Line (Automated)**

```bash
# Install in system keychain (requires sudo)
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain self-signed.crt

# Install in user keychain
security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain self-signed.crt
```

### **Verification (macOS)**

```bash
# Check if certificate is installed
security find-certificate -c "*.nxcore.tail79107c.ts.net" /Library/Keychains/System.keychain
```

---

## 🐧 **Linux Installation**

### **Ubuntu/Debian Systems**

```bash
# Copy certificate to system directory
sudo cp self-signed.crt /usr/local/share/ca-certificates/nxcore-self-signed.crt

# Update certificate store
sudo update-ca-certificates

# Verify installation
ls -la /etc/ssl/certs/nxcore-self-signed.pem
```

### **CentOS/RHEL/Fedora Systems**

```bash
# Copy certificate to system directory
sudo cp self-signed.crt /etc/pki/ca-trust/source/anchors/

# Update certificate store
sudo update-ca-trust

# Verify installation
ls -la /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
```

### **Arch Linux**

```bash
# Copy certificate to system directory
sudo cp self-signed.crt /etc/ca-certificates/trust-source/anchors/

# Update certificate store
sudo trust extract-compat

# Verify installation
ls -la /etc/ssl/certs/nxcore-self-signed.pem
```

### **Verification (Linux)**

```bash
# Test certificate validation
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt self-signed.crt

# Check certificate store
grep -r "nxcore" /etc/ssl/certs/
```

---

## 🌐 **Browser-Specific Installation**

### **Chrome/Chromium**

Chrome uses the system certificate store, so installing the certificate system-wide (as described above) will work automatically.

### **Firefox**

Firefox maintains its own certificate store:

1. **Open Firefox**
2. **Go to Settings**
   - Type `about:preferences#privacy` in address bar
3. **Security Settings**
   - Scroll down to `Certificates`
   - Click `View Certificates...`
4. **Import Certificate**
   - Click `Import...`
   - Select `self-signed.crt`
   - Check `Trust this CA to identify websites`
   - Click `OK`

### **Safari (macOS)**

Safari uses the macOS Keychain, so the system-wide installation (described above) will work automatically.

---

## 🔧 **Automated Installation Scripts**

### **Windows PowerShell Script**

Create `install-nxcore-cert.ps1`:

```powershell
# NXCore Certificate Installation Script
param(
    [string]$CertPath = "self-signed.crt"
)

Write-Host "Installing NXCore Certificate..." -ForegroundColor Green

try {
    # Import certificate to Trusted Root Certification Authorities
    Import-Certificate -FilePath $CertPath -CertStoreLocation "Cert:\LocalMachine\Root"
    Write-Host "Certificate installed successfully!" -ForegroundColor Green
    
    # Verify installation
    $cert = Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
    if ($cert) {
        Write-Host "Verification: Certificate found in store" -ForegroundColor Green
        Write-Host "Subject: $($cert.Subject)" -ForegroundColor Cyan
        Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Error installing certificate: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

### **Linux Bash Script**

Create `install-nxcore-cert.sh`:

```bash
#!/bin/bash
# NXCore Certificate Installation Script

CERT_FILE="self-signed.crt"
CERT_NAME="nxcore-self-signed"

echo "Installing NXCore Certificate..."

# Detect distribution
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    sudo cp "$CERT_FILE" "/usr/local/share/ca-certificates/${CERT_NAME}.crt"
    sudo update-ca-certificates
    echo "Certificate installed for Debian/Ubuntu"
elif [ -f /etc/redhat-release ]; then
    # CentOS/RHEL/Fedora
    sudo cp "$CERT_FILE" "/etc/pki/ca-trust/source/anchors/${CERT_NAME}.crt"
    sudo update-ca-trust
    echo "Certificate installed for CentOS/RHEL/Fedora"
elif [ -f /etc/arch-release ]; then
    # Arch Linux
    sudo cp "$CERT_FILE" "/etc/ca-certificates/trust-source/anchors/${CERT_NAME}.crt"
    sudo trust extract-compat
    echo "Certificate installed for Arch Linux"
else
    echo "Unsupported distribution"
    exit 1
fi

# Verify installation
if [ -f "/etc/ssl/certs/${CERT_NAME}.pem" ] || [ -f "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" ]; then
    echo "Verification: Certificate installed successfully"
else
    echo "Warning: Could not verify certificate installation"
fi
```

---

## 🧪 **Testing Certificate Installation**

### **Test HTTPS Access**

After installation, test access to NXCore subdomains:

```bash
# Test with curl (should not show certificate errors)
curl -I https://grafana.nxcore.tail79107c.ts.net/
curl -I https://prometheus.nxcore.tail79107c.ts.net/
curl -I https://status.nxcore.tail79107c.ts.net/

# Test with openssl
openssl s_client -connect grafana.nxcore.tail79107c.ts.net:443 -servername grafana.nxcore.tail79107c.ts.net
```

### **Browser Testing**

1. **Open browser** (Chrome, Firefox, Safari)
2. **Navigate to** `https://grafana.nxcore.tail79107c.ts.net/`
3. **Verify** no security warnings appear
4. **Test other subdomains**:
   - `https://prometheus.nxcore.tail79107c.ts.net/`
   - `https://status.nxcore.tail79107c.ts.net/`
   - `https://files.nxcore.tail79107c.ts.net/`

---

## 🔄 **Certificate Renewal**

### **When Certificate Expires**

The self-signed certificate is valid for 365 days. Before expiration:

1. **Generate new certificate** on NXCore server
2. **Distribute new certificate** to all client systems
3. **Install new certificate** using same process
4. **Remove old certificate** from client systems

### **Automated Renewal Process**

```bash
# On NXCore server (renewal script)
#!/bin/bash
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

# Notify users to update certificates
echo "New certificate generated. Please update client certificates."
```

---

## 🚨 **Troubleshooting**

### **Certificate Not Trusted**

**Symptoms**: Browser still shows security warnings

**Solutions**:
1. **Verify installation**: Check certificate is in correct store
2. **Restart browser**: Close and reopen browser
3. **Clear browser cache**: Clear SSL state
4. **Check certificate details**: Verify subject and SAN match

### **Certificate Installation Failed**

**Windows**:
```cmd
# Check certificate store
certutil -store -user Root | findstr "nxcore"

# Reinstall with verbose output
certutil -addstore -user Root -v self-signed.crt
```

**macOS**:
```bash
# Check keychain
security find-certificate -c "nxcore" /Library/Keychains/System.keychain

# Reinstall
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain self-signed.crt
```

**Linux**:
```bash
# Check certificate store
ls -la /etc/ssl/certs/ | grep nxcore

# Reinstall
sudo cp self-signed.crt /usr/local/share/ca-certificates/nxcore-self-signed.crt
sudo update-ca-certificates
```

---

## 📋 **Installation Checklist**

### **Pre-Installation**
- [ ] Download certificate from NXCore server
- [ ] Verify certificate file integrity
- [ ] Backup existing certificates (if needed)

### **Installation**
- [ ] Install certificate in system certificate store
- [ ] Verify installation success
- [ ] Test browser access to subdomains

### **Post-Installation**
- [ ] Test all NXCore subdomains
- [ ] Verify no security warnings
- [ ] Document installation for team
- [ ] Set up renewal reminder

---

## 🔗 **Related Documentation**

- [SSL Certificate Strategy](./SSL_CERTIFICATE_STRATEGY.md)
- [Phase B Browser Workspaces Plan](./PHASE_B_BROWSER_WORKSPACES_PLAN.md)
- [Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)
- [Quick Reference](./QUICK_REFERENCE.md)

---

*This guide ensures seamless HTTPS access to all NXCore services by pre-installing the self-signed certificate on client systems.*
