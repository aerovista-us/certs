# AeroVista Deployment Checklist

**Use this checklist after clean wipe to deploy services in the correct order.**

---

## ✅ Pre-Deployment (10 min)

### Step 1: Clean Wipe (on NXCore)

```bash
# SSH to NXCore
ssh glyph@192.168.7.209

# Stop and remove all containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || echo "No containers to stop"
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || echo "No containers to remove"

# Remove networks
sudo docker network rm gateway backend observability 2>/dev/null || true

# Verify clean state
sudo docker ps -a        # Should be empty
sudo docker network ls   # Only: bridge, host, none
```

### Step 2: Prepare Directories & Certs

```bash
# Create directory structure
sudo mkdir -p /srv/core \
             /opt/nexus/traefik/certs \
             /opt/nexus/traefik/dynamic \
             /opt/nexus/aerocaller/certs \
             /opt/nexus/authelia \
             /opt/nexus/prometheus \
             /srv/core/data \
             /srv/core/config \
             /srv/core/fileshare/www \
             /srv/core/fileshare/uploads \
             /srv/core/config/fileshare \
             /srv/core/config/dashboard

# Set ownership
sudo chown -R glyph:glyph /opt/nexus /srv/core

# Mint/verify Tailscale certificates
if [ ! -f /opt/nexus/traefik/certs/fullchain.pem ]; then
    sudo tailscale cert \
      --cert-file=/opt/nexus/traefik/certs/fullchain.pem \
      --key-file=/opt/nexus/traefik/certs/privkey.pem \
      nxcore.tail79107c.ts.net
    sudo chown -R glyph:glyph /opt/nexus/traefik/certs
fi

# Copy certs for AeroCaller
sudo cp /opt/nexus/traefik/certs/*.pem /opt/nexus/aerocaller/certs/ 2>/dev/null || true
sudo chown -R glyph:glyph /opt/nexus/aerocaller/certs

# Verify
ls -l /opt/nexus/traefik/certs/
```

### Step 3: Pre-Flight Checks

```bash
echo "=== Pre-Flight Checklist ==="
echo "1. Tailscale Status:"
tailscale status | grep nxcore

echo "2. Certificates:"
ls -lh /opt/nexus/traefik/certs/

echo "3. Directory Ownership:"
ls -ld /srv/core /opt/nexus

echo "4. Passwordless Sudo Test:"
sudo docker version > /dev/null && echo "✅ Docker sudo works" || echo "❌ Configure passwordless sudo"

# If passwordless sudo fails, run:
# echo 'glyph ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose, /sbin/install, /usr/bin/mkdir, /usr/bin/chown' | sudo tee /etc/sudoers.d/glyph-docker
# sudo chmod 0440 /etc/sudoers.d/glyph-docker
```

**Exit NXCore SSH:**
```bash
exit
```

**Pre-Deployment Checklist:**
- [ ] SSH to NXCore works without password
- [ ] All containers removed
- [ ] Networks cleaned (only bridge, host, none)
- [ ] Directory structure exists: `/srv/core`, `/opt/nexus`
- [ ] Tailscale certs exist: `/opt/nexus/traefik/certs/fullchain.pem`
- [ ] Passwordless sudo works for Docker

---

## 🔧 Phase 0: Traefik (Gateway) - 5 min

```powershell
.\scripts\ps\deploy-containers.ps1 -Service traefik
```

**Verify:**
- [ ] Container running: `sudo docker ps | grep traefik`
- [ ] Gateway network created: `sudo docker network ls | grep gateway`
- [ ] HTTP responds: `curl -I http://localhost:80` (expect redirect)
- [ ] Dashboard accessible: https://traefik.nxcore.tail79107c.ts.net/dashboard/

**If fails:** Check Tailscale certs, verify ports 80/443 not in use

---

## 🏗️ Phase A: Foundation - 15 min

**Deploy all 5 foundation services at once:**

```powershell
# From Windows PowerShell (in D:\NeXuS\NXCore-Control)
.\scripts\ps\deploy-containers.ps1 -Service foundation
```

This deploys:
1. Docker Socket Proxy (secure Docker API access)
2. PostgreSQL 16 (primary database)
3. Redis (cache & queues)
4. Authelia (SSO/MFA gateway)
5. Landing Page (status dashboard)

**Verify on NXCore (SSH):**

```bash
# Check all containers running
sudo docker ps --format 'table {{.Names}}\t{{.Status}}'

# Should see:
# - docker-socket-proxy
# - postgres
# - redis
# - authelia
# - landing

# Check PostgreSQL
sudo docker exec postgres pg_isready -U aerovista

# Check Redis
sudo docker exec redis redis-cli ping  # Should return: PONG

# Check networks exist
sudo docker network ls | grep -E "gateway|backend|observability"
```

**Verify from Browser:**
- [ ] https://auth.nxcore.tail79107c.ts.net/ loads (Authelia login page)
- [ ] https://nxcore.tail79107c.ts.net/ loads (Landing page)

**⚠️ IMPORTANT: Update Authelia Password**

```bash
# Generate password hash (on NXCore or Windows with Docker)
sudo docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'YourStrongPasswordHere'

# SSH to NXCore and edit users file
ssh glyph@192.168.7.209
sudo nano /opt/nexus/authelia/users_database.yml

# Replace the password hash with the one generated above
# Then restart Authelia
sudo docker restart authelia
```

**✅ Foundation Complete!** All core infrastructure ready.

---

## 📊 Phase E: Observability - 15 min

**Deploy all 5 observability services at once:**

```powershell
# From Windows PowerShell (in D:\NeXuS\NXCore-Control)
.\scripts\ps\deploy-containers.ps1 -Service observability
```

This deploys:
1. Prometheus (metrics collection)
2. Grafana (dashboards & visualization)
3. Uptime Kuma (uptime monitoring)
4. Dozzle (real-time log viewer)
5. cAdvisor (container metrics)

**Verify on NXCore (SSH):**

```bash
# Check all containers running
sudo docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E "prometheus|grafana|uptime|dozzle|cadvisor"

# Should see:
# - prometheus
# - grafana
# - uptime-kuma
# - dozzle
# - cadvisor
```

**Verify from Browser:**
- [ ] https://prometheus.nxcore.tail79107c.ts.net/ loads (protected by Authelia)
- [ ] https://grafana.nxcore.tail79107c.ts.net/ loads
- [ ] https://status.nxcore.tail79107c.ts.net/ loads (Uptime Kuma)
- [ ] https://logs.nxcore.tail79107c.ts.net/ loads (Dozzle)

**Configure Services:**

1. **Uptime Kuma** - Create admin and add monitors:
   ```
   https://status.nxcore.tail79107c.ts.net/
   - Create admin account
   - Add monitors for all service URLs
   - Set check interval to 60s
   ```

2. **Grafana** - Import dashboards:
   ```
   Login: admin / admin (change on first login)
   - Import dashboard 1860 (Node Exporter Full)
   - Import dashboard 893 (Docker & System Monitoring)
   - Verify Prometheus datasource connected
   ```

3. **Prometheus** - Check targets:
   ```
   https://prometheus.nxcore.tail79107c.ts.net/targets
   - Verify all exporters are UP
   ```

**✅ Observability Complete!** Can now monitor everything.

---

## 🤖 Phase C: AI - 10 min (+ model download time)

**Deploy both AI services at once:**

```powershell
# From Windows PowerShell (in D:\NeXuS\NXCore-Control)
.\scripts\ps\deploy-containers.ps1 -Service ai
```

This deploys:
1. Ollama (local LLM runtime)
2. Open WebUI (ChatGPT-like interface)

**Note:** The script automatically pulls `llama3.2` model (~4GB), which takes 5-10 minutes on first run.

**Verify on NXCore (SSH):**

```bash
# Check containers running
sudo docker ps | grep -E "ollama|openwebui"

# Verify Ollama has models
sudo docker exec ollama ollama list
# Should show: llama3.2

# Check logs if needed
sudo docker logs ollama --tail 50
sudo docker logs openwebui --tail 50
```

**Verify from Browser:**
- [ ] https://ai.nxcore.tail79107c.ts.net/ loads (Open WebUI)

**Configure Open WebUI:**

1. Create your admin account (first user = admin)
2. Test AI chat:
   - Click "New Chat"
   - Type: "What is AeroVista?"
   - Verify llama3.2 responds

**✅ AI Complete!** Private AI assistant ready (100% local, no external API calls).

---

## 🖥️ Phase B: Browser Workspaces - 6-9 hours

### Prerequisites (Must Complete First)
```bash
# 1. Generate Self-Signed Wildcard Certificate
sudo mkdir -p /opt/nexus/traefik/certs
cd /opt/nexus/traefik/certs

# Generate self-signed certificate for subdomains
sudo openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"

# Set proper permissions
sudo chown root:root self-signed.*
sudo chmod 600 self-signed.key
sudo chmod 644 self-signed.crt

# 2. Update Traefik Configuration
# Edit /opt/nexus/traefik/dynamic/traefik-dynamic.yml
# Add self-signed certificate configuration

# 3. Restart Traefik
sudo docker restart traefik

# 4. Verify DNS Resolution
nslookup grafana.nxcore.tail79107c.ts.net
nslookup prometheus.nxcore.tail79107c.ts.net
```

### 13. Deploy All Browser Workspace Services
```powershell
.\scripts\ps\deploy-containers.ps1 -Service workspaces
```

**This deploys:**
- VNC Server (Remote Desktop)
- NoVNC (Web VNC Client)
- Guacamole (HTML5 Remote Desktop Gateway)
- Code Server (VS Code in Browser)
- Jupyter (Interactive Notebooks)
- RStudio (R Development Environment)

**Verify:** 
- [ ] VNC Desktop: https://vnc.nxcore.tail79107c.ts.net/
- [ ] VS Code: https://code.nxcore.tail79107c.ts.net/
- [ ] Jupyter: https://jupyter.nxcore.tail79107c.ts.net/
- [ ] RStudio: https://rstudio.nxcore.tail79107c.ts.net/
- [ ] Guacamole: https://guac.nxcore.tail79107c.ts.net/

## 📱 Phase B: Apps - 10 min

### 14. n8n (Workflows)
```powershell
.\scripts\ps\deploy-containers.ps1 -Service n8n
```
**Verify:** 
- [ ] https://n8n.nxcore.tail79107c.ts.net/ loads
- [ ] Create account
- [ ] Can create workflow

### 14. File Sharing System
```powershell
.\scripts\ps\deploy-containers.ps1 -Service fileshare
```
**Verify:** 
- [ ] http://100.115.9.61:8082/ loads (Drop & Go interface)
- [ ] http://100.115.9.61:8082/files.html loads (File Manager)
- [ ] Can drag & drop files to upload
- [ ] Can browse, download, and delete files
- [ ] PHP backend processes uploads correctly

### 15. NXCore Dashboard
```powershell
# Deploy dashboard service
.\scripts\ps\deploy-containers.ps1 -Service dashboard

# Start dashboard on NXCore screen
ssh glyph@100.115.9.61 "/tmp/start-dashboard.sh"
```
**Verify:** 
- [ ] http://100.115.9.61:8081/ loads (Dashboard service)
- [ ] Chromium displays dashboard on NXCore screen
- [ ] Dashboard shows live service status
- [ ] All service links work correctly

### 16. FileBrowser (Legacy)
```powershell
.\scripts\ps\deploy-containers.ps1 -Service filebrowser
```
**Verify:** 
- [ ] https://files.nxcore.tail79107c.ts.net/ loads
- [ ] Login: admin / admin (change password!)
- [ ] Can browse /srv/core

### 17. Portainer
```powershell
.\scripts\ps\deploy-containers.ps1 -Service portainer
```
**Verify:** 
- [ ] https://portainer.nxcore.tail79107c.ts.net/ loads
- [ ] **IMPORTANT:** Create admin within 5 minutes!
- [ ] Can see local environment with all containers

### 16. AeroCaller
```powershell
.\scripts\ps\deploy-containers.ps1 -Service aerocaller
```
**Verify:** 
- [ ] https://nxcore.tail79107c.ts.net:4443/ loads
- [ ] Can join call (WebRTC connects)

**✅ Apps Complete!** All core applications running.

---

## 🎯 Final Verification

### Check All Services
```bash
# On NXCore
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

**Expected containers (16 total):**
- [ ] traefik
- [ ] docker-socket-proxy
- [ ] postgres
- [ ] redis
- [ ] authelia
- [ ] landing
- [ ] prometheus
- [ ] grafana
- [ ] uptime-kuma
- [ ] dozzle
- [ ] cadvisor
- [ ] ollama
- [ ] openwebui
- [ ] n8n
- [ ] filebrowser
- [ ] portainer
- [ ] aerocaller (if deployed)

### Check Networks
```bash
sudo docker network inspect gateway | grep -A2 '"Name"'
sudo docker network inspect backend | grep -A2 '"Name"'
sudo docker network inspect observability | grep -A2 '"Name"'
```

**Expected:**
- [ ] gateway: traefik, authelia, landing, grafana, prometheus, uptime-kuma, dozzle, openwebui, n8n, filebrowser, portainer
- [ ] backend: docker-socket-proxy, postgres, redis, authelia, grafana, openwebui, ollama
- [ ] observability: prometheus, grafana, cadvisor

### Test URLs (from browser)
- [ ] https://nxcore.tail79107c.ts.net/ (Landing)
- [ ] https://traefik.nxcore.tail79107c.ts.net/dashboard/ (Traefik)
- [ ] https://auth.nxcore.tail79107c.ts.net/ (Authelia)
- [ ] https://prometheus.nxcore.tail79107c.ts.net/ (Prometheus)
- [ ] https://grafana.nxcore.tail79107c.ts.net/ (Grafana)
- [ ] https://status.nxcore.tail79107c.ts.net/ (Uptime Kuma)
- [ ] https://logs.nxcore.tail79107c.ts.net/ (Dozzle)
- [ ] https://ai.nxcore.tail79107c.ts.net/ (AI Assistant)
- [ ] https://n8n.nxcore.tail79107c.ts.net/ (n8n)
- [ ] https://files.nxcore.tail79107c.ts.net/ (FileBrowser)
- [ ] https://portainer.nxcore.tail79107c.ts.net/ (Portainer)
- [ ] https://nxcore.tail79107c.ts.net:4443/ (AeroCaller)

### Health Checks
```bash
# All should be healthy
sudo docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -v "Up.*healthy"
```

**If any unhealthy:** Check logs with `sudo docker logs <container>`

---

## 📝 Post-Deployment Tasks

### 1. Update Authelia Password
```bash
# Generate hash
sudo docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'YourStrongPassword'

# Edit file
sudo nano /opt/nexus/authelia/users_database.yml

# Restart Authelia
sudo docker restart authelia
```

### 2. Configure Uptime Kuma Monitors
- Add monitors for all service URLs
- Set check interval to 60s
- Configure notifications (optional)

### 3. Configure Grafana Dashboards
- Import dashboard: 1860 (Node Exporter Full)
- Import dashboard: 893 (Docker & System Monitoring)
- Create custom dashboard for service health

### 4. Test AI Assistant
- Open https://ai.nxcore.tail79107c.ts.net/
- Ask: "What is AeroVista?"
- Verify response from llama3.2

### 5. Update Landing Page
- Edit `/srv/core/landing/index.html`
- Update service URLs if needed
- Refresh browser to see changes

---

## 🚨 Troubleshooting

### Container won't start
```bash
sudo docker logs <container> --tail 50
sudo docker inspect <container> | jq '.[].State'
```

### Network issues
```bash
sudo docker network inspect gateway
sudo docker restart <container>
```

### Authelia login fails
- Check password hash in `/opt/nexus/authelia/users_database.yml`
- Check Redis connection: `sudo docker exec redis redis-cli ping`
- Check logs: `sudo docker logs authelia`

### Prometheus no targets
- Check `/srv/core/config/prometheus/prometheus.yml`
- Verify services on observability network
- Restart Prometheus: `sudo docker restart prometheus`

### AI not responding
- Check Ollama has model: `sudo docker exec ollama ollama list`
- Check Open WebUI logs: `sudo docker logs openwebui`
- Verify backend network connection

---

## ⏱️ Total Time Estimate

- Pre-deployment: 5 min
- Phase 0 (Traefik): 5 min
- Phase A (Foundation): 15 min
- Phase E (Observability): 15 min
- Phase C (AI): 10 min (+ model download)
- Phase B (Apps): 10 min
- Verification: 10 min
- **Total: ~70 minutes**

---

## ✅ Success Criteria

You're done when:
- [ ] All 16+ containers running
- [ ] No unhealthy containers
- [ ] All URLs accessible from browser
- [ ] Authelia login works
- [ ] AI assistant responds to queries
- [ ] Uptime Kuma shows all services green
- [ ] Grafana dashboards show metrics
- [ ] No port conflicts
- [ ] No network issues

**🎉 Congratulations! Your AeroVista infrastructure is fully deployed!**

---

**Next Steps:**
- Add more services as needed (Phase B, D, F, G)
- Configure backups
- Set up monitoring alerts
- Onboard team members
- Build workflows in n8n

