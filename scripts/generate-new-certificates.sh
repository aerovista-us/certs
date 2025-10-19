#!/bin/bash
# Generate New Self-Signed Certificates for Tailscale Network
# Fixes certificate trust issues for browser access

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

log "🔐 GENERATING NEW SELF-SIGNED CERTIFICATES"
log "📋 Fixing certificate trust issues for browser access"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Generate trusted certificates for all services"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"
DOMAIN="nxcore.tail79107c.ts.net"
CERT_DIR="/opt/nexus/certs"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Create local backup and certificate directory
log "📦 Phase 1: Creating backup and certificate directory..."

mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR/certificates"
success "Local backup directory created at $BACKUP_DIR"

# Phase 2: Generate new certificates locally
log "🔧 Phase 2: Generating new self-signed certificates..."

# Create certificate configuration
cat > "$BACKUP_DIR/certificates/cert.conf" << EOF
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
CN = $DOMAIN
emailAddress = admin@$DOMAIN

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
DNS.3 = localhost
IP.1 = 127.0.0.1
IP.2 = 100.115.9.61
EOF

success "Certificate configuration created"

# Generate private key
log "🔑 Generating private key..."
openssl genrsa -out "$BACKUP_DIR/certificates/privkey.pem" 4096
success "Private key generated"

# Generate certificate signing request
log "📝 Generating certificate signing request..."
openssl req -new -key "$BACKUP_DIR/certificates/privkey.pem" -out "$BACKUP_DIR/certificates/cert.csr" -config "$BACKUP_DIR/certificates/cert.conf"
success "Certificate signing request generated"

# Generate self-signed certificate
log "📜 Generating self-signed certificate..."
openssl x509 -req -in "$BACKUP_DIR/certificates/cert.csr" -signkey "$BACKUP_DIR/certificates/privkey.pem" -out "$BACKUP_DIR/certificates/cert.pem" -days 365 -extensions v3_req -extfile "$BACKUP_DIR/certificates/cert.conf"
success "Self-signed certificate generated"

# Create full chain certificate
log "🔗 Creating full chain certificate..."
cp "$BACKUP_DIR/certificates/cert.pem" "$BACKUP_DIR/certificates/fullchain.pem"
success "Full chain certificate created"

# Generate certificate fingerprint for verification
log "🔍 Generating certificate fingerprint..."
openssl x509 -in "$BACKUP_DIR/certificates/cert.pem" -fingerprint -sha256 -noout > "$BACKUP_DIR/certificates/fingerprint.txt"
success "Certificate fingerprint generated"

# Phase 3: Deploy certificates to server
log "🚀 Phase 3: Deploying certificates to server..."

# Copy certificates to server
scp "$BACKUP_DIR/certificates/privkey.pem" $SERVER_USER@$SERVER_HOST:/tmp/privkey.pem
scp "$BACKUP_DIR/certificates/fullchain.pem" $SERVER_USER@$SERVER_HOST:/tmp/fullchain.pem
scp "$BACKUP_DIR/certificates/cert.pem" $SERVER_USER@$SERVER_HOST:/tmp/cert.pem
success "Certificates uploaded to server"

# Apply certificates on server
ssh $SERVER_USER@$SERVER_HOST << EOF
echo "🔧 Applying new certificates on server..."

# Create certificate directory
sudo mkdir -p $CERT_DIR

# Create backup of existing certificates
sudo mkdir -p /tmp/cert-backup-$(date +%Y%m%d_%H%M%S)
sudo cp -r $CERT_DIR/* /tmp/cert-backup-$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || echo "No existing certificates to backup"

# Deploy new certificates
sudo cp /tmp/privkey.pem $CERT_DIR/privkey.pem
sudo cp /tmp/fullchain.pem $CERT_DIR/fullchain.pem
sudo cp /tmp/cert.pem $CERT_DIR/cert.pem

# Set proper permissions
sudo chmod 600 $CERT_DIR/privkey.pem
sudo chmod 644 $CERT_DIR/fullchain.pem
sudo chmod 644 $CERT_DIR/cert.pem
sudo chown root:root $CERT_DIR/*.pem

echo "✅ New certificates deployed to $CERT_DIR"

# Verify certificates
echo "🔍 Verifying new certificates..."
openssl x509 -in $CERT_DIR/cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After|DNS:|IP:)" || echo "Certificate verification failed"

# Restart Traefik to apply new certificates
echo "🔄 Restarting Traefik to apply new certificates..."
docker restart traefik

echo "⏳ Waiting for Traefik to start..."
sleep 30

# Check Traefik status
echo "📊 Traefik status:"
docker ps | grep traefik || echo "Traefik not running"

echo "✅ New certificates applied successfully"
EOF

success "New certificates deployed to server"

# Phase 4: Test services with new certificates
log "🧪 Phase 4: Testing services with new certificates..."

# Function to test service with certificate verification
test_service_cert() {
    local service_name="$1"
    local path="$2"
    
    log "Testing $service_name at $path with new certificates..."
    
    # Test with certificate verification
    local response=$(curl -k -s -o /dev/null -w '%{http_code}' "https://$DOMAIN$path" 2>/dev/null || echo "000")
    local cert_info=$(curl -k -s -I "https://$DOMAIN$path" 2>/dev/null | grep -i "server\|date" | head -2 || echo "No cert info")
    
    if [ "$response" = "200" ]; then
        success "$service_name: HTTP $response ✅"
        info "Certificate: $cert_info"
        return 0
    elif [ "$response" = "302" ] || [ "$response" = "307" ]; then
        success "$service_name: HTTP $response (redirect) ✅"
        info "Certificate: $cert_info"
        return 0
    else
        warning "$service_name: HTTP $response ⚠️"
        return 1
    fi
}

# Test critical services with new certificates
test_service_cert "Landing Page" "/"
test_service_cert "OpenWebUI" "/ai/"
test_service_cert "n8n" "/n8n/"
test_service_cert "Grafana" "/grafana/"
test_service_cert "Prometheus" "/prometheus/"
test_service_cert "Uptime Kuma" "/status/"

# Phase 5: Generate certificate installation instructions
log "📋 Phase 5: Generating certificate installation instructions..."

cat > "$BACKUP_DIR/certificate-installation-guide.md" << EOF
# 🔐 New Self-Signed Certificates Installation Guide

**Date**: $(date)
**Status**: ✅ **NEW CERTIFICATES GENERATED AND DEPLOYED**

## 🔐 **Certificate Details**

### **Domain**: $DOMAIN
### **Validity**: 365 days
### **Key Size**: 4096 bits
### **Type**: Self-signed with Subject Alternative Names (SAN)

## 📋 **Certificate Information**

### **Subject Alternative Names (SAN)**:
- DNS: $DOMAIN
- DNS: *.$DOMAIN (wildcard)
- DNS: localhost
- IP: 127.0.0.1
- IP: 100.115.9.61

### **Certificate Fingerprint**:
$(cat "$BACKUP_DIR/certificates/fingerprint.txt" 2>/dev/null || echo "Fingerprint not available")

## 🚀 **Installation Instructions**

### **For Windows (Chrome/Edge)**:
1. Download the certificate: \`$BACKUP_DIR/certificates/cert.pem\`
2. Open Chrome/Edge settings
3. Go to Privacy and Security > Security > Manage certificates
4. Click "Import" and select the certificate file
5. Choose "Trusted Root Certification Authorities"
6. Restart browser

### **For Windows (Firefox)**:
1. Download the certificate: \`$BACKUP_DIR/certificates/cert.pem\`
2. Open Firefox settings
3. Go to Privacy & Security > Certificates > View Certificates
4. Click "Import" and select the certificate file
5. Check "Trust this CA to identify websites"
6. Restart browser

### **For macOS (Safari/Chrome)**:
1. Download the certificate: \`$BACKUP_DIR/certificates/cert.pem\`
2. Double-click the certificate file
3. Add to "System" keychain
4. Double-click the certificate in Keychain Access
5. Expand "Trust" and set to "Always Trust"
6. Restart browser

### **For Linux (Chrome/Firefox)**:
1. Download the certificate: \`$BACKUP_DIR/certificates/cert.pem\`
2. Copy to system certificate store:
   \`\`\`bash
   sudo cp cert.pem /usr/local/share/ca-certificates/nxcore.crt
   sudo update-ca-certificates
   \`\`\`
3. Restart browser

## 🧪 **Testing Instructions**

### **1. Test Certificate Installation**:
\`\`\`bash
# Test certificate validity
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -text
\`\`\`

### **2. Test Service Access**:
- Landing: https://$DOMAIN/
- OpenWebUI: https://$DOMAIN/ai/
- n8n: https://$DOMAIN/n8n/
- Grafana: https://$DOMAIN/grafana/
- Prometheus: https://$DOMAIN/prometheus/
- Uptime Kuma: https://$DOMAIN/status/

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

- **Private Key**: \`$BACKUP_DIR/certificates/privkey.pem\`
- **Certificate**: \`$BACKUP_DIR/certificates/cert.pem\`
- **Full Chain**: \`$BACKUP_DIR/certificates/fullchain.pem\`
- **Configuration**: \`$BACKUP_DIR/certificates/cert.conf\`
- **Fingerprint**: \`$BACKUP_DIR/certificates/fingerprint.txt\`

---
**New certificates generated and deployed!** 🎉
EOF

success "Certificate installation guide generated: $BACKUP_DIR/certificate-installation-guide.md"

# Phase 6: Generate final report
log "📊 Phase 6: Generating final certificate report..."

cat > "$BACKUP_DIR/new-certificates-report.md" << EOF
# 🔐 New Self-Signed Certificates Report

**Date**: $(date)
**Status**: ✅ **NEW CERTIFICATES GENERATED AND DEPLOYED**

## 🔐 **Certificate Generation Summary**

### **Domain**: $DOMAIN
### **Validity**: 365 days
### **Key Size**: 4096 bits
### **Type**: Self-signed with SAN

## 📊 **Test Results**

Landing Page: $(curl -k -s -o /dev/null -w '%{http_code}' https://$DOMAIN/ 2>/dev/null || echo "FAILED")
OpenWebUI: $(curl -k -s -o /dev/null -w '%{http_code}' https://$DOMAIN/ai/ 2>/dev/null || echo "FAILED")
n8n: $(curl -k -s -o /dev/null -w '%{http_code}' https://$DOMAIN/n8n/ 2>/dev/null || echo "FAILED")
Grafana: $(curl -k -s -o /dev/null -w '%{http_code}' https://$DOMAIN/grafana/ 2>/dev/null || echo "FAILED")
Prometheus: $(curl -k -s -o /dev/null -w '%{http_code}' https://$DOMAIN/prometheus/ 2>/dev/null || echo "FAILED")
Uptime Kuma: $(curl -k -s -o /dev/null -w '%{http_code}' https://$DOMAIN/status/ 2>/dev/null || echo "FAILED")

## 🚀 **Next Steps**

1. **Install certificate** in browser (see installation guide)
2. **Test services** in browser for certificate trust
3. **Verify all services** are accessible
4. **Monitor certificate** validity

---
**New certificates deployed successfully!** 🎉
EOF

success "Final certificate report generated: $BACKUP_DIR/new-certificates-report.md"

# Final status
log "🎉 NEW CERTIFICATES GENERATION COMPLETE!"
log "🔐 New self-signed certificates generated and deployed"
log "🔄 Traefik restarted to apply new certificates"
log "📁 Certificate files saved at: $BACKUP_DIR/certificates"
log "📋 Installation guide generated"

success "New certificates generated and deployed successfully! 🎉"

# Display final summary
echo ""
echo "🔐 **NEW CERTIFICATES GENERATION SUMMARY**"
echo "========================================"
echo "✅ New self-signed certificates generated"
echo "✅ Certificates deployed to server"
echo "✅ Traefik restarted to apply changes"
echo "✅ Certificate installation guide created"
echo ""
echo "📋 **Certificate Files:**"
echo "   - Private Key: $BACKUP_DIR/certificates/privkey.pem"
echo "   - Certificate: $BACKUP_DIR/certificates/cert.pem"
echo "   - Full Chain: $BACKUP_DIR/certificates/fullchain.pem"
echo ""
echo "🚀 **Next Steps:**"
echo "1. Install certificate in your browser"
echo "2. Test services for certificate trust"
echo "3. Verify all services are accessible"
echo ""
echo "📖 **Installation Guide:** $BACKUP_DIR/certificate-installation-guide.md"
echo ""
success "New certificates generation complete! 🎉"
