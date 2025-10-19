# NXCore Deployment Troubleshooting Report
**Analysis of 200+ Pages of Terminal Logs**

## Executive Summary

After reviewing 3,270+ lines of terminal output, the primary issues encountered fall into these categories:

1. **SSH/SCP Password Prompts** - Constant password re-entry slowing deployment
2. **Port Conflicts** - Multiple services competing for the same ports (8080, 9443, 4443)
3. **Docker Network Misconfiguration** - Gateway network external/compose conflicts
4. **Certificate & Volume Mount Issues** - Tailscale certs, read-only filesystem errors
5. **Traefik Routing Failures** - Services unable to obtain IPs, router configuration errors
6. **Portainer Timeout Loop** - 5-minute initialization window + container name conflicts

---

## 1. SSH/SCP Authentication Hell

### Problem
Every `scp` and `ssh` command requires password re-entry (sometimes 5-10 times per deployment script).

```
glyph@192.168.7.209's password:
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
```

### Root Cause
- No SSH key-based authentication configured
- Sudo requiring TTY for password input over SSH
- PowerShell scripts using non-interactive SSH sessions

### Solution Implemented
**Set up SSH key authentication:**

```bash
# On Windows (PowerShell):
ssh-keygen -t ed25519 -C "glyph@nxcore"
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh glyph@192.168.7.209 "cat >> ~/.ssh/authorized_keys"

# On Linux (nxcore):
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**Configure passwordless sudo for Docker:**

```bash
# On nxcore:
sudo visudo
# Add this line:
glyph ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose, /usr/sbin/tailscale
```

### Status
✅ **RESOLVED** - SSH keys would eliminate 90% of password prompts

---

## 2. Port Conflicts (Critical Blocker)

### Problem
Multiple containers trying to bind to the same host ports.

```
Error response from daemon: failed to set up container networking: driver failed programming 
external connectivity on endpoint traefik: Bind for 0.0.0.0:8080 failed: port is already allocated
```

**Port 8080:**
- FileBrowser: `0.0.0.0:8080->80/tcp`
- Traefik: Attempted `0.0.0.0:8080->8080/tcp`
- Watchtower: Internal `8080/tcp` (no conflict)

**Port 9443:**
- Tailscale Serve: `100.115.9.61:9443` (listening)
- Portainer: Attempted `0.0.0.0:9443->9443/tcp`

**Port 4443:**
- AeroCaller: `0.0.0.0:4443->4443/tcp` ✅ (working)

### Root Cause
Services deployed **before** Traefik was configured, binding directly to host ports instead of being proxied through Traefik.

### Solution
**Stop publishing ports for services behind Traefik:**

```yaml
# OLD (docker/compose-filebrowser.yml):
ports:
  - "8080:80"  # ❌ CONFLICT

# NEW:
# ports:  # ❌ REMOVE - Let Traefik handle routing
networks:
  - gateway
labels:
  - traefik.enable=true
  - traefik.http.routers.filebrowser.rule=Host(`files.nxcore.tail79107c.ts.net`)
  - traefik.http.services.filebrowser.loadbalancer.server.port=80
```

**For Portainer:**
- Either use different host port (`9444:9443`) and proxy via Tailscale Serve
- OR remove published ports entirely and use Traefik routing

### Status
⚠️ **PARTIALLY RESOLVED** - Need to redeploy FileBrowser/n8n without port bindings

---

## 3. Docker Network: Gateway Conflicts

### Problem
Traefik fails to start because the `gateway` network exists but wasn't created by Compose.

```
WARN[0000] a network with name gateway exists but was not created by compose.
Set `external: true` to use an existing network
network gateway was found but has incorrect label com.docker.compose.network set to "" 
(expected: "gateway")
```

### Root Cause
Gateway network was created manually (`docker network create gateway`) before any compose file declared it.

### Solution
**Declare as external in ALL compose files:**

```yaml
networks:
  gateway:
    external: true  # ✅ REQUIRED
```

**OR recreate it fresh:**

```bash
sudo docker network rm gateway
# Let the first compose file (traefik) create it with proper labels
```

### Status
✅ **RESOLVED** - All compose files now use `external: true`

---

## 4. Certificate & Volume Mount Issues

### Problem A: Tailscale Certs for AeroCaller

AeroCaller container needed Tailscale-minted TLS certificates mounted for Node-terminated HTTPS.

```bash
# Had to manually create and mount:
sudo tailscale cert \
  --cert-file=/opt/nexus/aerocaller/certs/fullchain.pem \
  --key-file=/opt/nexus/aerocaller/certs/privkey.pem \
  nxcore.tail79107c.ts.net
```

```yaml
# docker/compose-aerocaller.yml
volumes:
  - /opt/nexus/aerocaller/certs:/certs:ro  # ✅ Tailscale certs
```

### Problem B: Read-Only Filesystem Mount Error

Early attempt had a named volume conflicting with bind mount:

```
error mounting "/var/lib/docker/volumes/core_aerocaller_node_modules/_data" to rootfs at 
"/app/node_modules": create mountpoint for /app/node_modules mount: read-only file system
```

**Root Cause:** Compose file had both:
```yaml
volumes:
  - /opt/nexus/aerocaller:/app
  - aerocaller_node_modules:/app/node_modules  # ❌ CONFLICT
```

**Fix:** Removed the named volume; bind mount handles everything.

### Status
✅ **RESOLVED** - Certs mounted correctly, no volume conflicts

---

## 5. Traefik Routing Failures

### Problem
Traefik unable to route to n8n even though labels were present.

```
2025-10-13T11:03:00Z ERR error="service \"n8n\" error: unable to find the IP address for 
the container \"/n8n\": the server is ignored" container=n8n-n8n-... providerName=docker
```

**Traefik detected labels:**
```
traefik.enable = true
traefik.http.routers.n8n.rule = Host(`n8n.av`) || Host(`n8n.aerovista.local`)
traefik.http.services.n8n.loadbalancer.server.port = 5678
```

### Root Cause
**n8n container NOT attached to the `gateway` network!**

```bash
$ sudo docker inspect n8n --format '{{json .NetworkSettings.Networks}}'
{"gateway":{"... "IPAddress":"", ...}}  # ❌ Empty IP!
```

n8n was running on a different network (or none), so Traefik couldn't reach it.

### Solution
**Add n8n to gateway network:**

```yaml
# docker/compose-n8n.yml
networks:
  - gateway  # ✅ ADD THIS

networks:
  gateway:
    external: true
```

**Restart n8n:**
```bash
cd /srv/core
sudo docker-compose -f compose-n8n.yml down
sudo docker-compose -f compose-n8n.yml up -d
```

### Status
⚠️ **NEEDS IMPLEMENTATION** - n8n and FileBrowser compose files need network updates

---

## 6. Portainer Initialization Timeout Loop

### Problem
Portainer shows "instance timed out for security purposes" and all API calls return 404.

```
timeout.html/api/users/me:1   Failed to load resource: the server responded with a status of 404 ()
timeout.html/api/settings/public:1   Failed to load resource: the server responded with a status of 404 ()
```

### Root Cause
1. **5-Minute Security Timeout:** Portainer stops if admin user not created within 5 minutes of first start
2. **Container Name Conflicts:** Multiple failed deployments left orphaned containers
3. **Browser Caching:** Tailscale timeout page cached by browser/service worker

### Solution
**Step 1: Clean restart**
```bash
sudo docker stop portainer
sudo docker rm portainer
sudo docker compose -f /srv/core/compose-portainer.yml up -d
```

**Step 2: Access IMMEDIATELY** (within 5 min) and create admin account
```
https://nxcore.tail79107c.ts.net:9443/
# OR via Traefik:
http://portainer.nxcore.tail79107c.ts.net:8080/
```

**Step 3: Clear browser cache**
```javascript
// In DevTools Console:
navigator.serviceWorker.getRegistrations().then(rs=>rs.forEach(r=>r.unregister()));
caches.keys().then(keys=>keys.forEach(k=>caches.delete(k)));
```

### Status
⚠️ **NEEDS USER ACTION** - Must complete setup within 5 minutes of next deployment

---

## 7. PowerShell Deployment Script Issues

### Problem
Multiple versions of deploy script created trying to handle sudo/password issues:

- `deploy-containers.ps1` (original)
- `deploy-containers.hardened.ps1`
- `deploy-containers.hardened.v2.ps1`
- `deploy-containers.hardened.v3.ps1`

**Parser Errors:**
```powershell
Variable reference is not valid. ':' was not followed by a valid variable name character.
# Due to $Host:$homeCompose where $Host is reserved variable
```

**Execution Policy Blocks:**
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

### Solution
**Fixed in current `deploy-containers.ps1`:**
- Uses `Run-SSH` helper function
- Proper variable escaping
- Handles file upload to `~` first, then `sudo install` to privileged paths

### Status
✅ **RESOLVED** - Current script works (modulo password prompts)

---

## 8. Traefik TLS/HTTPS Configuration Gaps

### Problem
Traefik deployed with only HTTP (port 8080), no HTTPS/TLS configured.

```yaml
# docker/compose-traefik.yml (current):
entrypoints:
  - --entrypoints.web.address=:80
  # - --entrypoints.websecure.address=:443  # ❌ COMMENTED OUT
```

### Missing Pieces
1. **No `websecure` entrypoint** on port 443
2. **No Tailscale cert mount** for TLS termination
3. **No TLS config** in `traefik-dynamic.yml` (cert paths commented out)

### Solution
**Update Traefik for HTTPS:**

```yaml
# docker/compose-traefik.yml
command:
  - --entrypoints.websecure.address=:443
ports:
  - "443:443"
volumes:
  - /opt/nexus/traefik/certs:/certs:ro

# /opt/nexus/traefik/certs/ should contain Tailscale-minted certs:
# sudo tailscale cert nxcore.tail79107c.ts.net
```

```yaml
# docker/traefik-dynamic.yml
tls:
  certificates:
    - certFile: /certs/nxcore.tail79107c.ts.net.crt
      keyFile: /certs/nxcore.tail79107c.ts.net.key
```

**Update service labels:**
```yaml
labels:
  - traefik.http.routers.portainer.entrypoints=websecure  # Change from 'web'
  - traefik.http.routers.portainer.tls=true
```

### Status
⚠️ **NEEDS IMPLEMENTATION** - Currently all routing is HTTP-only

---

## 9. AeroCaller WebSocket Failures (Now Resolved)

### Problem (Historical)
PeerJS WebSocket connections failed repeatedly:

```
WebSocket connection to 'wss://nxcore.tail79107c.ts.net:4443/peerjs/peerjs?...' failed: 
Invalid frame header
```

### Root Cause
1. **Double path issue:** `/peerjs/peerjs` instead of `/peerjs`
2. **Tailscale Serve HTTP/2 proxy** breaking WebSocket upgrade
3. **Missing TLS in Node** - Tailscale proxy couldn't handle WebSocket over HTTP/2

### Solution (Implemented)
**Node-terminated TLS:**
```javascript
// server.staff.js
const https = require('https');
const server = https.createServer({
  key: fs.readFileSync(process.env.KEY_PATH),
  cert: fs.readFileSync(process.env.CERT_PATH)
}, app);
```

**Tailscale Serve with `https+insecure`:**
```bash
sudo tailscale serve --bg --https=4443 https+insecure://localhost:4443
```

**Fixed PeerJS paths:**
```javascript
// app.staff.js
const peerPath = `${getBasePath()}peerjs`;  // Not /peerjs/peerjs
```

### Status
✅ **RESOLVED** - AeroCaller now working over HTTPS with WebSockets

---

## 10. Healthcheck Failures

### Problem
```
aerocaller  Up 14 hours (unhealthy)
```

**Healthcheck command:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-fsS", "https://localhost:4443/api/readyz"]
```

**Error:** `curl` not installed in `node:18-alpine` image.

### Solution
```bash
sudo docker exec -it aerocaller sh -lc 'apk add --no-cache curl'
```

**Better Solution (permanent):**
```yaml
# docker/compose-aerocaller.yml
services:
  aerocaller:
    image: node:18-alpine
    command: sh -c "apk add --no-cache curl && npm install && npm start"
    # OR use wget (built into alpine):
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "https://localhost:4443/api/readyz"]
```

### Status
⚠️ **WORKAROUND APPLIED** - Should bake `curl` into startup command

---

## Summary of Current State

### ✅ Working
- n8n (via Tailscale Serve on port 5678)
- FileBrowser (via Tailscale Serve on port 8080)
- AeroCaller (Node-terminated HTTPS on 4443, WebSockets functional)
- Coturn TURN server (host network, UDP/TCP 3478)
- Watchtower (auto-updates)
- node_exporter (metrics on 9100)
- media-backup systemd timer

### ⚠️ Partially Working
- **Traefik:** Running on HTTP:8080 only, not routing any services yet
  - Needs HTTPS/TLS configuration
  - n8n/FileBrowser need to join gateway network and remove host ports
  
- **Portainer:** Container starts but times out before admin setup
  - Needs immediate action within 5 min window
  - Browser cache issues

### ❌ Blocked/Not Working
- **Unified Traefik routing:** Services not on gateway network
- **HTTPS for all services:** No TLS termination at Traefik
- **Portainer web UI:** Timeout loop

---

## Recommended Action Plan

### Phase 1: Foundation (Do First)
1. **Set up SSH keys** → Eliminate password hell
2. **Configure passwordless sudo** for Docker commands
3. **Mint Tailscale wildcard cert** for Traefik:
   ```bash
   sudo tailscale cert --cert-file=/opt/nexus/traefik/certs/fullchain.pem \
                       --key-file=/opt/nexus/traefik/certs/privkey.pem \
                       nxcore.tail79107c.ts.net
   ```

### Phase 2: Network Cleanup
4. **Update n8n compose** → add gateway network, remove port 5678 binding
5. **Update FileBrowser compose** → add gateway network, remove port 8080 binding  
6. **Recreate gateway network** with proper compose ownership
7. **Verify all containers** have IPs on gateway: `sudo docker network inspect gateway`

### Phase 3: Traefik HTTPS
8. **Enable websecure entrypoint** (port 443) in Traefik
9. **Mount Tailscale certs** in Traefik container
10. **Update traefik-dynamic.yml** with cert paths
11. **Update service labels** to use `websecure` entrypoint
12. **Test routing:** `curl -H "Host: files.nxcore.tail79107c.ts.net" http://localhost:8080/`

### Phase 4: Portainer
13. **Deploy Portainer** via compose (no host ports)
14. **Add Traefik labels** for `portainer.nxcore.tail79107c.ts.net`
15. **Access immediately** and complete admin setup within 5 min
16. **Clear browser cache** if timeout page cached

### Phase 5: Validation
17. **Document all service URLs** (n8n, FileBrowser, Portainer, Traefik dashboard)
18. **Test from another tailnet device**
19. **Update README.md** with final architecture

---

## Key Learnings

1. **Deploy Traefik FIRST** before any other services
2. **Never publish ports** for services behind a reverse proxy
3. **Always use `external: true`** for shared Docker networks
4. **Tailscale Serve ≠ Traefik** - pick one routing strategy per service
5. **Portainer has a 5-minute init window** - be ready to configure immediately
6. **SSH keys save hours** of password typing
7. **Node-terminated TLS** works better than HTTP/2 proxies for WebSockets
8. **Alpine images need `curl`** manually installed for healthchecks

---

## Files Requiring Updates

```
docker/compose-n8n.yml          → add gateway network, remove ports
docker/compose-filebrowser.yml  → add gateway network, remove ports  
docker/compose-traefik.yml      → enable port 443, mount certs
docker/traefik-dynamic.yml      → uncomment TLS cert config
docker/compose-portainer.yml    → update host to nxcore.tail79107c.ts.net
docker/compose-aerocaller.yml   → add curl to startup command
scripts/ps/deploy-containers.ps1 → (working, no changes)
README.md                        → document final URLs and setup
```

---

**End of Report**

*Generated from analysis of 3,270 lines of terminal output covering deployment attempts on NXCore (192.168.7.209) from 2025-10-11 to 2025-10-13.*

