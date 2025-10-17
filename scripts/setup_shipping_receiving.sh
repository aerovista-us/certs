#!/usr/bin/env bash
set -euo pipefail

# Complete Shipping & Receiving System Setup
# Installs all components and configures systemd services

REPO_DIR="/srv/core/nxcore"
EXCHANGE_DIR="/srv/exchange"

echo "🚀 Setting up Shipping & Receiving System..."

# Create exchange directories
echo "📁 Creating exchange directories..."
sudo mkdir -p "$EXCHANGE_DIR"/{inbox,processing,archive,quarantine,outbox,scripts}
sudo chown -R glyph:glyph "$EXCHANGE_DIR"

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x "$REPO_DIR/scripts/watch_inbox.sh"
chmod +x "$REPO_DIR/scripts/push_outbox.sh"
chmod +x "$REPO_DIR/scripts/monitor_disk_usage.sh"
chmod +x "$REPO_DIR/scripts/quarantine_unknown.sh"

# Install systemd services
echo "⚙️ Installing systemd services..."
sudo cp "$REPO_DIR/systemd/exchange-inbox.service" /etc/systemd/system/
sudo cp "$REPO_DIR/systemd/exchange-inbox.path" /etc/systemd/system/
sudo cp "$REPO_DIR/systemd/exchange-outbox.service" /etc/systemd/system/
sudo cp "$REPO_DIR/systemd/exchange-outbox.timer" /etc/systemd/system/

# Reload systemd and enable services
echo "🔄 Reloading systemd and enabling services..."
sudo systemctl daemon-reload
sudo systemctl enable exchange-inbox.service
sudo systemctl enable exchange-inbox.path
sudo systemctl enable exchange-outbox.timer

# Start services
echo "▶️ Starting services..."
sudo systemctl start exchange-inbox.service
sudo systemctl start exchange-inbox.path
sudo systemctl start exchange-outbox.timer

# Verify services are running
echo "✅ Verifying services..."
echo "Inbox service status:"
sudo systemctl is-active exchange-inbox.service || echo "⚠️ Inbox service not active"
echo "Inbox path status:"
sudo systemctl is-active exchange-inbox.path || echo "⚠️ Inbox path not active"
echo "Outbox timer status:"
sudo systemctl is-active exchange-outbox.timer || echo "⚠️ Outbox timer not active"

# Create test directories
echo "🧪 Creating test directories..."
mkdir -p "$EXCHANGE_DIR/outbox/$(date +%Y-%m-%d)"/{csv,images,documents,archives}

echo "🎉 Shipping & Receiving System setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Ensure n8n is running on localhost:5678"
echo "2. Test by dropping a file in $EXCHANGE_DIR/inbox"
echo "3. Monitor logs: journalctl -u exchange-inbox.service -f"
echo "4. Check outbox: journalctl -u exchange-outbox.service -f"
echo ""
echo "📁 Directory structure:"
echo "  $EXCHANGE_DIR/inbox      - Drop files here"
echo "  $EXCHANGE_DIR/processing - Active processing"
echo "  $EXCHANGE_DIR/archive    - Immutable copies"
echo "  $EXCHANGE_DIR/quarantine - Unsafe files"
echo "  $EXCHANGE_DIR/outbox     - Ready for GitHub"
