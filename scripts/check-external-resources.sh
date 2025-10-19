#!/bin/bash
# Check External Resource Dependencies
# Identify external CDN dependencies, API calls, and asset references

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

log "🔍 CHECKING EXTERNAL RESOURCE DEPENDENCIES"
log "📋 Identifying external CDN dependencies and API calls"
log "🌐 Tailscale Network: nxcore.tail79107c.ts.net"
log "🎯 Target: Find external resources that might be causing issues"

# Configuration
SERVER_USER="glyph"
SERVER_HOST="100.115.9.61"
DOMAIN="nxcore.tail79107c.ts.net"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Phase 1: Check landing page for external resources
log "🔍 Phase 1: Checking landing page for external resources..."

mkdir -p "$BACKUP_DIR"

# Check landing page HTML for external resources
log "📄 Analyzing landing page HTML for external resources..."
curl -k -s https://nxcore.tail79107c.ts.net/ > "$BACKUP_DIR/landing-page.html" 2>/dev/null || echo "Failed to fetch landing page"

# Extract external resources from landing page
log "🔍 Extracting external resources from landing page..."
grep -E "(http://|https://|cdn\.|googleapis\.|jsdelivr\.|unpkg\.|cdnjs\.)" "$BACKUP_DIR/landing-page.html" 2>/dev/null | head -20 || echo "No external resources found in landing page"

# Phase 2: Check service containers for external dependencies
log "🔍 Phase 2: Checking service containers for external dependencies..."

# Check each service for external resource usage
services=("grafana" "n8n" "openwebui" "portainer" "filebrowser" "authelia")

for service in "${services[@]}"; do
    log "🔍 Checking $service for external dependencies..."
    
    # Get service HTML content
    case $service in
        "grafana")
            curl -k -s https://nxcore.tail79107c.ts.net/grafana/ > "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "Failed to fetch $service"
            ;;
        "n8n")
            curl -k -s https://nxcore.tail79107c.ts.net/n8n/ > "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "Failed to fetch $service"
            ;;
        "openwebui")
            curl -k -s https://nxcore.tail79107c.ts.net/ai/ > "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "Failed to fetch $service"
            ;;
        "portainer")
            curl -k -s https://nxcore.tail79107c.ts.net/portainer/ > "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "Failed to fetch $service"
            ;;
        "filebrowser")
            curl -k -s https://nxcore.tail79107c.ts.net/files/ > "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "Failed to fetch $service"
            ;;
        "authelia")
            curl -k -s https://nxcore.tail79107c.ts.net/auth/ > "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "Failed to fetch $service"
            ;;
    esac
    
    # Extract external resources
    if [ -f "$BACKUP_DIR/${service}-page.html" ]; then
        log "📊 External resources found in $service:"
        grep -E "(http://|https://|cdn\.|googleapis\.|jsdelivr\.|unpkg\.|cdnjs\.)" "$BACKUP_DIR/${service}-page.html" 2>/dev/null | head -10 || echo "No external resources found in $service"
    fi
done

# Phase 3: Check server-side container configurations
log "🔍 Phase 3: Checking server-side container configurations..."

# Check container environment variables for external dependencies
ssh $SERVER_USER@$SERVER_HOST << 'EOF'
echo "🔍 Checking container environment variables for external dependencies..."

# Check Grafana
echo "📊 Grafana environment:"
docker exec grafana env 2>/dev/null | grep -E "(GF_|GRAFANA_|EXTERNAL|CDN|API)" | head -10 || echo "No external dependencies found in Grafana"

# Check n8n
echo "📊 n8n environment:"
docker exec n8n env 2>/dev/null | grep -E "(N8N_|EXTERNAL|CDN|API)" | head -10 || echo "No external dependencies found in n8n"

# Check OpenWebUI
echo "📊 OpenWebUI environment:"
docker exec openwebui env 2>/dev/null | grep -E "(OPENWEBUI_|EXTERNAL|CDN|API)" | head -10 || echo "No external dependencies found in OpenWebUI"

# Check Portainer
echo "📊 Portainer environment:"
docker exec portainer env 2>/dev/null | grep -E "(PORTAINER_|EXTERNAL|CDN|API)" | head -10 || echo "No external dependencies found in Portainer"
EOF

# Phase 4: Check for specific external resource patterns
log "🔍 Phase 4: Checking for specific external resource patterns..."

# Common external resource patterns
external_patterns=(
    "cdn.tailwindcss.com"
    "cdnjs.cloudflare.com"
    "unpkg.com"
    "jsdelivr.net"
    "googleapis.com"
    "fonts.googleapis.com"
    "fonts.gstatic.com"
    "ajax.googleapis.com"
    "cdn.jsdelivr.net"
    "stackpath.bootstrapcdn.com"
    "maxcdn.bootstrapcdn.com"
    "cdn.jsdelivr.net"
)

log "🔍 Checking for common external CDN dependencies..."
for pattern in "${external_patterns[@]}"; do
    log "🔍 Checking for $pattern..."
    found=false
    
    # Check landing page
    if grep -q "$pattern" "$BACKUP_DIR/landing-page.html" 2>/dev/null; then
        warning "Found $pattern in landing page"
        found=true
    fi
    
    # Check service pages
    for service in "${services[@]}"; do
        if [ -f "$BACKUP_DIR/${service}-page.html" ] && grep -q "$pattern" "$BACKUP_DIR/${service}-page.html" 2>/dev/null; then
            warning "Found $pattern in $service"
            found=true
        fi
    done
    
    if [ "$found" = false ]; then
        success "No $pattern dependencies found"
    fi
done

# Phase 5: Generate external resources report
log "📊 Phase 5: Generating external resources report..."

cat > "$BACKUP_DIR/external-resources-report.md" << EOF
# 🔍 External Resources Dependencies Report

**Date**: $(date)
**Status**: 🔍 **EXTERNAL RESOURCES ANALYSIS COMPLETE**

## 🔍 **External Resources Analysis**

### **Landing Page External Resources**:
$(grep -E "(http://|https://|cdn\.|googleapis\.|jsdelivr\.|unpkg\.|cdnjs\.)" "$BACKUP_DIR/landing-page.html" 2>/dev/null | head -10 || echo "No external resources found in landing page")

### **Service External Resources**:
EOF

# Add service-specific external resources to report
for service in "${services[@]}"; do
    if [ -f "$BACKUP_DIR/${service}-page.html" ]; then
        echo "#### **$service External Resources**:" >> "$BACKUP_DIR/external-resources-report.md"
        grep -E "(http://|https://|cdn\.|googleapis\.|jsdelivr\.|unpkg\.|cdnjs\.)" "$BACKUP_DIR/${service}-page.html" 2>/dev/null | head -5 >> "$BACKUP_DIR/external-resources-report.md" || echo "No external resources found in $service" >> "$BACKUP_DIR/external-resources-report.md"
        echo "" >> "$BACKUP_DIR/external-resources-report.md"
    fi
done

cat >> "$BACKUP_DIR/external-resources-report.md" << EOF

## 🚨 **Potential Issues Identified**

### **External CDN Dependencies**:
- **Problem**: Services may be trying to load external resources
- **Impact**: 404 errors for external assets
- **Solution**: Configure services to use local assets

### **External API Calls**:
- **Problem**: Services may be making external API calls
- **Impact**: Network timeouts or blocked requests
- **Solution**: Configure services to use local APIs

### **External Font Dependencies**:
- **Problem**: Services may be loading external fonts
- **Impact**: Slow loading or missing fonts
- **Solution**: Host fonts locally

## 🔧 **Recommended Solutions**

### **1. Local Asset Hosting**:
- **Host external assets locally**
- **Configure services to use local assets**
- **Update service configurations**

### **2. Network Configuration**:
- **Check firewall rules**
- **Verify DNS resolution**
- **Test external connectivity**

### **3. Service Configuration**:
- **Update service environment variables**
- **Configure local asset paths**
- **Disable external dependencies**

## 📊 **Next Steps**

1. **Review external resources found**
2. **Configure services to use local assets**
3. **Test service functionality**
4. **Monitor for remaining issues**

---
**External resources analysis complete!** 🔍
EOF

success "External resources report generated: $BACKUP_DIR/external-resources-report.md"

# Phase 6: Check for specific problematic patterns
log "🔍 Phase 6: Checking for specific problematic patterns..."

# Check for Tailwind CSS CDN usage (mentioned in user's error)
log "🔍 Checking for Tailwind CSS CDN usage..."
if grep -q "cdn.tailwindcss.com" "$BACKUP_DIR/landing-page.html" 2>/dev/null; then
    warning "Found Tailwind CSS CDN usage in landing page"
    echo "📋 Tailwind CSS CDN references:"
    grep -n "cdn.tailwindcss.com" "$BACKUP_DIR/landing-page.html" 2>/dev/null || echo "No Tailwind CSS CDN references found"
else
    success "No Tailwind CSS CDN usage found in landing page"
fi

# Check for other common problematic patterns
problematic_patterns=(
    "cdn.tailwindcss.com"
    "fonts.googleapis.com"
    "fonts.gstatic.com"
    "ajax.googleapis.com"
)

log "🔍 Checking for problematic external resource patterns..."
for pattern in "${problematic_patterns[@]}"; do
    found_count=0
    
    # Count occurrences in landing page
    if [ -f "$BACKUP_DIR/landing-page.html" ]; then
        count=$(grep -c "$pattern" "$BACKUP_DIR/landing-page.html" 2>/dev/null || echo "0")
        found_count=$((found_count + count))
    fi
    
    # Count occurrences in service pages
    for service in "${services[@]}"; do
        if [ -f "$BACKUP_DIR/${service}-page.html" ]; then
            count=$(grep -c "$pattern" "$BACKUP_DIR/${service}-page.html" 2>/dev/null || echo "0")
            found_count=$((found_count + count))
        fi
    done
    
    if [ $found_count -gt 0 ]; then
        warning "Found $found_count occurrences of $pattern"
    else
        success "No $pattern dependencies found"
    fi
done

# Final status
log "🎉 EXTERNAL RESOURCES ANALYSIS COMPLETE!"
log "🔍 External resource dependencies analyzed"
log "📊 Report generated with findings"
log "📁 Analysis saved at: $BACKUP_DIR"

success "External resources analysis complete! 🎉"

# Display final summary
echo ""
echo "🔍 **EXTERNAL RESOURCES ANALYSIS SUMMARY**"
echo "========================================"
echo "✅ Landing page external resources analyzed"
echo "✅ Service external resources analyzed"
echo "✅ Container environment variables checked"
echo "✅ Common external CDN patterns checked"
echo ""
echo "📊 **Key Findings:**"
echo "   - External resource dependencies identified"
echo "   - CDN usage patterns analyzed"
echo "   - Service configurations checked"
echo ""
echo "📖 **Detailed Report:** $BACKUP_DIR/external-resources-report.md"
echo ""
echo "🎯 **Next Step:** Review the report to identify external dependencies!"
success "External resources analysis complete! 🎉"
