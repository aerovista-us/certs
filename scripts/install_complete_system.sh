#!/usr/bin/env bash
set -euo pipefail

# Complete Shipping & Receiving System Installation
# One-command setup for the entire system

REPO_DIR="/srv/core/nxcore"

echo "🚀 NXCore Shipping & Receiving System - Complete Installation"
echo "=============================================================="

# Check if running as root for systemd operations
if [ "$EUID" -eq 0 ]; then
    echo "⚠️ Running as root - this is correct for systemd installation"
else
    echo "❌ This script must be run as root for systemd installation"
    echo "Please run: sudo $0"
    exit 1
fi

# Make setup script executable and run it
chmod +x "$REPO_DIR/scripts/setup_shipping_receiving.sh"
"$REPO_DIR/scripts/setup_shipping_receiving.sh"

echo ""
echo "🔍 Running system verification..."
chmod +x "$REPO_DIR/scripts/test_shipping_receiving.sh"
"$REPO_DIR/scripts/test_shipping_receiving.sh"

echo ""
echo "🎯 Installation Summary:"
echo "========================"
echo "✅ Exchange directories created"
echo "✅ Scripts made executable"
echo "✅ Systemd services installed and enabled"
echo "✅ Services started and verified"
echo "✅ System tested and operational"
echo ""
echo "📋 System Status:"
systemctl status exchange-inbox.service --no-pager -l
echo ""
systemctl status exchange-outbox.timer --no-pager -l
echo ""
echo "🎉 NXCore Shipping & Receiving System is now fully operational!"
echo ""
echo "📝 Quick Commands:"
echo "  Monitor inbox:  journalctl -u exchange-inbox.service -f"
echo "  Monitor outbox: journalctl -u exchange-outbox.service -f"
echo "  Test system:    $REPO_DIR/scripts/test_shipping_receiving.sh"
echo "  Drop files:     /srv/exchange/inbox/"
echo ""
echo "📚 Documentation: documents/Shipping_Receiving_Docs/"
