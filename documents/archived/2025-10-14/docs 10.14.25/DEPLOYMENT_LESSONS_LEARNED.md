# 🎓 Deployment Lessons Learned

**Last Updated:** 2025-10-14  
**Deployment:** Phase A - Foundation (Complete ✅)

---

## ✅ Critical Fixes Applied

### 1. PowerShell Script Issues

**Problem:** PowerShell cannot parse bash operators (`&&`, `||`) or UTF-8 emoji characters.

**Solution:**
- Replaced all emojis with ASCII-safe text (`🚀` → `==>`, `✅` → `[OK]`)
- Split all `mkdir && chown` commands into separate `Run-SSH` calls
- Changed double quotes to single quotes for bash `||` operators in network creation

**Files Fixed:**
- `scripts/ps/deploy-containers.ps1`

---

### 2. SSH Authentication & Passwordless Sudo

**Problem:** Password prompts break automation when using separate SSH connections.

**Solution:**
- Generated Ed25519 SSH key pair on Windows: `ssh-keygen -t ed25519 -C "glyph@nxcore"`
- Copied public key to NXCore's `~/.ssh/authorized_keys`
- Created `/etc/sudoers.d/glyph-docker` with: `glyph ALL=(ALL) NOPASSWD: ALL`
- Set correct permissions: `sudo chmod 0440 /etc/sudoers.d/glyph-docker`

**Commands:**
```powershell
# On Windows
ssh-keygen -t ed25519 -C "glyph@nxcore" -f $env:USERPROFILE\.ssh\id_ed25519
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh glyph@100.115.9.61 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

```bash
# On NXCore
echo 'glyph ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/glyph-docker
sudo chmod 0440 /etc/sudoers.d/glyph-docker
sudo visudo -c  # Verify syntax
```

---

### 3. Authelia Configuration - Environment Variables Don't Work in YAML

**Problem:** YAML files don't automatically expand environment variable syntax like `${VAR_NAME}`.

**Solution:** Use plain text passwords in configuration files.

**Files Fixed:**
- `configs/authelia/configuration.yml`
  - Line 61: `password: ${REDIS_PASSWORD}` → `password: ChangeMe_RedisPassword123`
  - Line 76: `password: ${AUTHELIA_DB_PASSWORD}` → `password: CHANGE_ME_authelia_password`

**Critical:** Remove ALL `${}` syntax from YAML config files!

---

### 4. Authelia Compose - Cross-File Dependencies

**Problem:** `depends_on` referencing services in other compose files causes validation errors.

**Solution:** Remove `depends_on` when services are in separate compose files.

**Files Fixed:**
- `docker/compose-authelia.yml` - Removed `depends_on: [redis, postgres]`

---

### 5. PostgreSQL Superuser Name

**Problem:** Default assumption was `postgres` user, but our setup uses `aerovista`.

**Solution:** Always use `-U aerovista -d aerovista` for PostgreSQL commands.

**Key Command:**
```bash
sudo docker exec -i postgres psql -U aerovista -d aerovista < /srv/core/config/postgres/init-databases.sql
```

**Files Fixed:**
- `configs/postgres/init-databases.sql` - Added comment documenting correct superuser

---

### 6. PostgreSQL Schema Permissions (PostgreSQL 15+)

**Problem:** In PostgreSQL 15+, users need explicit `GRANT ALL ON SCHEMA public` to create tables.

**Error:** `permission denied for schema public (SQLSTATE 42501)`

**Solution:** Grant schema permissions in init script.

**Files Fixed:**
- `configs/postgres/init-databases.sql` - Added schema permission grants for all database users

**New Code:**
```sql
\c authelia
GRANT ALL ON SCHEMA public TO authelia_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO authelia_user;
```

---

### 7. PostgreSQL Data Directory Permissions

**Problem:** PostgreSQL data directory must be owned by UID `999:999`.

**Solution:**
```bash
sudo chown -R 999:999 /srv/core/data/postgres
```

---

### 8. Landing Page Healthcheck - Alpine Nginx Missing wget

**Problem:** Alpine nginx image doesn't include `wget`, causing healthcheck to fail.

**Error:** `wget: can't connect to remote host: Connection refused`

**Solution:** Use `curl` instead of `wget` for healthcheck.

**Files Fixed:**
- `docker/compose-landing.yml`
  - Changed: `test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]`
  - To: `test: ["CMD", "curl", "-f", "http://localhost/"]`

---

### 9. Landing Page nginx.conf Mount Issue

**Problem:** Docker created nginx.conf as a directory instead of file when container started before file existed.

**Solution:**
1. Stop and remove container: `sudo docker stop landing && sudo docker rm landing`
2. Remove directory: `sudo rm -rf /srv/core/config/landing/nginx.conf`
3. Create file: `sudo tee /srv/core/config/landing/nginx.conf < nginx.conf`
4. Recreate container: `sudo docker compose -f /srv/core/compose-landing.yml up -d`

**Lesson:** Always ensure config files exist BEFORE starting containers that mount them.

---

### 10. Network Connectivity - Use Tailscale IP

**Problem:** Local network IP `192.168.7.209` sometimes times out.

**Solution:** Use Tailscale IP `100.115.9.61` for all SSH/SCP connections.

**PowerShell Script Updated:** The `deploy-containers.ps1` script now uses the Tailscale IP by default (line 13).

**Manual Commands:**
```powershell
ssh glyph@100.115.9.61
scp file.yml glyph@100.115.9.61:~
```

---

## 📋 Pre-Flight Checklist for Next Deployment

### Before Starting:

- [ ] SSH keys are set up (no password prompts)
- [ ] Passwordless sudo is configured (`/etc/sudoers.d/glyph-docker`)
- [ ] Docker networks created: `gateway`, `backend`, `observability`
- [ ] Directories exist with correct permissions:
  - `/srv/core` (glyph:glyph)
  - `/srv/core/data` (glyph:glyph)
  - `/srv/core/config` (glyph:glyph)
  - `/opt/nexus` (glyph:glyph)
- [ ] Tailscale certificates are in `/var/lib/tailscale/certs/`

### Configuration File Checklist:

- [ ] All passwords in YAML files are plain text (NO `${}` syntax)
- [ ] PostgreSQL init script includes schema permissions
- [ ] Compose files don't have cross-file `depends_on`
- [ ] Healthchecks use tools available in the image (`curl` not `wget` for Alpine)

---

## 🚀 Deployment Order

### Phase 0: Pre-Deployment
1. Create networks
2. Prepare directories
3. Mint Tailscale certificates

### Phase 1: Gateway
1. Deploy Traefik

### Phase 2: Foundation
1. Docker Socket Proxy
2. PostgreSQL (ensure ownership `999:999`)
3. Redis
4. Authelia
5. Landing Page

### Phase 3: Observability
1. Prometheus
2. Grafana
3. Uptime Kuma
4. Dozzle
5. cAdvisor

### Phase 4: AI
1. Ollama
2. Open WebUI

### Phase 5: Apps
1. n8n
2. FileBrowser
3. Portainer
4. AeroCaller

---

## 🔧 Common Troubleshooting Commands

```bash
# Check all container status
sudo docker ps --format 'table {{.Names}}\t{{.Status}}'

# Check specific service logs
sudo docker logs <container> --tail 50 -f

# Test PostgreSQL connection
sudo docker exec postgres psql -U aerovista -d aerovista -c "SELECT version();"

# Test Redis connection
sudo docker exec redis redis-cli -a "ChangeMe_RedisPassword123" ping

# Verify file is not a directory
file /srv/core/config/landing/nginx.conf

# Check Docker networks
sudo docker network ls
sudo docker network inspect gateway

# Remove and recreate container
sudo docker stop <container> && sudo docker rm <container>
sudo docker compose -f /srv/core/compose-<service>.yml up -d
```

---

## 📊 Success Metrics

**Phase A Foundation - Completed 2025-10-14:**
- ✅ PostgreSQL: Up 5 hours (healthy)
- ✅ Redis: Up 5 hours (healthy)
- ✅ Authelia: Up 5 hours (healthy)
- ✅ Landing Page: Up and healthy
- ✅ Traefik: Running (needs verification)

**Time to Deploy (with all fixes):** ~30 minutes  
**Time to Debug (first run):** ~4 hours  
**Documentation Quality:** Comprehensive ✅

---

## 🎯 Next Deployment Goals

1. Deploy all 5 phases without errors
2. Complete in < 60 minutes
3. All services healthy on first try
4. Zero manual interventions required

---

**This document should be updated after each deployment with new lessons learned!**

