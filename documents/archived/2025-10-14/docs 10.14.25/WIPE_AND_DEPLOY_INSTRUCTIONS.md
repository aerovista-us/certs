# 🧹 Wipe & Deploy Instructions

**Complete clean wipe + fresh deployment guide**

**Total Time:** ~70 minutes (includes wipe, setup, and full deployment)

---

## 📋 Quick Reference

### Phase 0: Clean Wipe (~10 min)

1. SSH to NXCore
2. Stop/remove containers and networks
3. Prepare directories and certificates

### Phase 1: Gateway (~5 min)

- Deploy Traefik

### Phase 2: Foundation (~15 min)

- Deploy: docker-socket-proxy, postgres, redis, authelia, landing

### Phase 3: Observability (~15 min)

- Deploy: prometheus, grafana, uptime-kuma, dozzle, cadvisor

### Phase 4: AI (~15 min + model download)

- Deploy: ollama, openwebui

### Phase 5: Apps (~10 min)

- Deploy: n8n, filebrowser, portainer, aerocaller

---

## 🧹 STEP 1: Clean Wipe (on NXCore)

### 1.1 SSH to NXCore

```bash
# Use Tailscale IP for reliable connectivity
ssh glyph@100.115.9.61

# Or use local IP if on same network
# ssh glyph@192.168.7.209
```

### 1.2 Stop & Remove Containers

```bash
# Stop all running containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || echo "No containers to stop"

# Remove all containers
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || echo "No containers to remove"

# Verify (should be empty)
sudo docker ps -a
```

### 1.3 Remove Networks

```bash
# Remove custom networks
sudo docker network rm gateway backend observability 2>/dev/null || true

# Verify (should only show: bridge, host, none)
sudo docker network ls
```

### 1.4 Optional: Clean Volumes

**⚠️ WARNING:** This deletes ALL data (n8n workflows, Portainer config, etc.)

```bash
# List volumes first
sudo docker volume ls

# If you want to start 100% fresh:
sudo docker volume prune -f

# Or remove specific volumes:
# sudo docker volume rm n8n_data portainer_data
```

### 1.5 Clean System (Free Disk Space)

```bash
# Remove unused images and build cache
sudo docker system prune -af

# Check disk space
df -h /
```

### 1.6 Prepare Directories

```bash
# Create directory structure
sudo mkdir -p /srv/core \
             /opt/nexus/traefik/certs \
             /opt/nexus/traefik/dynamic \
             /opt/nexus/aerocaller/certs \
             /opt/nexus/authelia \
             /opt/nexus/prometheus \
             /srv/core/data \
             /srv/core/config

# Set ownership
sudo chown -R glyph:glyph /opt/nexus /srv/core

# Verify
ls -ld /srv/core /opt/nexus
```

### 1.7 Verify/Mint Tailscale Certificates

```bash
# Check if certs exist
ls -l /opt/nexus/traefik/certs/

# If missing, mint new certs
if [ ! -f /opt/nexus/traefik/certs/fullchain.pem ]; then
    echo "Minting Tailscale certificates..."
    sudo tailscale cert \
      --cert-file=/opt/nexus/traefik/certs/fullchain.pem \
      --key-file=/opt/nexus/traefik/certs/privkey.pem \
      nxcore.tail79107c.ts.net
  
    sudo chown -R glyph:glyph /opt/nexus/traefik/certs
fi

# Copy certs for AeroCaller
sudo cp /opt/nexus/traefik/certs/*.pem /opt/nexus/aerocaller/certs/ 2>/dev/null || true
sudo chown -R glyph:glyph /opt/nexus/aerocaller/certs

# Verify certs exist
ls -lh /opt/nexus/traefik/certs/
```

### 1.8 Pre-Flight Checks

```bash
echo "=== Pre-Flight Checklist ==="
echo ""
echo "1. Tailscale Status:"
tailscale status | grep nxcore
echo ""
echo "2. Certificates:"
ls -lh /opt/nexus/traefik/certs/
echo ""
echo "3. Directory Ownership:"
ls -ld /srv/core /opt/nexus
echo ""
echo "4. Passwordless Sudo Test:"
sudo docker version > /dev/null && echo "✅ Docker sudo works" || echo "❌ Configure passwordless sudo"
echo ""
echo "=== System Ready! ==="
```

**If passwordless sudo doesn't work:**

```bash
echo 'glyph ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose, /sbin/install, /usr/bin/mkdir, /usr/bin/chown' | sudo tee /etc/sudoers.d/glyph-docker
sudo chmod 0440 /etc/sudoers.d/glyph-docker
```

### 1.9 Exit NXCore

```bash
exit
```

✅ **Wipe Complete!** System is clean and ready for deployment.

---

## 🚀 STEP 2: Deploy Services (from Windows PowerShell)

Open PowerShell in: `D:\NeXuS\NXCore-Control\`

```powershell
cd D:\NeXuS\NXCore-Control
```

### 2.1 Phase 0: Traefik (Gateway) - 5 min

```powershell
.\scripts\ps\deploy-containers.ps1 -Service traefik
```

**What it does:**

- Creates `gateway`, `backend`, `observability` Docker networks
- Deploys Traefik reverse proxy on ports 80/443
- Mounts Tailscale certificates for HTTPS

**Verify:**

```powershell
# Open in browser
https://traefik.nxcore.tail79107c.ts.net/dashboard/
```

✅ Traefik dashboard should load

---

### 2.2 Phase A: Foundation - 15 min

```powershell
.\scripts\ps\deploy-containers.ps1 -Service foundation
```

**What it deploys:**

1. Docker Socket Proxy (secure Docker API access)
2. PostgreSQL 16 (primary database)
3. Redis (cache & queues)
4. Authelia (SSO/MFA gateway)
5. Landing Page (status dashboard)

**Verify in browser:**

- ✅ https://auth.nxcore.tail79107c.ts.net/ (Authelia login)
- ✅ https://nxcore.tail79107c.ts.net/ (landing page)

**⚠️ IMPORTANT: Update Authelia Password**

```bash
# SSH to NXCore
ssh glyph@192.168.7.209

# Generate password hash
sudo docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'YourStrongPassword'

# Edit users file and replace hash
sudo nano /opt/nexus/authelia/users_database.yml

# Restart Authelia
sudo docker restart authelia
exit
```

---

### 2.3 Phase E: Observability - 15 min

```powershell
.\scripts\ps\deploy-containers.ps1 -Service observability
```

**What it deploys:**

1. Prometheus (metrics collection)
2. Grafana (dashboards)
3. Uptime Kuma (uptime monitoring)
4. Dozzle (real-time log viewer)
5. cAdvisor (container metrics)

**Verify in browser:**

- ✅ https://prometheus.nxcore.tail79107c.ts.net/
- ✅ https://grafana.nxcore.tail79107c.ts.net/ (login: admin/admin)
- ✅ https://status.nxcore.tail79107c.ts.net/ (create admin account)
- ✅ https://logs.nxcore.tail79107c.ts.net/

---

### 2.4 Phase C: AI - 15 min (+ model download)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service ai
```

**What it deploys:**

1. Ollama (local LLM runtime)
2. Open WebUI (ChatGPT-like interface)

**Note:** First run automatically downloads llama3.2 model (~4GB), takes 5-10 minutes.

**Verify in browser:**

- ✅ https://ai.nxcore.tail79107c.ts.net/
- Create admin account (first user becomes admin)
- Test chat with llama3.2

---

### 2.5 Phase B: Apps - 10 min

Deploy existing applications individually:

```powershell
# n8n (Workflow Automation)
.\scripts\ps\deploy-containers.ps1 -Service n8n

# FileBrowser
.\scripts\ps\deploy-containers.ps1 -Service filebrowser

# Portainer
.\scripts\ps\deploy-containers.ps1 -Service portainer

# AeroCaller
.\scripts\ps\deploy-containers.ps1 -Service aerocaller
```

**⚠️ IMPORTANT:** Open Portainer within 5 minutes to create admin!

---

### Or Deploy Everything at Once

```powershell
.\scripts\ps\deploy-containers.ps1 -Service all
```

---

## Step 5: Final Verification

### Check All Containers (SSH)

```bash
ssh glyph@192.168.7.209
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

**Expected: 17+ containers, all "Up" and "healthy"**

### Check URLs (Browser)

- ✅ https://nxcore.tail79107c.ts.net/ (Landing)
- ✅ https://traefik.nxcore.tail79107c.ts.net/dashboard/
- ✅ https://auth.nxcore.tail79107c.ts.net/
- ✅ https://ai.nxcore.tail79107c.ts.net/
- ✅ https://status.nxcore.tail79107c.ts.net/
- ✅ https://logs.nxcore.tail79107c.ts.net/
- ✅ https://prometheus.nxcore.tail79107c.ts.net/
- ✅ https://grafana.nxcore.tail79107c.ts.net/
- ✅ https://n8n.nxcore.tail79107c.ts.net/
- ✅ https://files.nxcore.tail79107c.ts.net/
- ✅ https://portainer.nxcore.tail79107c.ts.net/

---

## 🎉 Done!

**Total time: ~70 minutes**

---

## 📚 Next Steps

1. **Configure Uptime Kuma:** Add monitors for all services
2. **Configure Grafana:** Import dashboards (1860, 893)
3. **Test AI:** Ask it a question
4. **Create n8n workflows:** Automate tasks
5. **Add more services:** See `docs/AEROVISTA_COMPLETE_STACK.md`

---

## 🚨 If Something Goes Wrong

1. Check logs: `sudo docker logs <container>`
2. Check health: `sudo docker ps --format 'table {{.Names}}\t{{.Status}}'`
3. Check networks: `sudo docker network inspect gateway`
4. See: `docs/DEPLOYMENT_CHECKLIST.md` (troubleshooting section)
5. See: `docs/TROUBLESHOOTING_COMPLETE_REPORT.md` (known issues)

---

## 🔧 Common Issues & Fixes

### PostgreSQL Not Starting or Corrupted

If PostgreSQL fails to start or you see "role postgres does not exist":

```bash
# SSH to NXCore
ssh glyph@192.168.7.209

# Stop and remove the container
sudo docker stop postgres
sudo docker rm postgres

# Wipe data directory
sudo rm -rf /srv/core/data/postgres/*

# Recreate with proper ownership (UID 999 = postgres user)
sudo mkdir -p /srv/core/data/postgres
sudo chown -R 999:999 /srv/core/data/postgres

# Redeploy (this will initialize fresh database)
sudo docker compose -f /srv/core/compose-postgres.yml up -d

# Wait for initialization
sleep 10

# Verify it's running
sudo docker ps | grep postgres

# Initialize databases and users (NOTE: use 'aerovista' not 'postgres')
sudo docker exec -i postgres psql -U aerovista -d aerovista < /srv/core/config/postgres/init-databases.sql

# Verify users created
sudo docker exec postgres psql -U aerovista -d aerovista -c "\du"

# Verify databases created
sudo docker exec postgres psql -U aerovista -d aerovista -c "\l"
```

**Important:** The PostgreSQL superuser is `aerovista` (not `postgres`). See `compose-postgres.yml` line 13.

### Authelia Redis Authentication Failed

If you see "WRONGPASS invalid username-password pair":

```bash
# The configuration.yml file needs the plain password, not environment variable syntax
# Edit the config file
sudo nano /opt/nexus/authelia/configuration.yml

# Find the redis section and ensure it has:
#   redis:
#     host: redis
#     port: 6379
#     password: ChangeMe_RedisPassword123    # <-- Plain text, no ${} or $
#     database_index: 0

# Save and restart
sudo docker restart authelia
```

### Landing Page Mount Error

If you see "not a directory: unknown" for nginx.conf:

```bash
# The file got created as a directory by mistake
sudo rm -rf /srv/core/config/landing/nginx.conf

# Copy the correct file from Windows
# (In PowerShell on Windows)
scp configs/landing/nginx.conf glyph@192.168.7.209:~/nginx.conf

# (Back on NXCore)
sudo cp ~/nginx.conf /srv/core/config/landing/nginx.conf

# Restart landing page
sudo docker restart landing
```

---

## 📞 Quick Commands

```bash
# SSH
ssh glyph@192.168.7.209

# Check containers
sudo docker ps

# Check logs
sudo docker logs <container> --tail 50

# Restart container
sudo docker restart <container>

# Check networks
sudo docker network ls

# Check volumes
sudo docker volume ls

# System info
sudo docker system df
```

---

## 📝 Changelog

### 2025-10-14 - Major Update (Phase A Complete ✅)

**Fixed & Improved:**

- ✅ Fixed `deploy-containers.ps1` logic errors (phase deployment was broken)
- ✅ Fixed PowerShell script emoji parsing errors (replaced with ASCII-safe text)
- ✅ Fixed bash `&&` operator errors in PowerShell (split into separate commands)
- ✅ Fixed Authelia Redis password (removed `${}` environment variable syntax from config.yml)
- ✅ Fixed Authelia PostgreSQL password (removed `${}` environment variable syntax from config.yml)
- ✅ Fixed Authelia compose `depends_on` error (removed cross-file dependencies)
- ✅ Fixed PostgreSQL initialization (documented correct superuser: `aerovista`)
- ✅ Fixed PostgreSQL data directory permissions (must be `999:999`)
- ✅ Fixed PostgreSQL schema permissions for PostgreSQL 15+ (added to init script)
- ✅ Fixed Landing Page healthcheck (changed from `wget` to `curl` for Alpine)
- ✅ Fixed Landing Page nginx.conf mount error (ensure file exists before container starts)
- ✅ Added SSH key authentication setup (passwordless SSH)
- ✅ Added passwordless sudo configuration (`/etc/sudoers.d/glyph-docker`)
- ✅ Added phase-based deployment (`-Service foundation`, `-Service observability`, `-Service ai`)
- ✅ Updated all documentation to match working deployment flow
- ✅ Added comprehensive wipe instructions with pre-flight checks
- ✅ Simplified deployment from ~15 individual commands to 5 phase commands
- ✅ Documented cert minting process
- ✅ Added verification steps for each phase
- ✅ Added troubleshooting section for common issues
- ✅ Created `DEPLOYMENT_LESSONS_LEARNED.md` - comprehensive guide of all fixes

**Phase A Results:**

- PostgreSQL: ✅ Healthy
- Redis: ✅ Healthy
- Authelia: ✅ Healthy
- Landing Page: ✅ Healthy

**Time Savings:**

- Before: ~120 min (manual, error-prone)
- After with all fixes: ~30 min (automated, reliable)
- First deployment (with debugging): ~4 hours

**See Also:** `docs/DEPLOYMENT_LESSONS_LEARNED.md` for detailed troubleshooting and lessons

---

**Good luck! 🚀**

# Hmmm… can't reach this page

 **traefik.nxcore.tail79107c.ts.net** ’s server IP address could not be found.

Try:

* Checking the connection
* Checking the proxy, firewall, and DNS settings

ERR_NAME_NOT_RESOLVED
