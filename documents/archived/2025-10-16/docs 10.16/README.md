# NXCore-Control (Windows Operator Pack)

This pack lets you manage **NXCore** (192.168.7.209/22) from a Windows workstation using
built-in OpenSSH + PowerShell, with optional automation via **Cursor** (.cursorrules).

---

## 🗺️ **NEW: Complete Project Map & Clean Install**

**Lost? Start here:**

🗺️ **[PROJECT_MAP.md](PROJECT_MAP.md)** ← **Complete navigation guide** (start here!)

✅ **[docs/DEPLOYMENT_CHECKLIST.md](docs/DEPLOYMENT_CHECKLIST.md)** ← **NEW! Step-by-step deployment** (~70 min)

📖 **[docs/CLEAN_INSTALL_GUIDE.md](docs/CLEAN_INSTALL_GUIDE.md)** ← Original clean install guide

🔧 **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** ← Command cheat sheet

📋 **[docs/AEROVISTA_COMPLETE_STACK.md](docs/AEROVISTA_COMPLETE_STACK.md)** ← All 41 services mapped

🏗️ **[docs/MULTI_NODE_ARCHITECTURE.md](docs/MULTI_NODE_ARCHITECTURE.md)** ← Multi-server deployment

### Quick Links (after deployment):
- **🎉 Landing Dashboard:** https://nxcore.tail79107c.ts.net/ ← **Start here!** [Upgrade Summary →](docs/DASHBOARD_UPGRADE_SUMMARY.md)
- **Traefik:** https://nxcore.tail79107c.ts.net/traefik/
- **Auth (SSO):** https://nxcore.tail79107c.ts.net/auth/
- **🤖 AI Assistant:** https://ai.nxcore.tail79107c.ts.net/ ← **NEW! Phase C**
- **Status:** https://nxcore.tail79107c.ts.net/status/
- **Logs:** https://nxcore.tail79107c.ts.net/logs/
- **Metrics:** https://nxcore.tail79107c.ts.net/prometheus/
- **Dashboards:** https://nxcore.tail79107c.ts.net/grafana/
- **n8n:** https://nxcore.tail79107c.ts.net/n8n/
- **Files:** https://nxcore.tail79107c.ts.net/files/
- **Portainer:** https://nxcore.tail79107c.ts.net/portainer/
- **AeroCaller:** https://nxcore.tail79107c.ts.net/aerocaller/

*Replace `tail79107c` with your Tailscale tailnet ID*

**📊 Latest Updates:**
- ✅ **Phase A-C Complete** - 23 containers running
- ✅ **AI Enabled** - Ollama + Open WebUI (llama3.2)
- ✅ **Live Dashboard** - Real-time service status
- ✅ **8 HTTPS Routes** - All secured with self-signed certs

---

## 🔐 **Self-Signed Certificates (HTTPS)** ✅ CONFIGURED

All services are secured with self-signed certificates (valid until Oct 16, 2026).

### **📋 Quick Reference:**
- **Setup Complete:** [SETUP_COMPLETE.md](SETUP_COMPLETE.md) ← **Start here!**
- **Quick Access:** [QUICK_ACCESS.md](QUICK_ACCESS.md) ← Bookmark this!
- **Service Guide:** [docs/SERVICE_ACCESS_GUIDE.md](docs/SERVICE_ACCESS_GUIDE.md)
- **Full Cert Guide:** [docs/SELFSIGNED_CERTIFICATES.md](docs/SELFSIGNED_CERTIFICATES.md)

### **🚀 One-Time Setup:**

```powershell
# 1. Import certificate (opens file)
Start-Process ".\certs\selfsigned\fullchain.pem"

# 2. Then: Install → Local Machine → Trusted Root CA → Finish
# 3. Restart browser
# 4. Access: https://nxcore.tail79107c.ts.net/
```

### **💻 Quick Access (Works Now!):**
- Code-Server: http://100.115.9.61:8080/ (Password: `ChangeMe_CodeServerPassword123`)
- Jupyter: http://100.115.9.61:8888/
- Dashboard: http://100.115.9.61:8081/

---

## Quick Start

1. Unzip anywhere (e.g., `C:\NXCore-Control`).
1. Open **PowerShell** as admin and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\scripts\ps\sync-config.ps1
```

1. SSH in fast:

```bat
scripts\\ssh-nxcore.bat
```

## Layout

- `.cursorrules` → Cursor agent instructions & tool-usage policy.
- `scripts\\` → Handy `ssh` / `scp` wrappers. PowerShell deploy/sync jobs in `scripts\\ps`.
- `docker\\` → Example docker-compose files for core services (n8n, FileBrowser, AeroCaller).
- `agent\\` → Agent rules + systemd unit for a simple file-watcher "cursor-agent".
- `ai\\` → Local AI bootstrap (Ollama + lightweight API skeleton).
- `configs\\` → Example UFW and Tailscale ACL templates.
- `utils\\windows\\` → Optional setup helpers for your Windows box (OpenSSH, winget, path checks).
- `inventory\\hosts.ini` → Future-proofing for Ansible/WinRM/WSL.

## AeroCaller (PeerJS over Tailscale)

This repo now includes a deployable AeroCaller app with PeerJS signaling and optional TURN.

### Files added/updated

- `docker/compose-aerocaller.yml` → Node-terminated TLS (HTTPS on 4443), mounts `/opt/nexus/aerocaller`.
- `apps/AeroCaller/server.staff.js` → Binds `0.0.0.0`, supports `BASE_PATH`, mounts PeerJS at `/peerjs`.
- `apps/AeroCaller/app.staff.js` → Derives base path, loads optional `turn.json`, STUN by default.
- `scripts/ps/deploy-containers.ps1` → Added `-Service aerocaller` deployment.
- `cursor.json` → Added "Deploy AeroCaller" task.

### Prereqs (run on NXCore via SSH)

1. Create app + certs directories:

```bash
sudo mkdir -p /opt/nexus/aerocaller /opt/nexus/aerocaller/certs
```

1. Mint Tailscale TLS cert for Node (matches your tailnet name):

```bash
sudo tailscale cert \
  --cert-file=/opt/nexus/aerocaller/certs/fullchain.pem \
  --key-file=/opt/nexus/aerocaller/certs/privkey.pem \
  nxcore.tail79107c.ts.net
sudo chown -R glyph:glyph /opt/nexus/aerocaller/certs
```

### Deploy (from Windows PowerShell)

```powershell
scripts\\ps\\deploy-containers.ps1 -Service aerocaller
```

This syncs app files to `/opt/nexus/aerocaller`, pushes compose to `/srv/core/compose-aerocaller.yml`, and starts the service.

### Map Tailscale Serve (HTTPS on 4443)

Run on NXCore (SSH):

```bash
sudo tailscale serve reset
sudo tailscale serve --bg --https=4443 https://localhost:4443
tailscale serve status
```

If your cert/SNI doesn’t match and you see 404/502 from Serve, use:

```bash
sudo tailscale serve reset
sudo tailscale serve --bg --https=4443 https+insecure://127.0.0.1:4443
```

### Open the app

- HTTPS (recommended): `https://nxcore.tail79107c.ts.net:4443/index.staff.html`

### Troubleshooting WS (WebSocket) and caching

- Hard refresh service worker in the browser DevTools console:

```js
navigator.serviceWorker.getRegistrations().then(rs => rs.forEach(r => r.unregister()))
```

- Backend health (on NXCore):

```bash
curl -skI https://127.0.0.1:4443/api/readyz
curl -skI https://127.0.0.1:4443/index.staff.html
```

- If WS fails on Serve, reset mapping and re-apply as above. Ensure `BASE_PATH=/` and logs show:
  - `listening on https://0.0.0.0:4443`
  - `base paths: '/'`

### TURN (optional, only if calls can’t connect)

`utils/coturn/` contains a tailnet-only TURN pack.

Quick docker install (on NXCore):

```bash
cd /opt/nexus
sudo mkdir -p coturn && cd coturn
sudo tee .env >/dev/null <<'EOF'
REALM=nxcore.tail
TURN_USER=auser
TURN_PASS=apass
UDP_MIN_PORT=49160
UDP_MAX_PORT=49200
USE_TLS=0
TLS_CERT_PATH=
TLS_KEY_PATH=
STATIC_AUTH_SECRET=
EOF
sudo tee docker-compose.yml >/dev/null <<'YML'
version: "3.9"
services:
  coturn:
    image: coturn/coturn:latest
    container_name: coturn
    network_mode: host
    restart: unless-stopped
    environment:
      - REALM=${REALM}
      - TURN_USER=${TURN_USER}
      - TURN_PASS=${TURN_PASS}
      - UDP_MIN_PORT=${UDP_MIN_PORT}
      - UDP_MAX_PORT=${UDP_MAX_PORT}
      - USE_TLS=${USE_TLS}
      - TLS_CERT_PATH=${TLS_CERT_PATH}
      - TLS_KEY_PATH=${TLS_KEY_PATH}
      - STATIC_AUTH_SECRET=${STATIC_AUTH_SECRET}
    command: >
      bash -lc '
      set -euo pipefail;
      if [ "${USE_TLS}" = "1" ]; then
        TLS_OPTS="--tls-listening-port=5349 --cert=${TLS_CERT_PATH} --pkey=${TLS_KEY_PATH}";
      else
        TLS_OPTS="--no-tls --no-dtls";
      fi;
      exec turnserver
        --log-file=stdout
        --simple-log
        --fingerprint
        --realm=${REALM}
        --listening-port=3478
        --min-port=${UDP_MIN_PORT}
        --max-port=${UDP_MAX_PORT}
        --lt-cred-mech
        --user ${TURN_USER}:${TURN_PASS}
        $TLS_OPTS
      '
YML
sudo docker compose up -d
```

Client config file for AeroCaller (served automatically if present):

```bash
sudo tee /opt/nexus/aerocaller/turn.json >/dev/null <<'JSON'
{
  "iceServers": [
    { "urls": "stun:nxcore:3478" },
    { "urls": "turn:nxcore:3478?transport=udp", "username": "auser", "credential": "apass" },
    { "urls": "turn:nxcore:3478?transport=tcp", "username": "auser", "credential": "apass" }
  ]
}
JSON
sudo docker compose -f /srv/core/compose-aerocaller.yml restart aerocaller
```

To verify TURN usage, open `chrome://webrtc-internals` and look for `typ relay` in the selected candidate pair.

> Host: **nxcore**  |  IPv4: **192.168.7.209**  |  CIDR: **/22**

---

**AeroVista LLC** • Command node: **NXCore**
