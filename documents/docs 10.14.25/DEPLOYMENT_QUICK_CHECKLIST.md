# ✅ Deployment Quick Checklist

**Print this for your next deployment!**

---

## 🔧 Pre-Flight (One-Time Setup)

- [ ] **SSH Keys Generated** (`ssh-keygen -t ed25519 -C "glyph@nxcore"`)
- [ ] **Public key copied to NXCore** (`~/.ssh/authorized_keys`)
- [ ] **Passwordless sudo configured** (`/etc/sudoers.d/glyph-docker`)
- [ ] **Tailscale certificates minted** (`/var/lib/tailscale/certs/`)

---

## 📋 Wipe Steps (On NXCore)

**Connect via Tailscale IP:** `ssh glyph@100.115.9.61`

```bash
# 1. Stop and remove all containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true

# 2. Remove networks
sudo docker network rm gateway backend observability 2>/dev/null || true

# 3. Prune system
sudo docker system prune -af

# 4. Clean data directories (optional - DELETES ALL DATA!)
sudo rm -rf /srv/core/data/*
sudo rm -rf /opt/nexus/*

# 5. Recreate directory structure
sudo mkdir -p /srv/core/{data,config,landing} /opt/nexus
sudo chown -R glyph:glyph /srv/core /opt/nexus
```

---

## 🚀 Deployment Phases (On Windows PowerShell)

### Phase 1: Traefik (5 min)

```powershell
cd D:\NeXuS\NXCore-Control
.\scripts\ps\deploy-containers.ps1 -Service traefik
```

**Verify:** Check `https://nxcore.tail79107c.ts.net/dashboard/`

---

### Phase 2: Foundation (15 min)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service foundation
```

**Services:** docker-socket-proxy, postgres, redis, authelia, landing

**Verify on NXCore:**
```bash
ssh glyph@100.115.9.61
sudo docker ps --format 'table {{.Names}}\t{{.Status}}'
```

**Expected:**
- postgres: healthy
- redis: healthy
- authelia: healthy
- landing: healthy

---

### Phase 3: Observability (15 min)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service observability
```

**Services:** prometheus, grafana, uptime-kuma, dozzle, cadvisor

**Verify URLs (Note: SSL issues with subdomains - use IP addresses):**
- http://100.115.9.61:3000/ (Grafana)
- http://100.115.9.61:9090/ (Prometheus)
- http://100.115.9.61:3001/ (Uptime Kuma)
- http://100.115.9.61:8080/ (Dozzle)

---

### Phase 4: AI (15 min + model download)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service ai
```

**Services:** ollama, openwebui

**Verify:** http://100.115.9.61:11434/ (Ollama) or http://100.115.9.61:3000/ (OpenWebUI)

---

### Phase 5: SSL Certificate Generation (Required for Workspaces)

```bash
# SSH to NXCore
ssh glyph@100.115.9.61

# Generate self-signed wildcard certificate
sudo mkdir -p /opt/nexus/traefik/certs
cd /opt/nexus/traefik/certs

sudo openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"

# Set proper permissions
sudo chown root:root self-signed.*
sudo chmod 600 self-signed.key
sudo chmod 644 self-signed.crt

# Restart Traefik
sudo docker restart traefik
```

### Phase 6: Workspaces (5-7 hours)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service workspaces
```

**Services:** vnc-server, novnc, guacamole, code-server, jupyter, rstudio

### Phase 7: Apps (Individual)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service n8n
.\scripts\ps\deploy-containers.ps1 -Service filebrowser
.\scripts\ps\deploy-containers.ps1 -Service portainer
.\scripts\ps\deploy-containers.ps1 -Service aerocaller
```

---

## ⚠️ Common Issues Quick Fix

### Issue: Container unhealthy/restarting

```bash
# Check logs
sudo docker logs <container> --tail 50

# Common fixes:
# 1. Check file permissions
ls -la /srv/core/data/<service>
sudo chown -R 999:999 /srv/core/data/postgres  # For PostgreSQL

# 2. Verify config files are FILES not directories
file /srv/core/config/<service>/<config-file>

# 3. Restart container
sudo docker restart <container>
```

### Issue: PostgreSQL permission denied

```bash
# Grant schema permissions
sudo docker exec postgres psql -U aerovista -d <database> -c "GRANT ALL ON SCHEMA public TO <user>;"
```

### Issue: SSL Certificate Problems (Subdomains 404)

```bash
# Check certificate scope
openssl x509 -in /opt/nexus/traefik/certs/fullchain.pem -text -noout | grep -A 5 'Subject Alternative Name'

# Generate self-signed wildcard certificate for subdomains
sudo mkdir -p /opt/nexus/traefik/certs
cd /opt/nexus/traefik/certs

sudo openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"

# Set proper permissions
sudo chown root:root self-signed.*
sudo chmod 600 self-signed.key
sudo chmod 644 self-signed.crt

# Restart Traefik
sudo docker restart traefik
```

### Issue: Authelia can't connect

**Check config files have plain text passwords (NO `${}`):**
```bash
sudo nano /opt/nexus/authelia/configuration.yml
# Verify Redis password is plain text: ChangeMe_RedisPassword123
# Verify PostgreSQL password is plain text: CHANGE_ME_authelia_password
```

---

## 📊 Success Criteria

### Phase A: Foundation
- [ ] PostgreSQL: healthy
- [ ] Redis: healthy
- [ ] Authelia: healthy
- [ ] Landing: healthy

### Phase E: Observability
- [ ] Prometheus: healthy
- [ ] Grafana: accessible
- [ ] Uptime Kuma: accessible
- [ ] Dozzle: accessible
- [ ] cAdvisor: healthy

### Phase C: AI
- [ ] Ollama: running
- [ ] Open WebUI: accessible

### Phase B: Apps
- [ ] n8n: accessible
- [ ] FileBrowser: accessible
- [ ] Portainer: accessible (create admin within 5 min!)
- [ ] AeroCaller: accessible

---

## 🎯 Target Times

- **Wipe:** 5 min
- **Traefik:** 5 min
- **Foundation:** 15 min
- **Observability:** 15 min
- **AI:** 15 min + model download (~10 min)
- **Apps:** 10 min

**Total:** ~65 minutes (plus model downloads)

---

## 📞 Emergency Commands

```bash
# View all containers
sudo docker ps -a

# Stop everything
sudo docker stop $(sudo docker ps -aq)

# Check Docker networks
sudo docker network ls

# Check disk space
df -h /
sudo docker system df

# Restart Docker daemon
sudo systemctl restart docker

# Check Traefik logs
sudo docker logs traefik --tail 100 -f

# Force recreate container
sudo docker stop <container> && sudo docker rm <container>
sudo docker compose -f /srv/core/compose-<service>.yml up -d
```

---

**For detailed troubleshooting, see:** `docs/DEPLOYMENT_LESSONS_LEARNED.md`

**Good luck! 🚀**

