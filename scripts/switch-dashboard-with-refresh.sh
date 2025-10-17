#!/bin/bash

# Enhanced Dashboard Switcher with Browser Refresh
echo "🎛️  AeroVista Dashboard Switcher (with Auto-Refresh)"
echo "===================================================="
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
if [ -f "/srv/core/config/dashboard/$DASHBOARD_FILE" ]; then
    cp "/srv/core/config/dashboard/$DASHBOARD_FILE" "/srv/core/config/dashboard/index.html"
    echo "✅ Dashboard switched to: $DASHBOARD_FILE"
    
    # Restart the dashboard service to pick up changes
    echo "🔄 Restarting dashboard service..."
    docker restart nxcore-dashboard
    
    # Wait for service to restart
    sleep 3
    
    # Check if the service is running
    if docker ps | grep -q nxcore-dashboard; then
        echo "✅ Dashboard service restarted successfully"
        
        # Force browser refresh using remote debugging
        echo "🔄 Forcing browser refresh on monitor..."
        
        # Get the browser tab ID
        TAB_ID=$(curl -s http://localhost:9222/json | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ ! -z "$TAB_ID" ]; then
            # Send reload command to the browser
            curl -s -X POST "http://localhost:9222/json/runtime/reload" -d "{\"tabId\":\"$TAB_ID\"}" > /dev/null 2>&1
            
            # Alternative method: navigate to the page
            curl -s -X POST "http://localhost:9222/json/runtime/evaluate" -d "{\"expression\":\"location.reload()\"}" > /dev/null 2>&1
            
            echo "✅ Browser refresh command sent"
        else
            echo "⚠️  Could not get browser tab ID, but dashboard is updated"
        fi
        
        echo ""
        echo "🎉 Dashboard switch completed!"
        echo "📺 The office monitor should now show the new dashboard style."
        echo "🌐 Dashboard is available at: http://100.115.9.61:8081/"
        
    else
        echo "❌ Error: Dashboard service failed to restart"
        exit 1
    fi
else
    echo "❌ Error: Dashboard file not found: $DASHBOARD_FILE"
    exit 1
fi
