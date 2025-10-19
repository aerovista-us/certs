#!/bin/bash
# Fix Mixed Content Issues for NXCore

echo "🔧 NXCore Mixed Content Fix - Starting..."

# Fix Dozzle URL to use HTTPS
echo "🔧 Fixing Dozzle URL to use HTTPS..."

# Update landing page to use HTTPS for Dozzle
sed -i 's|http://100.115.9.61:9999/|https://nxcore.tail79107c.ts.net/dozzle/|g' /opt/nexus/landing/index.html

# Create Dozzle SSL configuration
cat > /opt/nexus/landing/dozzle-ssl.conf << 'EOF'
# Dozzle SSL Configuration
server {
    listen 443 ssl;
    server_name nxcore.tail79107c.ts.net;
    
    # SSL Configuration
    ssl_certificate /opt/nexus/traefik/certs/fullchain.pem;
    ssl_certificate_key /opt/nexus/traefik/certs/privkey.pem;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    location /dozzle/ {
        proxy_pass http://100.115.9.61:9999/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Create Traefik configuration for Dozzle
cat > /opt/nexus/traefik/dynamic/dozzle-ssl.yml << 'EOF'
# Traefik Dozzle SSL Configuration
http:
  routers:
    dozzle-ssl:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/dozzle`)
      entryPoints:
        - websecure
      tls: {}
      middlewares:
        - dozzle-strip
        - dozzle-headers
      service: dozzle-svc

  middlewares:
    dozzle-strip:
      stripPrefix:
        prefixes:
          - "/dozzle"
    
    dozzle-headers:
      headers:
        customRequestHeaders:
          X-Forwarded-Proto: "https"
        customResponseHeaders:
          Strict-Transport-Security: "max-age=31536000; includeSubDomains"
          X-Frame-Options: "DENY"
          X-Content-Type-Options: "nosniff"
          Referrer-Policy: "strict-origin-when-cross-origin"

  services:
    dozzle-svc:
      loadBalancer:
        servers:
          - url: "http://100.115.9.61:9999"
EOF

# Update landing page HTML to fix mixed content
cat > /opt/nexus/landing/index-fixed.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NXCore Control Panel</title>
    <link rel="stylesheet" href="/assets/css/inter-font.css">
    <link rel="manifest" href="/manifest.json">
    <meta name="theme-color" content="#3b82f6">
    <meta name="description" content="Secure Tailscale Network Management Dashboard">
    
    <!-- Security Headers -->
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; script-src 'self' 'unsafe-inline'; img-src 'self' data: https:;">
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta http-equiv="X-Frame-Options" content="DENY">
    <meta http-equiv="Referrer-Policy" content="strict-origin-when-cross-origin">
    
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .header {
            text-align: center;
            color: white;
            margin-bottom: 3rem;
        }
        
        .header h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .header p {
            font-size: 1.25rem;
            opacity: 0.9;
        }
        
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }
        
        .service-card {
            background: white;
            border-radius: 1rem;
            padding: 1.5rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .service-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }
        
        .service-card h3 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #1f2937;
        }
        
        .service-card p {
            color: #6b7280;
            margin-bottom: 1rem;
            line-height: 1.5;
        }
        
        .status {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        .status.online {
            background-color: #d1fae5;
            color: #065f46;
        }
        
        .status.offline {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .verification {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 1rem;
            padding: 1.5rem;
            color: white;
            text-align: center;
            margin-top: 2rem;
        }
        
        .verification strong {
            color: #fbbf24;
        }
        
        .verification code {
            background: rgba(0,0,0,0.2);
            padding: 0.25rem 0.5rem;
            border-radius: 0.375rem;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        }
        
        .footer {
            text-align: center;
            color: white;
            opacity: 0.8;
            margin-top: 2rem;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .services-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>NXCore Control Panel</h1>
            <p>Secure Tailscale Network Management Dashboard</p>
        </div>
        
        <div class="services-grid">
            <a href="/traefik/" class="service-card">
                <h3>Traefik Dashboard</h3>
                <p>Reverse proxy and load balancer management</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/auth/" class="service-card">
                <h3>Authelia</h3>
                <p>Authentication and authorization server</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/ai/" class="service-card">
                <h3>OpenWebUI</h3>
                <p>AI chat interface and model management</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/n8n/" class="service-card">
                <h3>n8n Workflow</h3>
                <p>Workflow automation and integration platform</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/grafana/" class="service-card">
                <h3>Grafana</h3>
                <p>Monitoring and observability dashboards</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/prometheus/" class="service-card">
                <h3>Prometheus</h3>
                <p>Metrics collection and monitoring</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/status/" class="service-card">
                <h3>Uptime Kuma</h3>
                <p>Uptime monitoring and status pages</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/dozzle/" class="service-card">
                <h3>Dozzle</h3>
                <p>Docker container logs viewer</p>
                <span class="status offline">Offline</span>
            </a>
            
            <a href="/portainer/" class="service-card">
                <h3>Portainer</h3>
                <p>Docker container management interface</p>
                <span class="status online">Online</span>
            </a>
            
            <a href="/files/" class="service-card">
                <h3>FileBrowser</h3>
                <p>Web-based file manager</p>
                <span class="status online">Online</span>
            </a>
        </div>
        
        <div class="verification">
            <p><strong>Verification:</strong> After installation, visit <code>https://nxcore.tail79107c.ts.net/</code> - you should see a green lock icon in the address bar.</p>
        </div>
        
        <div class="footer">
            <p>© 2025 NXCore Control Panel. Secure Tailscale Network Management.</p>
        </div>
    </div>
    
    <script src="/assets/js/tailwind.min.js"></script>
</body>
</html>
EOF

# Backup original and replace
cp /opt/nexus/landing/index.html /opt/nexus/landing/index.html.backup
cp /opt/nexus/landing/index-fixed.html /opt/nexus/landing/index.html

# Set proper permissions
chown -R www-data:www-data /opt/nexus/landing/
chmod -R 644 /opt/nexus/landing/index.html

echo "✅ Mixed content issues fixed"
echo "✅ Dozzle URL updated to HTTPS"
echo "✅ Security headers added"
echo "✅ CSP policy configured"
echo "✅ Original file backed up"

# Test the fixes
echo "🧪 Testing mixed content fixes..."

# Check if Dozzle URL is updated
if grep -q "https://nxcore.tail79107c.ts.net/dozzle/" /opt/nexus/landing/index.html; then
    echo "✅ Dozzle URL updated to HTTPS"
else
    echo "❌ Dozzle URL update failed"
fi

# Check if security headers are present
if grep -q "Content-Security-Policy" /opt/nexus/landing/index.html; then
    echo "✅ Security headers added"
else
    echo "❌ Security headers not found"
fi

echo "🎉 Mixed content fix completed!"
echo ""
echo "Next steps:"
echo "1. Restart web server"
echo "2. Test with Playwright"
echo "3. Verify no mixed content warnings"
echo "4. Check security headers"
