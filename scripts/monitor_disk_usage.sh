#!/usr/bin/env bash
set -euo pipefail

# Disk usage monitoring for outbox system
# Creates alerts in state/outbox/alerts/ when disk usage is high

THRESHOLD_PERCENT=85
ALERT_DIR="/srv/core/nxcore/state/outbox/alerts"
OUTBOX_DIR="/srv/exchange/outbox"

mkdir -p "$ALERT_DIR"

# Check disk usage for outbox directory
USAGE_PERCENT=$(df "$OUTBOX_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$USAGE_PERCENT" -gt "$THRESHOLD_PERCENT" ]; then
    ALERT_FILE="$ALERT_DIR/disk_usage_$(date +%Y%m%d_%H%M%S).txt"
    cat > "$ALERT_FILE" << EOF
ALERT: High disk usage detected
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Usage: ${USAGE_PERCENT}%
Threshold: ${THRESHOLD_PERCENT}%
Directory: $OUTBOX_DIR

Action required: Clean up old files or expand storage
EOF
    echo "[ALERT] High disk usage: ${USAGE_PERCENT}% > ${THRESHOLD_PERCENT}%"
    exit 1
else
    echo "[OK] Disk usage: ${USAGE_PERCENT}%"
    exit 0
fi
