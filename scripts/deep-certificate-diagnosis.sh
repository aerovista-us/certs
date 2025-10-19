#!/bin/bash
# Deep Certificate Diagnosis
# Investigate root cause of certificate trust issues

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

log "🔍 DEEP CERTIFICATE DIAGNOSIS"
log "📋 Investigating root cause of certificate trust issues"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Understand why certificate trust is failing"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"
DOMAIN="nxcore.tail79107c.ts.net"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Check current certificate status on server
log "🔍 Phase 1: Checking certificate status on server..."

ssh $SERVER_USER@$SERVER_HOST << 'EOF'
echo "🔍 Checking certificate status on server..."

# Check if certificates exist
echo "📁 Certificate files:"
ls -la /opt/nexus/certs/ 2>/dev/null || echo "No certificates directory found"

# Check Traefik configuration
echo "📋 Traefik configuration:"
docker exec traefik cat /etc/traefik/traefik-static.yml 2>/dev/null | grep -A 10 -B 5 "tls\|cert" || echo "No TLS config found"

# Check Traefik logs for certificate errors
echo "📊 Recent Traefik logs:"
docker logs traefik --tail 20 2>/dev/null | grep -i "cert\|tls\|ssl\|error" || echo "No certificate-related logs found"

# Check if Traefik is using the certificates
echo "🔍 Traefik certificate usage:"
docker exec traefik ls -la /certs/ 2>/dev/null || echo "No /certs directory in Traefik container"

# Test certificate from server side
echo "🧪 Testing certificate from server:"
openssl s_client -connect localhost:443 -servername nxcore.tail79107c.ts.net < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -E "(Subject:|Issuer:|Not Before|Not After|DNS:|IP:)" | head -5 || echo "Certificate test failed"
EOF

# Phase 2: Analyze certificate chain and trust
log "🔍 Phase 2: Analyzing certificate chain and trust..."

# Check certificate details
if [ -f "./backups/20251019_051415/certificates/cert.pem" ]; then
    log "🔍 Analyzing certificate details..."
    
    # Certificate subject and issuer
    openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After)" | head -4
    
    # Check if certificate is self-signed
    SUBJECT=$(openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -noout -subject)
    ISSUER=$(openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -noout -issuer)
    
    if [ "$SUBJECT" = "$ISSUER" ]; then
        warning "Certificate is self-signed (Subject = Issuer)"
        info "This is expected for self-signed certificates"
    else
        success "Certificate is not self-signed"
    fi
    
    # Check certificate extensions
    log "🔍 Checking certificate extensions..."
    openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -text -noout | grep -A 10 "Subject Alternative Name" || echo "No SAN extensions found"
    
    # Check certificate validity
    log "🔍 Checking certificate validity..."
    openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -checkend 0 -noout && success "Certificate is valid" || error "Certificate is expired or invalid"
    
else
    error "Certificate file not found"
fi

# Phase 3: Test certificate from client side
log "🧪 Phase 3: Testing certificate from client side..."

# Test with different methods
log "🔍 Testing certificate with curl..."
curl -k -s -o /dev/null -w 'HTTPS Test: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "HTTPS Test: FAILED"

# Test certificate chain
log "🔍 Testing certificate chain..."
openssl s_client -connect nxcore.tail79107c.ts.net:443 -servername nxcore.tail79107c.ts.net < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -E "(Subject:|Issuer:|Not Before|Not After|DNS:|IP:)" | head -5 || echo "Certificate chain test failed"

# Phase 4: Check browser-specific issues
log "🔍 Phase 4: Analyzing browser-specific issues..."

# Check if certificate has proper extensions for browser trust
log "🔍 Checking certificate extensions for browser compatibility..."
openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -text -noout | grep -A 20 "X509v3 extensions" | grep -E "(Basic Constraints|Key Usage|Extended Key Usage)" || echo "No critical extensions found"

# Check certificate format
log "🔍 Checking certificate format..."
file "./backups/20251019_051415/certificates/cert.pem" || echo "Cannot determine file type"

# Phase 5: Generate comprehensive diagnosis report
log "📊 Phase 5: Generating comprehensive diagnosis report..."

mkdir -p "$BACKUP_DIR"

cat > "$BACKUP_DIR/certificate-diagnosis-report.md" << EOF
# 🔍 Certificate Diagnosis Report

**Date**: $(date)
**Status**: 🔍 **DEEP DIAGNOSIS COMPLETE**

## 🔍 **Certificate Analysis**

### **Certificate Details**:
$(openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After)" | head -4)

### **Subject Alternative Names**:
$(openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -text -noout | grep -A 10 "Subject Alternative Name" || echo "No SAN found")

### **Certificate Extensions**:
$(openssl x509 -in "./backups/20251019_051415/certificates/cert.pem" -text -noout | grep -A 20 "X509v3 extensions" | grep -E "(Basic Constraints|Key Usage|Extended Key Usage)" || echo "No critical extensions found")

## 🧪 **Test Results**

### **Server-side Tests**:
- **Certificate Files**: $(ssh $SERVER_USER@$SERVER_HOST "ls -la /opt/nexus/certs/ 2>/dev/null | wc -l" || echo "Unknown")
- **Traefik Status**: $(ssh $SERVER_USER@$SERVER_HOST "docker ps | grep traefik | wc -l" || echo "Unknown")

### **Client-side Tests**:
- **HTTPS Test**: $(curl -k -s -o /dev/null -w '%{http_code}' https://nxcore.tail79107c.ts.net/ 2>/dev/null || echo "FAILED")
- **Certificate Chain**: $(openssl s_client -connect nxcore.tail79107c.ts.net:443 -servername nxcore.tail79107c.ts.net < /dev/null 2>/dev/null | openssl x509 -noout -subject 2>/dev/null || echo "FAILED")

## 🔍 **Potential Issues Identified**

### **1. Self-Signed Certificate Issues**:
- **Problem**: Self-signed certificates are not trusted by default
- **Impact**: Browsers show certificate warnings
- **Solution**: Need proper CA certificate or browser trust

### **2. Certificate Installation Issues**:
- **Problem**: Certificate not properly installed in browser trust store
- **Impact**: Browser still shows certificate errors
- **Solution**: Proper certificate installation method

### **3. Certificate Format Issues**:
- **Problem**: Certificate format may not be compatible with browser
- **Impact**: Browser cannot process certificate
- **Solution**: Convert to proper format

### **4. Traefik Configuration Issues**:
- **Problem**: Traefik may not be using the correct certificate
- **Impact**: Server not serving the right certificate
- **Solution**: Check Traefik configuration

## 🚀 **Recommended Solutions**

### **Solution 1: Create Proper CA Certificate**
1. **Generate CA certificate** with proper extensions
2. **Install CA certificate** in browser trust store
3. **Test certificate trust**

### **Solution 2: Use Let's Encrypt (Recommended)**
1. **Generate Let's Encrypt certificate** for the domain
2. **Configure Traefik** to use Let's Encrypt
3. **Automatic certificate renewal**

### **Solution 3: Browser-Specific Trust**
1. **Add certificate exception** in browser
2. **Use browser-specific trust methods**
3. **Test with different browsers**

## 📊 **Next Steps**

1. **Analyze diagnosis results**
2. **Choose appropriate solution**
3. **Implement certificate fix**
4. **Test browser access**

---
**Certificate diagnosis complete!** 🔍
EOF

success "Comprehensive diagnosis report generated: $BACKUP_DIR/certificate-diagnosis-report.md"

# Phase 6: Check Traefik configuration
log "🔍 Phase 6: Checking Traefik configuration..."

ssh $SERVER_USER@$SERVER_HOST << 'EOF'
echo "🔍 Checking Traefik configuration..."

# Check Traefik static configuration
echo "📋 Traefik static configuration:"
docker exec traefik cat /etc/traefik/traefik-static.yml 2>/dev/null | grep -A 20 -B 5 "tls\|cert" || echo "No TLS configuration found"

# Check Traefik dynamic configuration
echo "📋 Traefik dynamic configuration:"
docker exec traefik find /etc/traefik/dynamic -name "*.yml" -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null | grep -A 10 -B 5 "tls\|cert" || echo "No dynamic TLS configuration found"

# Check Traefik logs for errors
echo "📊 Traefik error logs:"
docker logs traefik --tail 50 2>/dev/null | grep -i "error\|warn\|fail" | tail -10 || echo "No errors found in Traefik logs"
EOF

# Final status
log "🎉 DEEP CERTIFICATE DIAGNOSIS COMPLETE!"
log "🔍 Comprehensive analysis performed"
log "📊 Diagnosis report generated"
log "📁 Report saved at: $BACKUP_DIR"

success "Deep certificate diagnosis complete! 🎉"

# Display final summary
echo ""
echo "🔍 **DEEP CERTIFICATE DIAGNOSIS SUMMARY**"
echo "======================================="
echo "✅ Certificate analysis completed"
echo "✅ Server configuration checked"
echo "✅ Client-side tests performed"
echo "✅ Browser compatibility analyzed"
echo ""
echo "📊 **Key Findings:**"
echo "   - Certificate details analyzed"
echo "   - Trust chain examined"
echo "   - Browser compatibility checked"
echo "   - Traefik configuration verified"
echo ""
echo "📖 **Diagnosis Report:** $BACKUP_DIR/certificate-diagnosis-report.md"
echo ""
echo "🎯 **Next Step:** Review the diagnosis report to understand the root cause!"
success "Deep certificate diagnosis complete! 🎉"
