#!/bin/bash
# Fix Service Availability Issues for NXCore

echo "🔧 NXCore Service Availability Fix - Starting..."

# Check Docker container status
echo "🔍 Checking Docker container status..."

# Function to check and restart service
check_and_restart_service() {
    local service_name=$1
    local container_name=$2
    
    echo "🔍 Checking $service_name..."
    
    if docker ps | grep -q "$container_name"; then
        echo "✅ $service_name is running"
    else
        echo "⚠️ $service_name is not running, attempting to start..."
        docker start "$container_name" 2>/dev/null || echo "❌ Failed to start $service_name"
    fi
}

# Check and restart services
check_and_restart_service "Grafana" "grafana"
check_and_restart_service "Portainer" "portainer"
check_and_restart_service "Uptime Kuma" "uptime-kuma"

# Check Docker Compose services
echo "🔍 Checking Docker Compose services..."

# Navigate to compose directory
cd /opt/nexus || exit 1

# Check if docker-compose.yml exists
if [ -f "docker-compose.yml" ]; then
    echo "✅ Docker Compose file found"
    
    # Check service status
    echo "🔍 Checking service status..."
    docker-compose ps
    
    # Restart failed services
    echo "🔄 Restarting failed services..."
    docker-compose up -d --no-deps grafana
    docker-compose up -d --no-deps portainer
    docker-compose up -d --no-deps uptime-kuma
    
    # Wait for services to start
    echo "⏳ Waiting for services to start..."
    sleep 30
    
    # Check service health
    echo "🔍 Checking service health..."
    docker-compose ps
else
    echo "❌ Docker Compose file not found"
fi

# Create service health check script
cat > /opt/nexus/scripts/health-check.sh << 'EOF'
#!/bin/bash
# NXCore Service Health Check

echo "🔍 NXCore Service Health Check - $(date)"

# Function to check service health
check_service_health() {
    local service_name=$1
    local url=$2
    local expected_status=$3
    
    echo "🔍 Checking $service_name at $url..."
    
    # Check if service is responding
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        echo "✅ $service_name is healthy"
        return 0
    else
        echo "❌ $service_name is not responding"
        return 1
    fi
}

# Check all services
check_service_health "Landing Page" "https://nxcore.tail79107c.ts.net/" "200"
check_service_health "Traefik Dashboard" "https://nxcore.tail79107c.ts.net/traefik/" "200"
check_service_health "AI Service" "https://nxcore.tail79107c.ts.net/ai/" "200"
check_service_health "FileBrowser" "https://nxcore.tail79107c.ts.net/files/" "200"
check_service_health "Authelia" "https://nxcore.tail79107c.ts.net/auth/" "200"
check_service_health "Grafana" "https://nxcore.tail79107c.ts.net/grafana/" "200"
check_service_health "Portainer" "https://nxcore.tail79107c.ts.net/portainer/" "200"
check_service_health "Status" "https://nxcore.tail79107c.ts.net/status/" "200"

echo "🏁 Health check completed"
EOF

chmod +x /opt/nexus/scripts/health-check.sh

# Create service restart script
cat > /opt/nexus/scripts/restart-services.sh << 'EOF'
#!/bin/bash
# NXCore Service Restart Script

echo "🔄 NXCore Service Restart - Starting..."

# Navigate to compose directory
cd /opt/nexus || exit 1

# Restart all services
echo "🔄 Restarting all services..."
docker-compose down
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 60

# Check service status
echo "🔍 Checking service status..."
docker-compose ps

# Run health check
echo "🔍 Running health check..."
/opt/nexus/scripts/health-check.sh

echo "🎉 Service restart completed"
EOF

chmod +x /opt/nexus/scripts/restart-services.sh

# Create service monitoring script
cat > /opt/nexus/scripts/monitor-services.sh << 'EOF'
#!/bin/bash
# NXCore Service Monitoring Script

echo "📊 NXCore Service Monitoring - Starting..."

# Function to monitor service
monitor_service() {
    local service_name=$1
    local url=$2
    local log_file="/opt/nexus/logs/${service_name,,}-monitor.log"
    
    echo "📊 Monitoring $service_name..."
    
    # Create log file if it doesn't exist
    mkdir -p /opt/nexus/logs
    touch "$log_file"
    
    # Check service status
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log status
    echo "$timestamp - $service_name: HTTP $status" >> "$log_file"
    
    # Alert if service is down
    if [ "$status" != "200" ]; then
        echo "⚠️ ALERT: $service_name is returning HTTP $status"
        echo "$timestamp - ALERT: $service_name HTTP $status" >> "$log_file"
    fi
}

# Monitor all services
monitor_service "Landing" "https://nxcore.tail79107c.ts.net/"
monitor_service "Traefik" "https://nxcore.tail79107c.ts.net/traefik/"
monitor_service "AI" "https://nxcore.tail79107c.ts.net/ai/"
monitor_service "Files" "https://nxcore.tail79107c.ts.net/files/"
monitor_service "Auth" "https://nxcore.tail79107c.ts.net/auth/"
monitor_service "Grafana" "https://nxcore.tail79107c.ts.net/grafana/"
monitor_service "Portainer" "https://nxcore.tail79107c.ts.net/portainer/"
monitor_service "Status" "https://nxcore.tail79107c.ts.net/status/"

echo "📊 Monitoring completed"
EOF

chmod +x /opt/nexus/scripts/monitor-services.sh

# Create systemd service for monitoring
cat > /etc/systemd/system/nxcore-monitor.service << 'EOF'
[Unit]
Description=NXCore Service Monitor
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/nexus
ExecStart=/opt/nexus/scripts/monitor-services.sh
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

# Enable and start monitoring service
systemctl daemon-reload
systemctl enable nxcore-monitor.service
systemctl start nxcore-monitor.service

# Create log rotation for monitoring
cat > /etc/logrotate.d/nxcore-monitor << 'EOF'
/opt/nexus/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Run initial health check
echo "🔍 Running initial health check..."
/opt/nexus/scripts/health-check.sh

echo "✅ Service availability fixes completed"
echo "✅ Health check script created"
echo "✅ Service restart script created"
echo "✅ Monitoring script created"
echo "✅ Systemd service configured"
echo "✅ Log rotation configured"

# Test the fixes
echo "🧪 Testing service availability fixes..."

# Check if health check script works
if [ -f "/opt/nexus/scripts/health-check.sh" ]; then
    echo "✅ Health check script created"
else
    echo "❌ Health check script creation failed"
fi

# Check if monitoring service is running
if systemctl is-active --quiet nxcore-monitor.service; then
    echo "✅ Monitoring service is running"
else
    echo "❌ Monitoring service is not running"
fi

echo "🎉 Service availability fix completed!"
echo ""
echo "Next steps:"
echo "1. Test with Playwright"
echo "2. Verify all services are responding"
echo "3. Check monitoring logs"
echo "4. Set up alerts if needed"
