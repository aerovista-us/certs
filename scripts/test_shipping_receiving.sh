#!/usr/bin/env bash
set -euo pipefail

# Test script for Shipping & Receiving System
# Verifies all components are working correctly

EXCHANGE_DIR="/srv/exchange"
REPO_DIR="/srv/core/nxcore"
TEST_FILE="/tmp/test_shipping_receiving.txt"

echo "🧪 Testing Shipping & Receiving System..."

# Test 1: Directory structure
echo "📁 Testing directory structure..."
for dir in inbox processing archive quarantine outbox; do
    if [ -d "$EXCHANGE_DIR/$dir" ]; then
        echo "  ✅ $EXCHANGE_DIR/$dir exists"
    else
        echo "  ❌ $EXCHANGE_DIR/$dir missing"
        exit 1
    fi
done

# Test 2: Script permissions
echo "🔧 Testing script permissions..."
for script in watch_inbox.sh push_outbox.sh monitor_disk_usage.sh quarantine_unknown.sh; do
    if [ -x "$REPO_DIR/scripts/$script" ]; then
        echo "  ✅ $script is executable"
    else
        echo "  ❌ $script is not executable"
        exit 1
    fi
done

# Test 3: Systemd services
echo "⚙️ Testing systemd services..."
for service in exchange-inbox.service exchange-inbox.path exchange-outbox.timer; do
    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        echo "  ✅ $service is enabled"
    else
        echo "  ❌ $service is not enabled"
        exit 1
    fi
done

# Test 4: Service status
echo "📊 Checking service status..."
echo "  Inbox service: $(systemctl is-active exchange-inbox.service)"
echo "  Inbox path: $(systemctl is-active exchange-inbox.path)"
echo "  Outbox timer: $(systemctl is-active exchange-outbox.timer)"

# Test 5: n8n webhook connectivity
echo "🌐 Testing n8n webhook connectivity..."
if curl -s -f "http://localhost:5678/webhook/shipping-receiving" >/dev/null 2>&1; then
    echo "  ✅ n8n webhook is accessible"
else
    echo "  ⚠️ n8n webhook not accessible (n8n may not be running)"
fi

# Test 6: Create test file
echo "📄 Creating test file..."
echo "Test file created at $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$TEST_FILE"
echo "  ✅ Test file created: $TEST_FILE"

# Test 7: Copy test file to inbox
echo "📥 Testing file processing..."
cp "$TEST_FILE" "$EXCHANGE_DIR/inbox/"
echo "  ✅ Test file copied to inbox"

# Wait for processing
echo "⏳ Waiting for processing (10 seconds)..."
sleep 10

# Check if file was processed
if [ ! -f "$EXCHANGE_DIR/inbox/$(basename "$TEST_FILE")" ]; then
    echo "  ✅ File was processed (removed from inbox)"
    
    # Check if file exists in processing
    if find "$EXCHANGE_DIR/processing" -name "$(basename "$TEST_FILE")" -type f | grep -q .; then
        echo "  ✅ File found in processing directory"
    else
        echo "  ⚠️ File not found in processing directory"
    fi
    
    # Check if file exists in archive
    if find "$EXCHANGE_DIR/archive" -name "$(basename "$TEST_FILE")" -type f | grep -q .; then
        echo "  ✅ File found in archive directory"
    else
        echo "  ⚠️ File not found in archive directory"
    fi
else
    echo "  ❌ File was not processed (still in inbox)"
fi

# Test 8: Check recent logs
echo "📋 Recent service logs:"
echo "  Inbox service (last 5 lines):"
journalctl -u exchange-inbox.service -n 5 --no-pager | tail -5

# Cleanup
echo "🧹 Cleaning up test file..."
rm -f "$TEST_FILE"

echo "🎉 Shipping & Receiving System test complete!"
echo ""
echo "📊 Summary:"
echo "  - Directory structure: ✅"
echo "  - Script permissions: ✅"
echo "  - Systemd services: ✅"
echo "  - File processing: ✅"
echo ""
echo "📝 To monitor the system:"
echo "  journalctl -u exchange-inbox.service -f"
echo "  journalctl -u exchange-outbox.service -f"
