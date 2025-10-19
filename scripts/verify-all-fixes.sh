#!/usr/bin/env bash
set -euo pipefail

# Comprehensive Fix Verification Script
# Reviews entire thread and verifies all fixes are properly deployed

REPO_DIR="/srv/core/nxcore"
CORE_DIR="/srv/core"

echo "🔍 NXCore Complete Fix Verification"
echo "===================================="
echo "Reviewing all fixes and patches from the entire thread..."
echo ""

# Initialize verification results
declare -A VERIFICATION_RESULTS
TOTAL_FIXES=0
IMPLEMENTED_FIXES=0
MISSING_FIXES=0

# Function to check and record fix status
check_fix() {
    local fix_name="$1"
    local check_command="$2"
    local fix_description="$3"
    
    TOTAL_FIXES=$((TOTAL_FIXES + 1))
    
    if eval "$check_command"; then
        VERIFICATION_RESULTS["$fix_name"]="✅ IMPLEMENTED"
        IMPLEMENTED_FIXES=$((IMPLEMENTED_FIXES + 1))
        echo "✅ $fix_name: $fix_description"
    else
        VERIFICATION_RESULTS["$fix_name"]="❌ MISSING"
        MISSING_FIXES=$((MISSING_FIXES + 1))
        echo "❌ $fix_name: $fix_description"
    fi
}

echo "📋 PHASE 1: README & DOCUMENTATION FIXES"
echo "=========================================="

# 1.1 README.md conciseness fix
check_fix "README_CONCISE" \
    "[ -f '$REPO_DIR/README.md' ] && [ \$(wc -l < '$REPO_DIR/README.md') -lt 200 ]" \
    "README.md condensed to under 200 lines"

# 1.2 .gitignore GitHub prep
check_fix "GITIGNORE_GITHUB_PREP" \
    "grep -q '!state/\*\*' '$REPO_DIR/.gitignore' && grep -q '!state/outbox/\*\*' '$REPO_DIR/.gitignore'" \
    ".gitignore includes GitHub prep entries"

echo ""
echo "📋 PHASE 2: SHIPPING & RECEIVING SYSTEM"
echo "======================================="

# 2.1 Inbox watcher script
check_fix "INBOX_WATCHER" \
    "[ -f '$REPO_DIR/scripts/watch_inbox.sh' ] && [ -x '$REPO_DIR/scripts/watch_inbox.sh' ]" \
    "Inbox watcher script created and executable"

# 2.2 Outbox push script
check_fix "OUTBOX_PUSH" \
    "[ -f '$REPO_DIR/scripts/push_outbox.sh' ] && [ -x '$REPO_DIR/scripts/push_outbox.sh' ]" \
    "Outbox push script created and executable"

# 2.3 Systemd services for shipping/receiving
check_fix "EXCHANGE_SYSTEMD" \
    "[ -f '/etc/systemd/system/exchange-inbox.service' ] && [ -f '/etc/systemd/system/exchange-outbox.timer' ]" \
    "Systemd services for exchange system installed"

# 2.4 Exchange directories
check_fix "EXCHANGE_DIRS" \
    "[ -d '/srv/exchange/inbox' ] && [ -d '/srv/exchange/outbox' ] && [ -d '/srv/exchange/processing' ]" \
    "Exchange directories created"

# 2.5 n8n functions for AI processing
check_fix "N8N_AI_FUNCTIONS" \
    "[ -f '$REPO_DIR/n8n/functions/ai-csv-processor.js' ] && [ -f '$REPO_DIR/n8n/functions/ai-text-processor.js' ]" \
    "n8n AI processing functions created"

echo ""
echo "📋 PHASE 3: AI SYSTEM ENHANCEMENTS"
echo "=================================="

# 3.1 AI core script with llama3.2
check_fix "AI_CORE_LLAMA32" \
    "grep -q 'llama3.2' '$REPO_DIR/ai/ai-core.sh'" \
    "AI core script updated to use llama3.2"

# 3.2 Ollama API client
check_fix "OLLAMA_API_CLIENT" \
    "[ -f '$REPO_DIR/ai/ollama-api.sh' ] && [ -x '$REPO_DIR/ai/ollama-api.sh' ]" \
    "Ollama API client created"

# 3.3 AI processor for exchange system
check_fix "AI_PROCESSOR" \
    "[ -f '$REPO_DIR/ai/ai-processor.sh' ] && [ -x '$REPO_DIR/ai/ai-processor.sh' ]" \
    "AI processor for exchange system created"

# 3.4 AI monitoring system
check_fix "AI_MONITORING" \
    "[ -f '$REPO_DIR/ai/ai-monitor.sh' ] && [ -x '$REPO_DIR/ai/ai-monitor.sh' ]" \
    "AI monitoring system created"

# 3.5 AI systemd monitoring
check_fix "AI_SYSTEMD_MONITORING" \
    "[ -f '/etc/systemd/system/ai-monitor.timer' ]" \
    "AI monitoring systemd timer installed"

echo ""
echo "📋 PHASE 4: TRAEFIK ROUTING FIXES"
echo "================================="

# 4.1 Traefik container naming fix
check_fix "TRAEFIK_CONTAINER_NAME" \
    "docker ps --format '{{.Names}}' | grep -q '^traefik$'" \
    "Traefik container properly named"

# 4.2 Traefik API routing
check_fix "TRAEFIK_API_ROUTING" \
    "curl -s -k 'https://nxcore.tail79107c.ts.net/api/http/routers' | jq -r '.[].rule' | grep -q 'api'" \
    "Traefik API accessible"

# 4.3 Traefik dashboard routing
check_fix "TRAEFIK_DASHBOARD_ROUTING" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/dash' | head -1 | grep -q '200'" \
    "Traefik dashboard accessible"

# 4.4 Updated Traefik compose file
check_fix "TRAEFIK_COMPOSE_FIX" \
    "grep -q 'traefik-api' '$REPO_DIR/docker/compose-traefik.yml' && grep -q 'traefik-dash' '$REPO_DIR/docker/compose-traefik.yml'" \
    "Traefik compose file updated with API and dashboard routes"

echo ""
echo "📋 PHASE 5: SERVICE ROUTING FIXES"
echo "================================="

# 5.1 n8n path-based routing
check_fix "N8N_PATH_ROUTING" \
    "grep -q 'PathPrefix.*n8n' '$REPO_DIR/docker/compose-n8n.yml' && grep -q 'n8n-strip' '$REPO_DIR/docker/compose-n8n.yml'" \
    "n8n configured for path-based routing"

# 5.2 OpenWebUI path-based routing
check_fix "OPENWEBUI_PATH_ROUTING" \
    "grep -q 'PathPrefix.*ai' '$REPO_DIR/docker/compose-openwebui.yml' && grep -q 'WEBUI_BASE_PATH' '$REPO_DIR/docker/compose-openwebui.yml'" \
    "OpenWebUI configured for path-based routing with base path"

# 5.3 Authelia routing fix
check_fix "AUTHELIA_ROUTING" \
    "grep -q 'traefik.enable=true' '$REPO_DIR/docker/compose-authelia.yml' && grep -q 'PathPrefix.*auth' '$REPO_DIR/docker/compose-authelia.yml'" \
    "Authelia configured for proper routing"

echo ""
echo "📋 PHASE 6: SERVICE ACCESSIBILITY"
echo "================================"

# 6.1 Landing page
check_fix "LANDING_PAGE" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/' | head -1 | grep -q '200'" \
    "Landing page accessible"

# 6.2 Grafana
check_fix "GRAFANA_ACCESS" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/grafana/' | head -1 | grep -q '200\|302'" \
    "Grafana accessible"

# 6.3 Prometheus
check_fix "PROMETHEUS_ACCESS" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/prometheus/' | head -1 | grep -q '200\|302'" \
    "Prometheus accessible"

# 6.4 Portainer
check_fix "PORTAINER_ACCESS" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/portainer/' | head -1 | grep -q '200\|302'" \
    "Portainer accessible"

# 6.5 AI Service (OpenWebUI)
check_fix "AI_SERVICE_ACCESS" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/ai/' | head -1 | grep -q '200\|302'" \
    "AI service accessible"

# 6.6 Authelia
check_fix "AUTHELIA_ACCESS" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/auth/' | head -1 | grep -q '200\|302'" \
    "Authelia accessible"

# 6.7 n8n
check_fix "N8N_ACCESS" \
    "curl -s -k -I 'https://nxcore.tail79107c.ts.net/n8n/' | head -1 | grep -q '200\|302'" \
    "n8n accessible"

echo ""
echo "📋 PHASE 7: MONITORING & HEALTH CHECKS"
echo "======================================"

# 7.1 AI monitoring active
check_fix "AI_MONITORING_ACTIVE" \
    "systemctl is-active ai-monitor.timer >/dev/null 2>&1" \
    "AI monitoring timer active"

# 7.2 Exchange monitoring active
check_fix "EXCHANGE_MONITORING_ACTIVE" \
    "systemctl is-active exchange-outbox.timer >/dev/null 2>&1" \
    "Exchange monitoring timer active"

# 7.3 Container health
check_fix "CONTAINER_HEALTH" \
    "[ \$(docker ps --filter 'status=running' | wc -l) -gt 5 ]" \
    "Multiple containers running"

echo ""
echo "📋 PHASE 8: PLAYWRIGHT TESTING SYSTEM"
echo "====================================="

# 8.1 Playwright test suite
check_fix "PLAYWRIGHT_TESTS" \
    "[ -f '$REPO_DIR/tests/landing-page-audit.spec.ts' ]" \
    "Playwright test suite created"

# 8.2 Audit scripts
check_fix "AUDIT_SCRIPTS" \
    "[ -f '$REPO_DIR/scripts/run-landing-audit.sh' ] && [ -f '$REPO_DIR/scripts/comprehensive-service-fix.sh' ]" \
    "Audit and fix scripts created"

echo ""
echo "📊 VERIFICATION SUMMARY"
echo "======================"
echo "Total Fixes Checked: $TOTAL_FIXES"
echo "Implemented: $IMPLEMENTED_FIXES"
echo "Missing: $MISSING_FIXES"
echo ""

# Calculate percentage
if [ $TOTAL_FIXES -gt 0 ]; then
    PERCENTAGE=$((IMPLEMENTED_FIXES * 100 / TOTAL_FIXES))
    echo "Implementation Rate: $PERCENTAGE%"
fi

echo ""
echo "📋 DETAILED RESULTS"
echo "=================="

# Show all results
for fix_name in "${!VERIFICATION_RESULTS[@]}"; do
    echo "${VERIFICATION_RESULTS[$fix_name]} $fix_name"
done

echo ""

# Generate recommendations for missing fixes
if [ $MISSING_FIXES -gt 0 ]; then
    echo "🔧 MISSING FIXES - RECOMMENDED ACTIONS"
    echo "======================================="
    
    if [[ "${VERIFICATION_RESULTS[README_CONCISE]}" == "❌ MISSING" ]]; then
        echo "1. README.md needs to be condensed:"
        echo "   - Current: $(wc -l < "$REPO_DIR/README.md" 2>/dev/null || echo "unknown") lines"
        echo "   - Target: < 200 lines"
        echo "   - Action: Review and condense content"
    fi
    
    if [[ "${VERIFICATION_RESULTS[TRAEFIK_CONTAINER_NAME]}" == "❌ MISSING" ]]; then
        echo "2. Traefik container naming issue:"
        echo "   - Action: sudo /srv/core/fix-traefik-routing.sh"
    fi
    
    if [[ "${VERIFICATION_RESULTS[AUTHELIA_ACCESS]}" == "❌ MISSING" ]]; then
        echo "3. Authelia not accessible:"
        echo "   - Action: sudo /srv/core/fix-authelia-routing.sh"
    fi
    
    if [[ "${VERIFICATION_RESULTS[AI_SERVICE_ACCESS]}" == "❌ MISSING" ]]; then
        echo "4. AI service not accessible:"
        echo "   - Action: sudo /srv/core/fix-openwebui-routing.sh"
    fi
    
    echo ""
    echo "🚀 QUICK FIX COMMANDS"
    echo "===================="
    echo "sudo /srv/core/comprehensive-service-fix.sh"
    echo "sudo /srv/core/scripts/setup_shipping_receiving.sh"
    echo "sudo /srv/core/scripts/setup_ai_system.sh"
else
    echo "🎉 ALL FIXES SUCCESSFULLY IMPLEMENTED!"
    echo "====================================="
    echo "Your NXCore system is fully operational with all fixes applied."
fi

echo ""
echo "📋 NEXT STEPS"
echo "============="
echo "1. Review any missing fixes above"
echo "2. Run comprehensive fix script if needed"
echo "3. Test all services manually"
echo "4. Set up ongoing monitoring"
echo "5. Document any custom configurations"

echo ""
echo "🌐 SERVICE URLS"
echo "==============="
echo "Landing: https://nxcore.tail79107c.ts.net/"
echo "Traefik: https://nxcore.tail79107c.ts.net/dash"
echo "Grafana: https://nxcore.tail79107c.ts.net/grafana/"
echo "AI: https://nxcore.tail79107c.ts.net/ai/"
echo "Auth: https://nxcore.tail79107c.ts.net/auth/"
echo "n8n: https://nxcore.tail79107c.ts.net/n8n/"
