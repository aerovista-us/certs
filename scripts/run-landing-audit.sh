#!/usr/bin/env bash
set -euo pipefail

# Run comprehensive landing page audit with Playwright
# Tests all service links and generates fix recommendations

REPO_DIR="/srv/core/nxcore"
TEST_DIR="$REPO_DIR/tests"
RESULTS_DIR="$REPO_DIR/test-results"

echo "🔍 Starting NXCore Landing Page Service Audit..."

# Create results directory
mkdir -p "$RESULTS_DIR"

# Install Playwright if not already installed
if ! command -v npx &> /dev/null; then
    echo "❌ npx not found. Please install Node.js and npm first."
    exit 1
fi

# Install Playwright browsers if needed
echo "📦 Installing Playwright browsers..."
cd "$TEST_DIR"
npx playwright install chromium

# Run the audit test
echo "🧪 Running service audit tests..."
npx playwright test landing-page-audit.spec.ts --reporter=html

# Check if report was generated
if [ -f "$RESULTS_DIR/landing-page-audit-report.html" ]; then
    echo "✅ Audit report generated: $RESULTS_DIR/landing-page-audit-report.html"
else
    echo "⚠️ HTML report not found, checking for other outputs..."
fi

# Generate fix recommendations
echo "🔧 Generating fix recommendations..."

cat > "$RESULTS_DIR/fix-recommendations.md" << 'EOF'
# NXCore Service Fix Recommendations

## Quick Fixes

### 1. Fix Traefik Routing Issues
```bash
# Deploy Traefik routing fixes
sudo /srv/core/fix-traefik-routing.sh
```

### 2. Fix Authelia Authentication
```bash
# Deploy Authelia routing fixes
sudo /srv/core/fix-authelia-routing.sh
```

### 3. Fix OpenWebUI AI Service
```bash
# Deploy OpenWebUI routing fixes
sudo /srv/core/fix-openwebui-routing.sh
```

### 4. Check All Services Status
```bash
# Check container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check Traefik routing
curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[].rule'

# Check service health
curl -k https://nxcore.tail79107c.ts.net/grafana/api/health
curl -k https://nxcore.tail79107c.ts.net/prometheus/-/healthy
curl -k https://nxcore.tail79107c.ts.net/portainer/api/status
```

## Service-Specific Fixes

### Grafana Issues
- Check if Grafana container is running
- Verify database connectivity
- Check configuration files

### Prometheus Issues
- Verify Prometheus configuration
- Check target discovery
- Ensure metrics collection is working

### Portainer Issues
- Check Docker socket access
- Verify authentication configuration
- Ensure proper network connectivity

### AI Service Issues
- Verify Ollama is running
- Check OpenWebUI configuration
- Ensure proper base path routing

### FileBrowser Issues
- Check file system permissions
- Verify volume mounts
- Ensure proper authentication

## Network and SSL Issues

### Certificate Problems
```bash
# Regenerate certificates
sudo /srv/core/scripts/generate-selfsigned-certs.ps1
sudo /srv/core/scripts/deploy-selfsigned-certs.ps1
```

### Network Connectivity
```bash
# Check network connectivity
docker network ls
docker network inspect gateway
docker network inspect backend
```

## Monitoring and Alerts

### Set up monitoring
```bash
# Enable service monitoring
sudo systemctl enable ai-monitor.timer
sudo systemctl start ai-monitor.timer

# Check service logs
journalctl -u exchange-inbox.service -f
journalctl -u exchange-outbox.service -f
```

## Prevention

### Regular Health Checks
- Set up automated testing
- Monitor service logs
- Check resource usage
- Verify SSL certificates

### Documentation Updates
- Update service documentation
- Create troubleshooting guides
- Maintain service status pages
EOF

echo "📋 Fix recommendations saved to: $RESULTS_DIR/fix-recommendations.md"

# Show summary
echo ""
echo "📊 AUDIT SUMMARY"
echo "================"
echo "Test results: $RESULTS_DIR/"
echo "HTML report: $RESULTS_DIR/landing-page-audit-report.html"
echo "Fix recommendations: $RESULTS_DIR/fix-recommendations.md"
echo ""
echo "🔍 To view results:"
echo "  cat $RESULTS_DIR/fix-recommendations.md"
echo "  open $RESULTS_DIR/landing-page-audit-report.html"
echo ""
echo "🚀 To apply fixes:"
echo "  sudo /srv/core/fix-traefik-routing.sh"
echo "  sudo /srv/core/fix-authelia-routing.sh"
echo "  sudo /srv/core/fix-openwebui-routing.sh"
