#!/bin/bash

# AeroVista Dashboard Switcher
# Switch between different dashboard styles for the office monitor

DASHBOARD_DIR="/srv/core/config/dashboard"
DASHBOARD_SERVICE="nxcore-dashboard"

echo "🎛️  AeroVista Dashboard Switcher"
echo "================================="
echo ""
echo "Available Dashboard Styles:"
echo "1. Full Featured (office-monitor-options.html) - Complete dashboard with charts and animations"
echo "2. Minimal Professional (office-minimal.html) - Clean, professional office display"
echo "3. Cyberpunk Style (office-cyberpunk.html) - Futuristic, dramatic display"
echo "4. Current System Monitor (nxcore-monitor.html) - Technical system monitor"
echo "5. Landing Page (aerovista-landing.html) - Main landing page"
echo ""

read -p "Select dashboard style (1-5): " choice

case $choice in
    1)
        DASHBOARD_FILE="office-monitor-options.html"
        echo "🔄 Switching to Full Featured Dashboard..."
        ;;
    2)
        DASHBOARD_FILE="office-minimal.html"
        echo "🔄 Switching to Minimal Professional Dashboard..."
        ;;
    3)
        DASHBOARD_FILE="office-cyberpunk.html"
        echo "🔄 Switching to Cyberpunk Style Dashboard..."
        ;;
    4)
        DASHBOARD_FILE="nxcore-monitor.html"
        echo "🔄 Switching to System Monitor Dashboard..."
        ;;
    5)
        DASHBOARD_FILE="aerovista-landing.html"
        echo "🔄 Switching to Landing Page..."
        ;;
    *)
        echo "❌ Invalid selection. Exiting."
        exit 1
        ;;
esac

# Copy the selected dashboard to the active location
if [ -f "$DASHBOARD_DIR/$DASHBOARD_FILE" ]; then
    cp "$DASHBOARD_DIR/$DASHBOARD_FILE" "$DASHBOARD_DIR/index.html"
    echo "✅ Dashboard switched to: $DASHBOARD_FILE"
    
    # Restart the dashboard service to pick up changes
    echo "🔄 Restarting dashboard service..."
    docker restart $DASHBOARD_SERVICE
    
    # Wait a moment for the service to restart
    sleep 3
    
    # Check if the service is running
    if docker ps | grep -q $DASHBOARD_SERVICE; then
        echo "✅ Dashboard service restarted successfully"
        echo "🌐 Dashboard is now available at: http://100.115.9.61:8081/"
        echo ""
        echo "💡 The office monitor should automatically refresh to show the new dashboard style."
    else
        echo "❌ Error: Dashboard service failed to restart"
        exit 1
    fi
else
    echo "❌ Error: Dashboard file not found: $DASHBOARD_FILE"
    exit 1
fi

echo ""
echo "🎉 Dashboard switch completed!"
echo "📺 Check the office monitor to see the new display style."
