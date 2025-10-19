# NXCore Infrastructure - Detailed Action Plan & Upgrade Path

## 🎯 **Executive Summary**

**System Type**: High-trust internal infrastructure for 10 stakeholder PCs  
**Current Status**: 67% operational (4/6 services working)  
**Target**: 95%+ operational with enterprise-grade reliability  
**Budget**: Cost-aware with free/open-source solutions prioritized  
**Timeline**: 2-week implementation with 1-week testing phase

---

## 📊 **Current System Analysis**

### **Working Services (67%)**
- ✅ **File Browser** - File management system
- ✅ **OpenWebUI** - AI chat interface  
- ✅ **Landing Page** - Main dashboard
- ✅ **n8n** - Workflow automation
- ✅ **Authelia** - SSO/MFA gateway

### **Critical Issues (33%)**
- ❌ **Grafana** - HTTP 302 redirect (monitoring dashboards)
- ❌ **Prometheus** - HTTP 302 redirect (metrics collection)
- ⚠️ **cAdvisor** - HTTP 307 redirect (container metrics)
- ⚠️ **Uptime Kuma** - HTTP 302 redirect (service monitoring)

---

## 🚀 **Phase 1: Critical Fixes (Days 1-3)**

### **1.1 Fix Traefik Middleware Configuration**

#### **Problem**: StripPrefix middleware not working correctly
#### **Solution**: Update Traefik dynamic configuration

```bash
# Create fixed middleware configuration
cat > /opt/nexus/traefik/dynamic/middleware-fixes.yml << 'EOF'
http:
  middlewares:
    # Fixed Grafana middleware
    grafana-strip-fixed:
      stripPrefix:
        prefixes: ["/grafana"]
        forceSlash: false
    
    # Fixed Prometheus middleware  
    prometheus-strip-fixed:
      stripPrefix:
        prefixes: ["/prometheus"]
        forceSlash: false
        
    # Fixed cAdvisor middleware
    cadvisor-strip-fixed:
      stripPrefix:
        prefixes: ["/metrics"]
        forceSlash: false
        
    # Fixed Uptime Kuma middleware
    uptime-strip-fixed:
      stripPrefix:
        prefixes: ["/status"]
        forceSlash: false

  routers:
    # Fixed Grafana routing
    grafana-fixed:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/grafana`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [grafana-strip-fixed]
      service: grafana-svc
      
    # Fixed Prometheus routing
    prometheus-fixed:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/prometheus`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [prometheus-strip-fixed]
      service: prometheus-svc
      
    # Fixed cAdvisor routing
    cadvisor-fixed:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/metrics`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [cadvisor-strip-fixed]
      service: cadvisor-svc
      
    # Fixed Uptime Kuma routing
    uptime-fixed:
      rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/status`)
      priority: 200
      entryPoints: [websecure]
      tls: {}
      middlewares: [uptime-strip-fixed]
      service: uptime-svc
EOF
```

#### **Implementation Steps**:
1. **Backup current configuration**
2. **Deploy fixed middleware**
3. **Restart Traefik**
4. **Test service endpoints**
5. **Verify content delivery**

### **1.2 Fix Service Configuration Issues**

#### **Problem**: Service discovery and networking issues
#### **Solution**: Update Docker Compose configurations

```yaml
# Fixed Grafana configuration
version: "3.9"
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SECURITY_DISABLE_GRAVATAR=true
      - GF_ANALYTICS_REPORTING_ENABLED=false
    volumes:
      - /srv/core/data/grafana:/var/lib/grafana
    networks:
      - gateway
      - observability
    labels:
      - traefik.enable=true
      - traefik.http.routers.grafana.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/grafana`)
      - traefik.http.routers.grafana.entrypoints=websecure
      - traefik.http.routers.grafana.tls=true
      - traefik.http.routers.grafana.priority=200
      - traefik.http.middlewares.grafana-strip.stripprefix.prefixes=/grafana
      - traefik.http.routers.grafana.middlewares=grafana-strip@docker
      - traefik.http.services.grafana.loadbalancer.server.port=3000
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### **1.3 Security Hardening**

#### **Problem**: Default credentials and placeholder secrets
#### **Solution**: Generate secure credentials

```bash
#!/bin/bash
# Security hardening script

# Generate secure passwords
GRAFANA_PASSWORD=$(openssl rand -base64 32)
N8N_PASSWORD=$(openssl rand -base64 32)
AUTHELIA_JWT_SECRET=$(openssl rand -base64 32)
AUTHELIA_SESSION_SECRET=$(openssl rand -base64 32)
AUTHELIA_STORAGE_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Create secure environment file
cat > /srv/core/.env.secure << EOF
# NXCore Secure Environment Variables
GRAFANA_PASSWORD=$GRAFANA_PASSWORD
N8N_PASSWORD=$N8N_PASSWORD
AUTHELIA_JWT_SECRET=$AUTHELIA_JWT_SECRET
AUTHELIA_SESSION_SECRET=$AUTHELIA_SESSION_SECRET
AUTHELIA_STORAGE_ENCRYPTION_KEY=$AUTHELIA_STORAGE_ENCRYPTION_KEY
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
EOF

# Change default credentials
docker exec grafana grafana-cli admin reset-admin-password "$GRAFANA_PASSWORD"
docker exec n8n n8n user:password --email admin@example.com --password "$N8N_PASSWORD"
```

---

## 🏗️ **Phase 2: System Enhancement (Days 4-7)**

### **2.1 Enhanced Monitoring & Alerting**

#### **Free Solutions**:
- **Prometheus** - Metrics collection (already installed)
- **Grafana** - Visualization dashboards (already installed)
- **Uptime Kuma** - Service monitoring (already installed)
- **cAdvisor** - Container metrics (already installed)

#### **Implementation**:
```yaml
# Enhanced monitoring configuration
version: "3.9"
services:
  # Prometheus with enhanced configuration
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    volumes:
      - /srv/core/config/prometheus:/etc/prometheus
      - /srv/core/data/prometheus:/prometheus
    networks:
      - gateway
      - observability
    labels:
      - traefik.enable=true
      - traefik.http.routers.prometheus.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/prometheus`)
      - traefik.http.routers.prometheus.entrypoints=websecure
      - traefik.http.routers.prometheus.tls=true
      - traefik.http.routers.prometheus.priority=200
      - traefik.http.middlewares.prometheus-strip.stripprefix.prefixes=/prometheus
      - traefik.http.routers.prometheus.middlewares=prometheus-strip@docker
      - traefik.http.services.prometheus.loadbalancer.server.port=9090
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:9090/-/healthy || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### **2.2 Automated Testing Framework**

#### **Free Solutions**:
- **Node.js** - HTTP testing framework
- **Playwright** - Browser automation testing
- **Python** - Advanced monitoring scripts
- **Cron** - Automated scheduling

#### **Implementation**:
```javascript
// Enhanced testing framework
const { chromium } = require('playwright');
const cron = require('node-cron');

class NXCoreTester {
    constructor() {
        this.services = [
            { name: 'Grafana', url: 'https://nxcore.tail79107c.ts.net/grafana/', expected: 200 },
            { name: 'Prometheus', url: 'https://nxcore.tail79107c.ts.net/prometheus/', expected: 200 },
            { name: 'cAdvisor', url: 'https://nxcore.tail79107c.ts.net/metrics/', expected: 200 },
            { name: 'Uptime Kuma', url: 'https://nxcore.tail79107c.ts.net/status/', expected: 200 }
        ];
    }

    async testServices() {
        const browser = await chromium.launch({ headless: true });
        const context = await browser.newContext({ ignoreHTTPSErrors: true });
        const page = await context.newPage();

        for (const service of this.services) {
            try {
                const response = await page.goto(service.url, { waitUntil: 'networkidle' });
                const status = response.status();
                
                if (status === service.expected) {
                    console.log(`✅ ${service.name}: Working (${status})`);
                } else {
                    console.log(`❌ ${service.name}: Failed (${status})`);
                }
            } catch (error) {
                console.log(`❌ ${service.name}: Error (${error.message})`);
            }
        }

        await browser.close();
    }
}

// Schedule automated testing every 5 minutes
cron.schedule('*/5 * * * *', () => {
    const tester = new NXCoreTester();
    tester.testServices();
});
```

### **2.3 High-Availability Configuration**

#### **Free Solutions**:
- **Docker Swarm** - Container orchestration
- **Traefik** - Load balancing (already installed)
- **Redis** - Caching layer (already installed)
- **PostgreSQL** - Database clustering

#### **Implementation**:
```yaml
# High-availability configuration
version: "3.9"
services:
  # Traefik with high availability
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    command:
      - --api.dashboard=true
      - --api.insecure=false
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --providers.file.directory=/traefik/dynamic
      - --providers.file.watch=true
      - --entrypoints.web.address=:80
      - --entrypoints.web.http.redirections.entryPoint.to=websecure
      - --entrypoints.web.http.redirections.entryPoint.scheme=https
      - --entrypoints.websecure.address=:443
      - --log.level=INFO
      - --accesslog=true
      - --metrics.prometheus=true
      - --metrics.prometheus.addEntryPointsLabels=true
      - --metrics.prometheus.addServicesLabels=true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /opt/nexus/traefik/dynamic:/traefik/dynamic:ro
      - /opt/nexus/traefik/certs:/certs:ro
    networks:
      - gateway
    labels:
      - traefik.enable=true
      - traefik.http.routers.traefik-dash.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/traefik`)
      - traefik.http.routers.traefik-dash.entrypoints=websecure
      - traefik.http.routers.traefik-dash.tls=true
      - traefik.http.routers.traefik-dash.service=api@internal
      - traefik.http.routers.traefik-dash.priority=100
      - traefik.http.middlewares.traefik-dash-strip.stripprefix.prefixes=/traefik
      - traefik.http.routers.traefik-dash.middlewares=traefik-dash-strip@docker
    healthcheck:
      test: ["CMD", "traefik", "healthcheck", "--ping"]
      interval: 10s
      timeout: 5s
      retries: 3
```

---

## 🖥️ **Phase 3: Stakeholder PC Integration (Days 8-10)**

### **3.1 PC Imaging Strategy**

#### **Free Solutions**:
- **Clonezilla** - Disk imaging
- **FOG Project** - Network boot and imaging
- **PXE Boot** - Network booting
- **Ansible** - Configuration management

#### **Implementation**:
```bash
#!/bin/bash
# PC imaging and configuration script

# Create base image with NXCore client configuration
create_base_image() {
    # Install required software
    apt-get update
    apt-get install -y curl wget git docker.io docker-compose
    
    # Configure NXCore client
    cat > /etc/nxcore-client.conf << EOF
# NXCore Client Configuration
NXCore_SERVER=nxcore.tail79107c.ts.net
NXCore_USER=stakeholder
NXCore_AUTO_UPDATE=true
NXCore_MONITORING=true
EOF
    
    # Create startup script
    cat > /usr/local/bin/nxcore-startup.sh << 'EOF'
#!/bin/bash
# NXCore client startup script

# Check server connectivity
if curl -k -s https://nxcore.tail79107c.ts.net/ >/dev/null; then
    echo "NXCore server is accessible"
    # Start client services
    systemctl start nxcore-client
else
    echo "NXCore server is not accessible"
    exit 1
fi
EOF
    
    chmod +x /usr/local/bin/nxcore-startup.sh
    
    # Create systemd service
    cat > /etc/systemd/system/nxcore-client.service << 'EOF'
[Unit]
Description=NXCore Client Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nxcore-startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl enable nxcore-client.service
}
```

### **3.2 High-Trust Security Configuration**

#### **Free Solutions**:
- **Tailscale** - Zero-trust networking (already installed)
- **Authelia** - SSO/MFA (already installed)
- **UFW** - Firewall configuration
- **Fail2ban** - Intrusion prevention

#### **Implementation**:
```bash
#!/bin/bash
# High-trust security configuration

# Configure firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 443/tcp
ufw allow 80/tcp
ufw --force enable

# Configure fail2ban
apt-get install -y fail2ban
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl start fail2ban

# Configure Tailscale ACL
cat > /etc/tailscale/acl.json << EOF
{
  "acls": [
    {
      "action": "accept",
      "src": ["group:stakeholders"],
      "dst": ["nxcore.tail79107c.ts.net:*"]
    }
  ],
  "groups": {
    "group:stakeholders": ["user:stakeholder1@example.com", "user:stakeholder2@example.com"]
  }
}
EOF
```

### **3.3 Automated PC Management**

#### **Free Solutions**:
- **Ansible** - Configuration management
- **Cockpit** - Web-based management
- **Webmin** - System administration
- **Grafana** - Monitoring dashboards

#### **Implementation**:
```yaml
# Ansible playbook for PC management
---
- name: Configure NXCore Stakeholder PCs
  hosts: stakeholder_pcs
  become: yes
  vars:
    nxcore_server: nxcore.tail79107c.ts.net
    nxcore_user: stakeholder
    
  tasks:
    - name: Install required packages
      apt:
        name:
          - curl
          - wget
          - git
          - docker.io
          - docker-compose
        state: present
        
    - name: Configure NXCore client
      template:
        src: nxcore-client.conf.j2
        dest: /etc/nxcore-client.conf
        
    - name: Create startup script
      template:
        src: nxcore-startup.sh.j2
        dest: /usr/local/bin/nxcore-startup.sh
        mode: '0755'
        
    - name: Enable NXCore client service
      systemd:
        name: nxcore-client
        enabled: yes
        state: started
        
    - name: Configure monitoring
      template:
        src: monitoring.conf.j2
        dest: /etc/nxcore-monitoring.conf
```

---

## 💰 **Ideal Upgrade Path - Cost-Aware**

### **Phase 1: Free Solutions (Immediate)**
- ✅ **Traefik** - Reverse proxy (already installed)
- ✅ **Prometheus** - Metrics collection (already installed)
- ✅ **Grafana** - Visualization (already installed)
- ✅ **Uptime Kuma** - Service monitoring (already installed)
- ✅ **Authelia** - SSO/MFA (already installed)
- ✅ **Tailscale** - Zero-trust networking (already installed)
- ✅ **Docker** - Containerization (already installed)

### **Phase 2: Open Source Enhancements (Free)**
- **Ansible** - Configuration management
- **Cockpit** - Web-based management
- **Webmin** - System administration
- **Clonezilla** - PC imaging
- **FOG Project** - Network boot and imaging
- **PXE Boot** - Network booting

### **Phase 3: Optional Paid Solutions (Future)**
- **Tailscale Business** - Advanced features ($5/user/month)
- **Grafana Cloud** - Managed monitoring ($8/month)
- **Docker Hub Pro** - Private repositories ($5/month)
- **Let's Encrypt** - SSL certificates (free)

### **Phase 4: Enterprise Solutions (Future)**
- **Red Hat Enterprise Linux** - Enterprise OS
- **VMware vSphere** - Virtualization platform
- **Microsoft System Center** - Enterprise management
- **Splunk** - Enterprise monitoring

---

## 📋 **Implementation Timeline**

### **Week 1: Critical Fixes**
- **Day 1-2**: Fix Traefik middleware configuration
- **Day 3-4**: Fix service configuration issues
- **Day 5-7**: Security hardening and testing

### **Week 2: System Enhancement**
- **Day 8-10**: Enhanced monitoring and alerting
- **Day 11-12**: Automated testing framework
- **Day 13-14**: High-availability configuration

### **Week 3: PC Integration**
- **Day 15-17**: PC imaging strategy
- **Day 18-19**: High-trust security configuration
- **Day 20-21**: Automated PC management

---

## 🎯 **Success Metrics**

### **Technical Metrics**
- **Service Availability**: 95%+ (target)
- **Response Time**: <100ms average
- **Container Health**: 100% healthy
- **Security**: Zero critical vulnerabilities

### **Business Metrics**
- **Stakeholder Satisfaction**: 90%+ (target)
- **System Reliability**: 99.9% uptime
- **Cost Efficiency**: 80%+ free/open-source solutions
- **Management Efficiency**: 50%+ automation

---

## 📞 **Support & Maintenance**

### **Free Support Options**
- **Community Forums** - Docker, Traefik, Grafana
- **Documentation** - Official project documentation
- **GitHub Issues** - Open source project support
- **Stack Overflow** - Community support

### **Paid Support Options** (Future)
- **Tailscale Support** - $5/user/month
- **Grafana Support** - $8/month
- **Docker Support** - $5/month
- **Professional Services** - $100-200/hour

---

## 🚀 **Quick Start Implementation**

### **Immediate Actions (Next 2 Hours)**
1. **Deploy middleware fixes**
2. **Restart Traefik**
3. **Test service endpoints**
4. **Verify content delivery**

### **Next 24 Hours**
1. **Complete service configuration**
2. **Implement security hardening**
3. **Set up monitoring**
4. **Test stakeholder PC connectivity**

### **Next Week**
1. **Deploy PC imaging solution**
2. **Configure high-trust security**
3. **Implement automated management**
4. **Conduct stakeholder training**

---

**This comprehensive action plan provides a cost-aware upgrade path utilizing free and open-source solutions while ensuring enterprise-grade reliability for your high-trust internal system serving 10 stakeholder PCs.**
