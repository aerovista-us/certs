#!/bin/bash
# Troubleshoot Certificate Issues
# Fixes certificate trust problems for browser access

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

log "🔍 TROUBLESHOOTING CERTIFICATE ISSUES"
log "📋 Browser still showing certificate errors"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Fix certificate trust issues"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"
DOMAIN="nxcore.tail79107c.ts.net"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Diagnose current certificate issues
log "🔍 Phase 1: Diagnosing current certificate issues..."

# Check if certificate files exist
if [ -f "./backups/20251019_051415/certificates/nxcore.crt" ]; then
    success "CRT certificate file exists"
else
    error "CRT certificate file not found"
    exit 1
fi

# Check certificate validity
log "🔍 Checking certificate validity..."
if command -v openssl >/dev/null 2>&1; then
    openssl x509 -in "./backups/20251019_051415/certificates/nxcore.crt" -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After|DNS:|IP:)" | head -5
else
    warning "OpenSSL not available for certificate verification"
fi

# Phase 2: Create alternative certificate formats
log "🔧 Phase 2: Creating alternative certificate formats..."

mkdir -p "$BACKUP_DIR/certificates"

# Create DER format certificate (Windows alternative)
log "🔧 Creating DER format certificate..."
openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -outform DER -out "$BACKUP_DIR/certificates/nxcore.der"
success "DER certificate created"

# Create P12 format certificate (Windows alternative)
log "🔧 Creating P12 format certificate..."
openssl pkcs12 -export -out "$BACKUP_DIR/certificates/nxcore.p12" -inkey "./backups/20251019_051415/certificates/privkey.pem" -in "./backups/20251019_051415/certificates/cert.pem" -passout pass:password
success "P12 certificate created"

# Create Windows-compatible certificate with proper extensions
log "🔧 Creating Windows-compatible certificate..."
cat > "$BACKUP_DIR/certificates/windows-cert.conf" << 'EOF'
[req]
default_bits = 4096
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req
x509_extensions = v3_req

[req_distinguished_name]
C = US
ST = California
L = San Francisco
O = NXCore Infrastructure
OU = Tailscale Network
CN = nxcore.tail79107c.ts.net
emailAddress = admin@nxcore.tail79107c.ts.net

[v3_req]
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign, digitalSignature, keyEncipherment
subjectAltName = @alt_names
authorityKeyIdentifier = keyid:always,issuer

[alt_names]
DNS.1 = nxcore.tail79107c.ts.net
DNS.2 = *.nxcore.tail79107c.ts.net
DNS.3 = localhost
IP.1 = 127.0.0.1
IP.2 = 100.115.9.61
EOF

# Generate new certificate with CA:TRUE
openssl req -new -x509 -key "./backups/20251019_051415/certificates/privkey.pem" -out "$BACKUP_DIR/certificates/nxcore-ca.crt" -days 365 -config "$BACKUP_DIR/certificates/windows-cert.conf" -extensions v3_req
success "Windows-compatible CA certificate created"

# Phase 3: Create comprehensive installation guide
log "📋 Phase 3: Creating comprehensive installation guide..."

cat > "$BACKUP_DIR/COMPREHENSIVE-CERTIFICATE-FIX.md" << EOF
# 🔐 Comprehensive Certificate Fix Guide

**Date**: $(date)
**Status**: 🚨 **CERTIFICATE TROUBLESHOOTING REQUIRED**

## 🚨 **Current Issue**
- Browser still showing certificate errors
- Certificate installation may not have worked
- Services accessible via curl but not browser

## 🔧 **Multiple Certificate Formats Available**

### **1. CRT Format (Original)**
- **File**: \`nxcore.crt\`
- **Location**: \`./backups/20251019_051415/certificates/nxcore.crt\`
- **Use**: Standard Windows certificate installation

### **2. DER Format (Alternative)**
- **File**: \`nxcore.der\`
- **Location**: \`$BACKUP_DIR/certificates/nxcore.der\`
- **Use**: Binary format for Windows

### **3. P12 Format (Alternative)**
- **File**: \`nxcore.p12\`
- **Location**: \`$BACKUP_DIR/certificates/nxcore.p12\`
- **Password**: \`password\`
- **Use**: PKCS#12 format for Windows

### **4. CA Certificate (Recommended)**
- **File**: \`nxcore-ca.crt\`
- **Location**: \`$BACKUP_DIR/certificates/nxcore-ca.crt\`
- **Use**: CA certificate for better trust

## 🚀 **Installation Methods**

### **Method 1: Windows Certificate Manager (Recommended)**
1. **Press**: Win + R
2. **Type**: \`certlm.msc\`
3. **Navigate**: Trusted Root Certification Authorities → Certificates
4. **Right-click**: "All Tasks" → "Import"
5. **Select**: \`nxcore-ca.crt\` (CA certificate)
6. **Follow**: Import wizard
7. **Restart**: Browser

### **Method 2: Browser-Specific Installation**

#### **Chrome/Edge**:
1. **Open**: chrome://settings/certificates
2. **Click**: "Authorities" tab
3. **Click**: "Import"
4. **Select**: \`nxcore-ca.crt\`
5. **Check**: "Trust this certificate for identifying websites"
6. **Restart**: Browser

#### **Firefox**:
1. **Open**: about:preferences#privacy
2. **Scroll**: "Certificates" section
3. **Click**: "View Certificates"
4. **Click**: "Import"
5. **Select**: \`nxcore-ca.crt\`
6. **Check**: "Trust this CA to identify websites"
7. **Restart**: Browser

### **Method 3: Command Line Installation**
\`\`\`cmd
# Run as Administrator
certlm.msc
# Then follow Method 1 steps
\`\`\`

## 🧪 **Testing Steps**

### **1. Test Certificate Installation**:
After installation, test these URLs:
- **Landing**: https://nxcore.tail79107c.ts.net/
- **OpenWebUI**: https://nxcore.tail79107c.ts.net/ai/
- **n8n**: https://nxcore.tail79107c.ts.net/n8n/
- **Grafana**: https://nxcore.tail79107c.ts.net/grafana/

### **2. Verify Certificate Trust**:
- **No certificate warnings** should appear
- **Green lock icon** should show in browser
- **Services should load** without certificate errors

## 🔍 **Troubleshooting**

### **If certificate still shows as untrusted**:
1. **Clear browser cache** and cookies
2. **Restart browser** completely
3. **Check certificate installation** in browser settings
4. **Try different certificate format** (DER, P12, CA)
5. **Verify certificate** is in "Trusted Root Certification Authorities"

### **If services still show certificate errors**:
1. **Check Traefik** is using new certificates
2. **Verify certificate files** are in correct location
3. **Check Traefik logs** for certificate errors
4. **Try alternative certificate formats**

## 📁 **Certificate Files**

### **Available Formats**:
- **CRT**: \`./backups/20251019_051415/certificates/nxcore.crt\`
- **DER**: \`$BACKUP_DIR/certificates/nxcore.der\`
- **P12**: \`$BACKUP_DIR/certificates/nxcore.p12\`
- **CA**: \`$BACKUP_DIR/certificates/nxcore-ca.crt\` (RECOMMENDED)

## 🎯 **Recommended Solution**

**Try the CA certificate first** (\`nxcore-ca.crt\`):
1. **Download**: \`nxcore-ca.crt\`
2. **Open**: \`certlm.msc\`
3. **Import**: to Trusted Root Certification Authorities
4. **Restart**: Browser
5. **Test**: Services

---
**Comprehensive certificate fix ready!** 🎉
EOF

success "Comprehensive installation guide created"

# Phase 4: Test current certificate status
log "🧪 Phase 4: Testing current certificate status..."

# Test certificate with different methods
log "Testing certificate with curl..."
curl -k -s -o /dev/null -w 'HTTPS Test: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "HTTPS Test: FAILED"

# Test certificate validity
log "Testing certificate validity..."
if command -v openssl >/dev/null 2>&1; then
    openssl s_client -connect nxcore.tail79107c.ts.net:443 -servername nxcore.tail79107c.ts.net < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -E "(Subject:|Issuer:|Not Before|Not After)" | head -3
else
    warning "OpenSSL not available for certificate testing"
fi

# Phase 5: Generate final report
log "📊 Phase 5: Generating final troubleshooting report..."

cat > "$BACKUP_DIR/certificate-troubleshooting-report.md" << EOF
# 🔍 Certificate Troubleshooting Report

**Date**: $(date)
**Status**: 🚨 **CERTIFICATE ISSUES IDENTIFIED**

## 🚨 **Issues Found**

### **Browser Certificate Errors**:
- Browser still showing \`net::ERR_CERT_AUTHORITY_INVALID\`
- Certificate installation may not have worked
- Services accessible via curl but not browser

## 🔧 **Solutions Provided**

### **1. Multiple Certificate Formats**:
- **CRT**: Standard Windows format
- **DER**: Binary format for Windows
- **P12**: PKCS#12 format with password
- **CA**: CA certificate for better trust (RECOMMENDED)

### **2. Installation Methods**:
- **Windows Certificate Manager**: \`certlm.msc\`
- **Browser-specific installation**
- **Command line installation**

### **3. Troubleshooting Steps**:
- Clear browser cache
- Restart browser
- Try different certificate formats
- Verify certificate installation

## 📊 **Test Results**

HTTPS Test: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "FAILED")

## 🚀 **Next Steps**

1. **Try CA certificate** (\`nxcore-ca.crt\`) first
2. **Use Windows Certificate Manager** (\`certlm.msc\`)
3. **Import to Trusted Root Certification Authorities**
4. **Restart browser** and test services

---
**Certificate troubleshooting complete!** 🎉
EOF

success "Troubleshooting report generated: $BACKUP_DIR/certificate-troubleshooting-report.md"

# Final status
log "🎉 CERTIFICATE TROUBLESHOOTING COMPLETE!"
log "🔧 Multiple certificate formats created"
log "📋 Comprehensive installation guide generated"
log "📁 Troubleshooting files saved at: $BACKUP_DIR"

success "Certificate troubleshooting complete! 🎉"

# Display final summary
echo ""
echo "🔍 **CERTIFICATE TROUBLESHOOTING SUMMARY**"
echo "========================================"
echo "✅ Multiple certificate formats created"
echo "✅ Comprehensive installation guide generated"
echo "✅ Troubleshooting steps provided"
echo ""
echo "📁 **Certificate Files:**"
echo "   - CRT: ./backups/20251019_051415/certificates/nxcore.crt"
echo "   - DER: $BACKUP_DIR/certificates/nxcore.der"
echo "   - P12: $BACKUP_DIR/certificates/nxcore.p12"
echo "   - CA: $BACKUP_DIR/certificates/nxcore-ca.crt (RECOMMENDED)"
echo ""
echo "🚀 **RECOMMENDED SOLUTION:**"
echo "1. Download: nxcore-ca.crt (CA certificate)"
echo "2. Open: certlm.msc (Windows Certificate Manager)"
echo "3. Import to: Trusted Root Certification Authorities"
echo "4. Restart browser"
echo ""
echo "📖 **Installation Guide:** $BACKUP_DIR/COMPREHENSIVE-CERTIFICATE-FIX.md"
echo ""
success "Certificate troubleshooting complete! 🎉"
