# NXCore Clean Installation Guide
**The Right Way: Traefik-First Architecture**

## Why Clean Install?

After 200+ pages of troubleshooting, we've learned:
- ✅ Deploy Traefik **FIRST** (it owns the gateway network)
- ✅ Never publish host ports for proxied services
- ✅ Set up SSH keys before any automation
- ✅ Mint certs once, use everywhere

This guide gets you from zero to fully-functional in ~30 minutes.

---

## Pre-Flight Checklist

### On NXCore (via SSH)
```bash
# 1. Stop and remove ALL containers
sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)

# 2. Remove all networks (except built-in)
sudo docker network rm gateway 2>/dev/null || true

# 3. Clean volumes (OPTIONAL - only if starting truly fresh)
# ⚠️ THIS DELETES ALL DATA - n8n workflows, portainer config, etc.
# sudo docker volume rm $(sudo docker volume ls -q)

# 4. Verify clean slate
sudo docker ps -a
sudo docker network ls
sudo docker volume ls
```

### On Windows (PowerShell)
```powershell
# Ensure you're in the repo root
cd D:\NeXuS\NXCore-Control

# Verify files exist
ls docker/*.yml
ls scripts/ps/deploy-containers.ps1
```

---

## Phase 1: SSH Key Setup (5 min)

**Goal:** Eliminate password prompts

### On Windows
```powershell
# Generate SSH key (if you don't have one)
if (!(Test-Path ~/.ssh/id_ed25519)) {
    ssh-keygen -t ed25519 -C "glyph@nxcore" -f ~/.ssh/id_ed25519 -N '""'
}

# Copy public key to NXCore
Get-Content ~/.ssh/id_ed25519.pub | ssh glyph@192.168.7.209 "cat >> ~/.ssh/authorized_keys"
```

### On NXCore (via SSH)
```bash
# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Configure passwordless sudo for Docker
echo 'glyph ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose, /sbin/install, /usr/bin/mkdir, /usr/bin/chown' | sudo tee /etc/sudoers.d/glyph-docker
sudo chmod 0440 /etc/sudoers.d/glyph-docker

# Test - should NOT ask for password:
sudo docker ps
```

### Verify
```powershell
# From Windows - should connect without password:
ssh glyph@192.168.7.209 "echo 'SSH key works!'"
```

---

## Phase 2: Tailscale Certificates (5 min)

**Goal:** Mint wildcard cert for all services

### On NXCore
```bash
# Create cert directories
sudo mkdir -p /opt/nexus/traefik/certs
sudo mkdir -p /opt/nexus/aerocaller/certs

# Mint Tailscale certificate (replace with YOUR tailnet domain)
sudo tailscale cert \
  --cert-file=/opt/nexus/traefik/certs/fullchain.pem \
  --key-file=/opt/nexus/traefik/certs/privkey.pem \
  nxcore.tail79107c.ts.net

# Copy for AeroCaller (uses Node-terminated TLS)
sudo cp /opt/nexus/traefik/certs/*.pem /opt/nexus/aerocaller/certs/

# Set ownership
sudo chown -R glyph:glyph /opt/nexus/traefik
sudo chown -R glyph:glyph /opt/nexus/aerocaller

# Verify
ls -l /opt/nexus/traefik/certs/
```

---

## Phase 3: Deploy Traefik (Gateway) (3 min)

**Goal:** Establish reverse proxy foundation

### From Windows PowerShell
```powershell
.\scripts\ps\deploy-containers.ps1 -Service traefik
```

### Verify on NXCore
```bash
sudo docker ps --filter name=traefik --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
# Expected: traefik   Up X seconds   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp

# Check gateway network
sudo docker network inspect gateway | grep -A5 '"Name": "traefik"'

# Check Traefik logs
sudo docker logs traefik --tail 20
# Should see: "Configuration loaded from file" and no errors

# Test HTTP endpoint
curl -I http://localhost:80
# Expected: 404 (no routes yet - that's correct)

# Test Traefik dashboard (if enabled)
curl -H "Host: traefik.nxcore.tail79107c.ts.net" http://localhost:80/api/rawdata
```

✅ **Checkpoint:** Traefik running, gateway network exists, ports 80/443 bound

---

## Phase 4: Deploy n8n (Behind Traefik) (2 min)

**Goal:** First service routed through Traefik

### From Windows PowerShell
```powershell
.\scripts\ps\deploy-containers.ps1 -Service n8n
```

### Verify on NXCore
```bash
# Container should be on gateway network with NO published ports
sudo docker ps --filter name=n8n --format 'table {{.Names}}\t{{.Ports}}'
# Expected: n8n   (empty - no published ports)

# Check it joined gateway
sudo docker inspect n8n --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}: {{$v.IPAddress}}{{end}}'
# Expected: gateway: 172.21.0.X

# Test Traefik routing
curl -H "Host: n8n.nxcore.tail79107c.ts.net" http://localhost:80/
# Expected: n8n login page HTML or redirect

# From another tailnet device:
# Open: https://n8n.nxcore.tail79107c.ts.net/
```

✅ **Checkpoint:** n8n accessible via Traefik, no host ports

---

## Phase 5: Deploy FileBrowser (2 min)

### From Windows PowerShell
```powershell
.\scripts\ps\deploy-containers.ps1 -Service filebrowser
```

### Verify
```bash
sudo docker ps --filter name=filebrowser --format 'table {{.Names}}\t{{.Ports}}'
# Expected: filebrowser   (no published ports)

curl -H "Host: files.nxcore.tail79107c.ts.net" http://localhost:80/
# Expected: FileBrowser UI HTML

# From browser:
# https://files.nxcore.tail79107c.ts.net/
```

✅ **Checkpoint:** FileBrowser accessible via Traefik

---

## Phase 6: Deploy Portainer (3 min)

**CRITICAL:** You have 5 minutes after deployment to create admin user!

### From Windows PowerShell
```powershell
.\scripts\ps\deploy-containers.ps1 -Service portainer
```

### IMMEDIATELY After Deployment
```bash
# Verify container started
sudo docker logs portainer --tail 10
# Should see: "Portainer started successfully"

# Get Traefik route
curl -H "Host: portainer.nxcore.tail79107c.ts.net" http://localhost:80/api/status
# Expected: JSON or redirect to setup page
```

**⏰ URGENT:** Within 5 minutes, open in browser:
```
https://portainer.nxcore.tail79107c.ts.net/
```

1. Create admin username/password
2. Skip environment wizard (it auto-detects local Docker)
3. Click "Get Started"

✅ **Checkpoint:** Portainer admin created, can see local environment

---

## Phase 7: Deploy AeroCaller (3 min)

**Special case:** Uses Node-terminated HTTPS (not Traefik-proxied)

### From Windows PowerShell
```powershell
.\scripts\ps\deploy-containers.ps1 -Service aerocaller
```

### Verify
```bash
sudo docker ps --filter name=aerocaller --format 'table {{.Names}}\t{{.Ports}}'
# Expected: aerocaller   0.0.0.0:4443->4443/tcp

# Test HTTPS directly
curl -k https://localhost:4443/api/readyz
# Expected: {"ok":true}

# From browser (tailnet device):
# https://nxcore.tail79107c.ts.net:4443/index.staff.html
```

**Optional:** Map via Tailscale Serve for cleaner URL
```bash
sudo tailscale serve --bg --https=443 --set-path=/call https+insecure://localhost:4443
# Then access: https://nxcore.tail79107c.ts.net/call/index.staff.html
```

✅ **Checkpoint:** AeroCaller running with WebRTC/PeerJS

---

## Phase 8: Deploy Auxiliary Services (5 min)

### Watchtower (Auto-updates)
```bash
sudo docker run -d --name watchtower --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower:latest --cleanup --include-restarting --interval 86400
```

### Node Exporter (Metrics)
```bash
sudo docker run -d --name node_exporter --pid=host --net=host --restart unless-stopped \
  quay.io/prometheus/node-exporter:latest
```

### Coturn (TURN Server)
```bash
cd /opt/nexus
sudo mkdir -p coturn && cd coturn

# Create .env
sudo tee .env >/dev/null <<'EOF'
REALM=nxcore.tail79107c.ts.net
TURN_USER=auser
TURN_PASS=apass
UDP_MIN_PORT=49160
UDP_MAX_PORT=49200
USE_TLS=0
EOF

# Create docker-compose.yml
sudo tee docker-compose.yml >/dev/null <<'YAML'
version: "3.9"
services:
  coturn:
    image: coturn/coturn:latest
    container_name: coturn
    network_mode: host
    restart: unless-stopped
    env_file: .env
    command: >
      bash -lc 'exec turnserver
        --log-file=stdout --simple-log --fingerprint
        --realm=${REALM} --listening-port=3478
        --min-port=${UDP_MIN_PORT} --max-port=${UDP_MAX_PORT}
        --lt-cred-mech --user ${TURN_USER}:${TURN_PASS}
        --no-tls --no-dtls'
YAML

sudo docker compose up -d
```

### Media Backup Timer
```bash
sudo mkdir -p /opt/nexus/scripts

# Copy from repo (if you have the script)
# Or create manually - see build files/media-backup.*

sudo systemctl daemon-reload
sudo systemctl enable --now media-backup.timer
```

✅ **Checkpoint:** All auxiliary services running

---

## Phase 9: Verification & Documentation (5 min)

### Service Inventory

| Service | URL | Purpose |
|---------|-----|---------|
| Traefik Dashboard | https://traefik.nxcore.tail79107c.ts.net/ | Reverse proxy admin |
| n8n | https://n8n.nxcore.tail79107c.ts.net/ | Workflow automation |
| FileBrowser | https://files.nxcore.tail79107c.ts.net/ | File management |
| Portainer | https://portainer.nxcore.tail79107c.ts.net/ | Container management |
| AeroCaller | https://nxcore.tail79107c.ts.net:4443/ | WebRTC calling |
| Node Exporter | http://nxcore:9100/metrics | Prometheus metrics |

### Health Checks
```bash
# All containers should be Up
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Gateway network should have 4 containers
sudo docker network inspect gateway --format '{{len .Containers}} containers'

# Traefik should see all routers
sudo docker exec traefik sh -c 'wget -qO- http://localhost/api/http/routers' | jq '.[].name'
# Expected: n8n@docker, filebrowser@docker, portainer@docker, traefik-dash@docker

# Tailscale status
tailscale status | grep nxcore
```

### Test From Another Device
```bash
# From a laptop/phone on the same tailnet:
curl -I https://n8n.nxcore.tail79107c.ts.net/
curl -I https://files.nxcore.tail79107c.ts.net/
curl -I https://portainer.nxcore.tail79107c.ts.net/
```

✅ **Final Checkpoint:** All services accessible via HTTPS from tailnet

---

## What Changed From Old Setup?

### Before (Broken)
```
[n8n:5678] ──┐
[files:8080]─┼─→ [Tailscale Serve] → Tailnet
[portainer:9443]─┘    ↑
                      Port conflicts, timeouts, routing failures
```

### After (Clean)
```
                    ┌─→ [n8n]
[Traefik:80/443] ──┼─→ [FileBrowser]
       ↑            ├─→ [Portainer]
       │            └─→ Dashboard
[Tailscale MagicDNS]
       ↓
  *.nxcore.tail79107c.ts.net

[AeroCaller:4443] ─→ Direct HTTPS (Node TLS)
```

**Key Improvements:**
- ✅ Single reverse proxy (Traefik)
- ✅ No port conflicts (only 80, 443, 4443 published)
- ✅ Proper TLS everywhere (Tailscale certs)
- ✅ All services on gateway network
- ✅ No password prompts (SSH keys)

---

## Troubleshooting

### "Permission denied" during deployment
```bash
# Re-check sudoers file:
sudo visudo -c
sudo cat /etc/sudoers.d/glyph-docker
```

### Service not accessible via Traefik
```bash
# Check container is on gateway network:
sudo docker inspect <service> --format '{{json .NetworkSettings.Networks}}' | jq

# Check Traefik sees it:
sudo docker logs traefik | grep <service>

# Check labels:
sudo docker inspect <service> --format '{{range $k,$v := .Config.Labels}}{{println $k "=" $v}}{{end}}' | grep traefik
```

### Portainer timeout loop
```bash
# Restart and access IMMEDIATELY:
sudo docker restart portainer
# Open browser within 30 seconds:
# https://portainer.nxcore.tail79107c.ts.net/
```

### Traefik shows 404 for all routes
```bash
# Check dynamic config loaded:
sudo docker exec traefik cat /etc/traefik/dynamic/traefik-dynamic.yml

# Check file provider enabled:
sudo docker logs traefik | grep "Configuration loaded"
```

---

## Maintenance

### Updating Containers
```bash
# Watchtower does this automatically every 24h
# Or manually:
cd /srv/core
sudo docker compose -f compose-<service>.yml pull
sudo docker compose -f compose-<service>.yml up -d
```

### Backing Up
```bash
# Portainer data
sudo docker run --rm -v portainer_data:/data -v $PWD:/backup alpine \
  tar czf /backup/portainer-$(date +%F).tgz -C /data .

# n8n data
sudo docker run --rm -v n8n_data:/data -v $PWD:/backup alpine \
  tar czf /backup/n8n-$(date +%F).tgz -C /data .

# FileBrowser database
sudo docker exec filebrowser cat /database.db > filebrowser-$(date +%F).db
```

### Monitoring
```bash
# Container health
sudo docker ps --format 'table {{.Names}}\t{{.Status}}'

# Logs
sudo docker compose -f /srv/core/compose-traefik.yml logs -f --tail=50

# Disk usage
sudo docker system df
```

---

## Next Steps

Once everything is stable:

1. **Add DNS records** (if using public domain)
2. **Configure backups** to run automatically
3. **Set up monitoring** (Grafana + Prometheus)
4. **Document workflows** in n8n
5. **Create Portainer templates** for common stacks

---

**Total Time:** ~30 minutes  
**Result:** Production-ready Traefik-first stack with HTTPS everywhere

*See `TROUBLESHOOTING_COMPLETE_REPORT.md` for what NOT to do.*

