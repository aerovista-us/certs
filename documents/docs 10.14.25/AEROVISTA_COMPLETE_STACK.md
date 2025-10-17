# AeroVista Complete Stack - Full Infrastructure Map

**Goal:** One-stop "work from any browser" server bundle for AeroVista  
**Vision:** Private, secure website where team can access desktop, dev tools, AI, and all apps from any browser

---

## Service Inventory (Complete Map)

### Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Tailscale Network                         │
│              (100.x.x.x - Private Mesh VPN)                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                 Traefik v3.1 (Reverse Proxy)                 │
│            :80 (redirect) → :443 (HTTPS/TLS)                 │
│         *.nxcore.tail79107c.ts.net (Tailscale certs)         │
└───────────┬────────┬────────┬────────┬────────┬─────────────┘
            │        │        │        │        │
    ┌───────┴───┐    │        │        │        │
    │ Authelia  │←───┴────────┴────────┴────────┘
    │ (SSO/MFA) │    (protects public/sensitive apps)
    └───────────┘
```

**Docker Networks:**
- `traefik_proxy` - Public-facing services (Traefik + proxied apps)
- `backend` - Databases, Redis, internal services
- `jobs` - n8n, automation workers
- `media` - Navidrome, Jellyfin, CopyParty
- `observability` - Prometheus, Grafana, Loki
- `remote` - MeshCentral, RustDesk, AeroCaller

---

## Service Map with Exact Specs

### 🏗️ **FOUNDATION LAYER**

#### 1. Traefik (Reverse Proxy & Gateway)
- **Image:** `traefik:3.1`
- **Container:** `traefik`
- **Network:** `traefik_proxy` (creates it)
- **Ports:** `80:80`, `443:443`
- **URL:** https://traefik.nxcore.tail79107c.ts.net/dashboard/
- **Config:** `/opt/nexus/traefik/traefik.yml`, `/opt/nexus/traefik/dynamic/`
- **Certs:** `/opt/nexus/traefik/certs/` (Tailscale-minted)
- **Status:** ✅ Deployed

#### 2. Docker Socket Proxy (Security)
- **Image:** `tecnativa/docker-socket-proxy:latest`
- **Container:** `docker-socket-proxy`
- **Network:** `backend` (isolated)
- **Internal Port:** `2375`
- **Env:**
  - `CONTAINERS=1`
  - `NETWORKS=1`
  - `SERVICES=1`
  - `TASKS=1`
  - `POST=0` (read-only by default)
- **Purpose:** Safer Docker socket access for Traefik/Portainer
- **Status:** 🔄 Need to deploy

#### 3. PostgreSQL 16 (Primary Database)
- **Image:** `postgres:16-alpine`
- **Container:** `postgres`
- **Network:** `backend`
- **Internal Port:** `5432`
- **Volume:** `/srv/core/data/postgres:/var/lib/postgresql/data`
- **Env:**
  - `POSTGRES_USER=aerovista`
  - `POSTGRES_PASSWORD=<from secrets>`
  - `POSTGRES_DB=aerovista`
- **Init DBs:** authelia, n8n, formbricks, keycloak (create via init script)
- **Status:** 🔄 Need to deploy

#### 4. Redis (Cache & Queues)
- **Image:** `redis:7-alpine`
- **Container:** `redis`
- **Network:** `backend`
- **Internal Port:** `6379`
- **Volume:** `/srv/core/data/redis:/data`
- **Command:** `redis-server --appendonly yes --requirepass <from secrets>`
- **Status:** 🔄 Need to deploy

#### 5. Authelia (SSO/MFA Gateway)
- **Image:** `authelia/authelia:latest`
- **Container:** `authelia`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `9091`
- **URL:** https://auth.nxcore.tail79107c.ts.net/
- **Config:** `/opt/nexus/authelia/configuration.yml`
- **Volumes:**
  - `/opt/nexus/authelia:/config`
  - `/srv/core/data/authelia:/data`
- **Purpose:** Protect Code Studio, Office Suite, AI, Admin tools
- **Status:** 🔄 Need to deploy

---

### 🖥️ **BROWSER WORKSPACES**

#### 6. Landing Page (Status Dashboard)
- **Image:** `nginx:alpine` (static site)
- **Container:** `aerovista-landing`
- **Network:** `traefik_proxy`
- **Internal Port:** `80`
- **URL:** https://nxcore.tail79107c.ts.net/ or https://home.nxcore.tail79107c.ts.net/
- **Files:** `/srv/core/landing/` (HTML/CSS/JS with live status badges)
- **Features:**
  - Links to all services
  - Live health checks (ping endpoints)
  - Green/red status indicators
  - Quick search/filter
- **Status:** 🔄 Need to create

#### 7. Web Desktop (KasmVNC - Linux Desktop in Browser)
- **Image:** `kasmweb/desktop:1.15.0` (Ubuntu with KDE/XFCE)
- **Container:** `web-desktop`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `6901`
- **URL:** https://desktop.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Preinstalled:** GIMP, Audacity, Firefox, LibreOffice
- **Volume:** `/srv/core/data/web-desktop:/home/kasm-user`
- **Purpose:** Full desktop environment accessible from browser
- **Status:** 🔄 Need to deploy

#### 8. Code Studio (code-server - VS Code in Browser)
- **Image:** `codercom/code-server:latest`
- **Container:** `code-studio`
- **Networks:** `traefik_proxy`, `backend`, `jobs`
- **Internal Port:** `8080`
- **URL:** https://code.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Volumes:**
  - `/srv/core/projects:/home/coder/projects`
  - `/srv/core/config/code-server:/home/coder/.config`
- **Extensions:** Pre-install Python, Docker, GitLens, Prettier
- **Status:** 🔄 Need to deploy

#### 9. Data Notebooks (JupyterLab)
- **Image:** `jupyter/datascience-notebook:latest`
- **Container:** `jupyterlab`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `8888`
- **URL:** https://jupyter.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Volume:** `/srv/core/notebooks:/home/jovyan/work`
- **Env:** `JUPYTER_ENABLE_LAB=yes`
- **Status:** 🔄 Need to deploy

#### 10. Office Suite (OnlyOffice Document Server)
- **Image:** `onlyoffice/documentserver:latest`
- **Container:** `onlyoffice`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `80`
- **URL:** https://office.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Volume:** `/srv/core/data/onlyoffice:/var/www/onlyoffice/Data`
- **Env:**
  - `JWT_ENABLED=true`
  - `JWT_SECRET=<from secrets>`
- **Status:** 🔄 Need to deploy

#### 11. Diagramming (draw.io / diagrams.net)
- **Image:** `jgraph/drawio:latest`
- **Container:** `drawio`
- **Network:** `traefik_proxy`
- **Internal Port:** `8080`
- **URL:** https://draw.nxcore.tail79107c.ts.net/
- **Volume:** `/srv/core/data/drawio:/var/lib/drawio`
- **Status:** 🔄 Need to deploy

#### 12. Whiteboard (Excalidraw)
- **Image:** `excalidraw/excalidraw:latest`
- **Container:** `excalidraw`
- **Network:** `traefik_proxy`
- **Internal Port:** `80`
- **URL:** https://whiteboard.nxcore.tail79107c.ts.net/
- **Status:** 🔄 Need to deploy

#### 13. BytePad (Collaborative Notepad)
- **Image:** `etherpad/etherpad:latest`
- **Container:** `bytepad`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `9001`
- **URL:** https://pad.nxcore.tail79107c.ts.net/
- **DB:** PostgreSQL (shared)
- **Status:** 🔄 Need to deploy

---

### 🤖 **AI LAYER**

#### 14. Ollama (Local LLM Runtime)
- **Image:** `ollama/ollama:latest`
- **Container:** `ollama`
- **Network:** `backend`
- **Internal Port:** `11434`
- **Volume:** `/srv/core/data/ollama:/root/.ollama`
- **GPU:** Optional (NVIDIA runtime if available)
- **Models:** Pull `llama3.2`, `codellama`, `mistral`
- **Status:** 🔄 Need to deploy

#### 15. Open WebUI (AI Chat Interface)
- **Image:** `ghcr.io/open-webui/open-webui:latest`
- **Container:** `openwebui`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `8080`
- **URL:** https://ai.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Volumes:**
  - `/srv/core/data/openwebui:/app/backend/data`
- **Env:**
  - `OLLAMA_BASE_URL=http://ollama:11434`
  - `ENABLE_RAG=true`
- **Status:** 🔄 Need to deploy

---

### 📊 **DATA PLANE**

#### 16. MinIO (S3-Compatible Object Storage)
- **Image:** `minio/minio:latest`
- **Container:** `minio`
- **Networks:** `traefik_proxy`, `backend`, `media`
- **Internal Ports:** `9000` (API), `9001` (Console)
- **URLs:**
  - API: https://s3.nxcore.tail79107c.ts.net/
  - Console: https://minio.nxcore.tail79107c.ts.net/
- **Volume:** `/srv/core/data/minio:/data`
- **Env:**
  - `MINIO_ROOT_USER=aerovista`
  - `MINIO_ROOT_PASSWORD=<from secrets>`
- **Buckets:** backups, media, uploads, ai-embeddings
- **Status:** 🔄 Need to deploy

#### 17. Meilisearch (Search Engine)
- **Image:** `getmeili/meilisearch:latest`
- **Container:** `meilisearch`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `7700`
- **URL:** https://search.nxcore.tail79107c.ts.net/
- **Volume:** `/srv/core/data/meilisearch:/meili_data`
- **Env:**
  - `MEILI_MASTER_KEY=<from secrets>`
  - `MEILI_ENV=production`
- **Status:** 🔄 Need to deploy

---

### 🔄 **AUTOMATION & API**

#### 18. n8n (Workflow Automation)
- **Image:** `n8nio/n8n:latest`
- **Container:** `n8n`
- **Networks:** `traefik_proxy`, `backend`, `jobs`
- **Internal Port:** `5678`
- **URL:** https://n8n.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/core/data/n8n:/home/node/.n8n`
- **DB:** PostgreSQL (shared)
- **Env:**
  - `N8N_HOST=n8n.nxcore.tail79107c.ts.net`
  - `N8N_PROTOCOL=https`
  - `WEBHOOK_URL=https://n8n.nxcore.tail79107c.ts.net/`
  - `DB_TYPE=postgresdb`
- **Status:** ✅ Deployed (needs DB migration)

#### 19. Kong (API Gateway)
- **Image:** `kong:3.7-alpine`
- **Container:** `kong`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Ports:** `8000` (proxy), `8001` (admin)
- **URLs:**
  - Proxy: https://api.nxcore.tail79107c.ts.net/
  - Admin: https://kong-admin.nxcore.tail79107c.ts.net/
- **DB:** PostgreSQL (shared - kong DB)
- **Purpose:** API routing, rate limiting, plugins
- **Status:** 🔄 Need to deploy

---

### 📁 **MEDIA & FILES**

#### 20. File Sharing System (Drop & Go)
- **Image:** `nginx:alpine` + `php:8.2-fpm-alpine`
- **Containers:** `nxcore-fileshare-nginx`, `nxcore-fileshare-php`
- **Network:** `gateway`, `backend`
- **Ports:** `8082:80`
- **URL:** http://100.115.9.61:8082/ (Direct IP)
- **URL:** http://share.nxcore.tail79107c.ts.net/ (Tailscale)
- **Features:** Drag & drop uploads, file manager, PHP backend
- **Storage:** `/srv/core/fileshare/uploads/`
- **Status:** ✅ **DEPLOYED**

#### 21. NXCore Dashboard (Live Monitor)
- **Image:** `nginx:alpine`
- **Container:** `nxcore-dashboard`
- **Network:** `gateway`
- **Ports:** `8081:80`
- **URL:** http://100.115.9.61:8081/ (Direct IP)
- **Features:** Live service monitoring, kiosk mode display
- **Display:** Chromium browser on NXCore screen
- **Status:** ✅ **DEPLOYED**

#### 22. FileBrowser (Legacy File Manager)
- **Image:** `filebrowser/filebrowser:latest`
- **Container:** `filebrowser`
- **Network:** `traefik_proxy`, `media`
- **Internal Port:** `80`
- **URL:** https://files.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/core:/srv/core`
  - `/srv/media:/srv/media`
  - `/srv/core/config/filebrowser.db:/database/filebrowser.db`
- **Status:** ✅ Deployed

#### 21. CopyParty (File Server for EchoVerse)
- **Image:** `copyparty/copyparty:latest`
- **Container:** `copyparty`
- **Network:** `traefik_proxy`, `media`
- **Internal Port:** `3923`
- **URL:** https://echoverse.nxcore.tail79107c.ts.net/
- **Volume:** `/srv/media/echoverse:/srv`
- **Purpose:** Serve static music site + file sharing
- **Status:** 🔄 Need to deploy

#### 22. Navidrome (Music Streaming)
- **Image:** `deluan/navidrome:latest`
- **Container:** `navidrome`
- **Network:** `traefik_proxy`, `media`
- **Internal Port:** `4533`
- **URL:** https://music.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/media/music:/music`
  - `/srv/core/data/navidrome:/data`
- **Env:**
  - `ND_LOGLEVEL=info`
  - `ND_BASEURL=/`
- **Status:** 🔄 Need to deploy

#### 23. Jellyfin (All-Media Server) [OPTIONAL]
- **Image:** `jellyfin/jellyfin:latest`
- **Container:** `jellyfin`
- **Network:** `traefik_proxy`, `media`
- **Internal Port:** `8096`
- **URL:** https://jellyfin.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/core/data/jellyfin/config:/config`
  - `/srv/core/data/jellyfin/cache:/cache`
  - `/srv/media:/media`
- **Status:** 🔄 Optional (later)

---

### 🔐 **REMOTE ACCESS**

#### 24. MeshCentral (Fleet Management - RDP/VNC/AMT/WoL)
- **Image:** `ylianst/meshcentral:latest`
- **Container:** `meshcentral`
- **Networks:** `traefik_proxy`, `backend`, `remote`
- **Internal Port:** `443` (HTTPS), `4433` (MPS)
- **URL:** https://mesh.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/core/data/meshcentral/data:/opt/meshcentral/meshcentral-data`
  - `/srv/core/data/meshcentral/files:/opt/meshcentral/meshcentral-files`
  - `/srv/core/data/meshcentral/backups:/opt/meshcentral/meshcentral-backups`
- **DB:** MongoDB (embedded or external)
- **Status:** 🔄 Need to deploy

#### 25. RustDesk Server (hbbs + hbbr)
- **Images:**
  - `rustdesk/rustdesk-server:latest` (hbbs - ID/rendezvous)
  - `rustdesk/rustdesk-server:latest` (hbbr - relay)
- **Containers:** `rustdesk-hbbs`, `rustdesk-hbbr`
- **Network:** `remote` (host network for UDP)
- **Ports:**
  - hbbs: `21115:21115` (TCP), `21116:21116/udp`, `21118:21118` (TCP)
  - hbbr: `21117:21117` (TCP), `21119:21119` (TCP)
- **Volume:** `/srv/core/data/rustdesk:/root`
- **Purpose:** Self-hosted remote desktop (alternative to TeamViewer)
- **Status:** 🔄 Need to deploy

#### 26. AeroCaller (WebRTC Staff Calls)
- **Image:** `node:18-alpine`
- **Container:** `aerocaller`
- **Network:** `remote`
- **Ports:** `4443:4443` (HTTPS - Node-terminated TLS)
- **URL:** https://nxcore.tail79107c.ts.net:4443/
- **Volumes:**
  - `/opt/nexus/aerocaller:/app`
  - `/opt/nexus/aerocaller/certs:/certs:ro`
- **Status:** ✅ Deployed

#### 27. coturn (TURN Server for WebRTC)
- **Image:** `coturn/coturn:latest`
- **Container:** `coturn`
- **Network:** `host` (for UDP NAT traversal)
- **Ports:** `3478` (STUN/TURN), `49160-49200/udp` (relay)
- **Config:** `/srv/core/config/coturn/turnserver.conf`
- **Status:** ✅ Deployed

---

### 📊 **OBSERVABILITY**

#### 28. Prometheus (Metrics DB)
- **Image:** `prom/prometheus:latest`
- **Container:** `prometheus`
- **Networks:** `traefik_proxy`, `observability`
- **Internal Port:** `9090`
- **URL:** https://prometheus.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/core/config/prometheus:/etc/prometheus`
  - `/srv/core/data/prometheus:/prometheus`
- **Scrape Targets:** cAdvisor, node_exporter, blackbox_exporter, all service /metrics
- **Status:** 🔄 Need to deploy

#### 29. Grafana (Dashboards)
- **Image:** `grafana/grafana:latest`
- **Container:** `grafana`
- **Networks:** `traefik_proxy`, `observability`, `backend`
- **Internal Port:** `3000`
- **URL:** https://grafana.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Volumes:**
  - `/srv/core/data/grafana:/var/lib/grafana`
- **DB:** PostgreSQL (shared)
- **Datasources:** Prometheus, Loki, PostgreSQL
- **Status:** 🔄 Need to deploy

#### 30. Loki (Log Aggregation)
- **Image:** `grafana/loki:2.9.0`
- **Container:** `loki`
- **Network:** `observability`
- **Internal Port:** `3100`
- **Volume:** `/srv/core/data/loki:/loki`
- **Config:** `/srv/core/config/loki/loki-config.yml`
- **Status:** 🔄 Need to deploy

#### 31. Promtail (Log Shipper)
- **Image:** `grafana/promtail:2.9.0`
- **Container:** `promtail`
- **Network:** `observability`
- **Volumes:**
  - `/var/lib/docker/containers:/var/lib/docker/containers:ro`
  - `/srv/core/logs:/logs`
  - `/srv/core/config/promtail:/etc/promtail`
- **Target:** Loki
- **Status:** 🔄 Need to deploy

#### 32. Uptime Kuma (Uptime Monitoring)
- **Image:** `louislam/uptime-kuma:latest`
- **Container:** `uptime-kuma`
- **Networks:** `traefik_proxy`, `observability`
- **Internal Port:** `3001`
- **URL:** https://status.nxcore.tail79107c.ts.net/
- **Volume:** `/srv/core/data/uptime-kuma:/app/data`
- **Purpose:** Monitor all service endpoints, show on landing page
- **Status:** 🔄 Need to deploy

#### 33. cAdvisor (Container Metrics)
- **Image:** `gcr.io/cadvisor/cadvisor:latest`
- **Container:** `cadvisor`
- **Network:** `observability`
- **Internal Port:** `8080`
- **Volumes:**
  - `/:/rootfs:ro`
  - `/var/run:/var/run:ro`
  - `/sys:/sys:ro`
  - `/var/lib/docker:/var/lib/docker:ro`
- **Privileged:** Yes
- **Status:** 🔄 Need to deploy

#### 34. Blackbox Exporter (HTTP/Network Probes)
- **Image:** `prom/blackbox-exporter:latest`
- **Container:** `blackbox-exporter`
- **Network:** `observability`
- **Internal Port:** `9115`
- **Config:** `/srv/core/config/blackbox/blackbox.yml`
- **Purpose:** Probe HTTP endpoints, ping services
- **Status:** 🔄 Need to deploy

#### 35. Dozzle (Quick Log Viewer)
- **Image:** `amir20/dozzle:latest`
- **Container:** `dozzle`
- **Networks:** `traefik_proxy`
- **Internal Port:** `8080`
- **URL:** https://logs.nxcore.tail79107c.ts.net/
- **Auth:** Via Authelia
- **Volume:** `/var/run/docker.sock:/var/run/docker.sock:ro`
- **Purpose:** Quick container log viewer (lightweight)
- **Status:** 🔄 Need to deploy

---

### 🛠️ **ADMIN & UTILITIES**

#### 36. Portainer (Container Management UI)
- **Image:** `portainer/portainer-ce:latest`
- **Container:** `portainer`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `9443` (HTTPS), `9000` (HTTP)
- **URL:** https://portainer.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/var/run/docker.sock:/var/run/docker.sock`
  - `portainer_data:/data`
- **Status:** ✅ Deployed (needs 5-min setup)

#### 37. Watchtower (Auto-Updates)
- **Image:** `containrrr/watchtower:latest`
- **Container:** `watchtower`
- **Network:** None (uses Docker socket)
- **Volume:** `/var/run/docker.sock:/var/run/docker.sock`
- **Env:**
  - `WATCHTOWER_CLEANUP=true`
  - `WATCHTOWER_INCLUDE_RESTARTING=true`
  - `WATCHTOWER_POLL_INTERVAL=86400` (24h)
- **Status:** ✅ Deployed

#### 38. Syncthing (Device Sync)
- **Image:** `syncthing/syncthing:latest`
- **Container:** `syncthing`
- **Networks:** `traefik_proxy`
- **Internal Ports:** `8384` (UI), `22000` (sync), `21027/udp` (discovery)
- **URL:** https://sync.nxcore.tail79107c.ts.net/
- **Volumes:**
  - `/srv/core/data/syncthing:/var/syncthing`
  - `/srv/sync:/sync`
- **Status:** 🔄 Need to deploy

---

### 📝 **FORMS & MESSAGING**

#### 39. Formbricks (Forms & Surveys)
- **Image:** `formbricks/formbricks:latest`
- **Container:** `formbricks`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `3000`
- **URL:** https://forms.nxcore.tail79107c.ts.net/
- **DB:** PostgreSQL (shared)
- **Env:**
  - `DATABASE_URL=postgresql://...`
  - `NEXTAUTH_URL=https://forms.nxcore.tail79107c.ts.net`
  - `NEXTAUTH_SECRET=<from secrets>`
- **Status:** 🔄 Need to deploy

#### 40. Mailpit (Dev Mail Sink)
- **Image:** `axllent/mailpit:latest`
- **Container:** `mailpit`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Ports:** `8025` (UI), `1025` (SMTP)
- **URLs:**
  - UI: https://mail.nxcore.tail79107c.ts.net/
  - SMTP: `mailpit:1025` (internal)
- **Purpose:** Catch all dev/test emails
- **Status:** 🔄 Need to deploy

---

### 📦 **OPTIONAL / ADVANCED**

#### 41. Keycloak (Central IdP / OIDC Provider) [OPTIONAL]
- **Image:** `quay.io/keycloak/keycloak:latest`
- **Container:** `keycloak`
- **Networks:** `traefik_proxy`, `backend`
- **Internal Port:** `8080`
- **URL:** https://auth-idp.nxcore.tail79107c.ts.net/
- **DB:** PostgreSQL (shared - keycloak DB)
- **Env:**
  - `KC_DB=postgres`
  - `KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak`
  - `KC_HOSTNAME=auth-idp.nxcore.tail79107c.ts.net`
  - `KC_PROXY=edge`
- **Purpose:** Central SSO for ALL apps (if Authelia isn't enough)
- **Status:** 🔄 Optional (Phase H)

#### 42. Cloudflare Tunnel [OPTIONAL]
- **Image:** `cloudflare/cloudflared:latest`
- **Container:** `cloudflare-tunnel`
- **Network:** `traefik_proxy`
- **Env:**
  - `TUNNEL_TOKEN=<from Cloudflare Zero Trust>`
- **Purpose:** Expose select services publicly (with Cloudflare Access)
- **Status:** 🔄 Optional (Phase H)

---

## Port Allocation Map

### Published Ports (Host → Container)
```
80   → traefik:80       (HTTP - redirects to HTTPS)
443  → traefik:443      (HTTPS - main entry point)
4443 → aerocaller:4443  (HTTPS - WebRTC/PeerJS)
3478 → coturn:3478      (STUN/TURN)
49160-49200/udp → coturn (TURN relay ports)
21115-21119 → rustdesk  (Remote desktop)
```

### Internal Ports (Container ↔ Container via Docker networks)
```
BACKEND NETWORK:
  5432  postgres
  6379  redis
  2375  docker-socket-proxy
  11434 ollama
  9000  minio (API)
  7700  meilisearch

TRAEFIK_PROXY NETWORK:
  All services expose their internal ports here
  Traefik routes based on Host() rules
  
OBSERVABILITY NETWORK:
  9090  prometheus
  3100  loki
  8080  cadvisor
  9115  blackbox-exporter
```

---

## URL Map (All Services)

**Landing & Core:**
- https://nxcore.tail79107c.ts.net/ → Landing page
- https://traefik.nxcore.tail79107c.ts.net/ → Traefik dashboard
- https://auth.nxcore.tail79107c.ts.net/ → Authelia (SSO/MFA)

**Browser Workspaces:**
- https://desktop.nxcore.tail79107c.ts.net/ → Web Desktop (KasmVNC)
- https://code.nxcore.tail79107c.ts.net/ → Code Studio (VS Code)
- https://jupyter.nxcore.tail79107c.ts.net/ → JupyterLab
- https://office.nxcore.tail79107c.ts.net/ → OnlyOffice
- https://draw.nxcore.tail79107c.ts.net/ → draw.io
- https://whiteboard.nxcore.tail79107c.ts.net/ → Excalidraw
- https://pad.nxcore.tail79107c.ts.net/ → BytePad (Etherpad)

**AI:**
- https://ai.nxcore.tail79107c.ts.net/ → Open WebUI (AI chat)

**Automation & API:**
- https://n8n.nxcore.tail79107c.ts.net/ → n8n workflows
- https://api.nxcore.tail79107c.ts.net/ → Kong API gateway
- https://kong-admin.nxcore.tail79107c.ts.net/ → Kong admin

**Media & Files:**
- http://100.115.9.61:8082/ → File Sharing (Drop & Go)
- http://100.115.9.61:8082/files.html → File Manager
- http://100.115.9.61:8081/ → NXCore Dashboard
- https://files.nxcore.tail79107c.ts.net/ → FileBrowser (Legacy)
- https://echoverse.nxcore.tail79107c.ts.net/ → EchoVerse (CopyParty)
- https://music.nxcore.tail79107c.ts.net/ → Navidrome
- https://jellyfin.nxcore.tail79107c.ts.net/ → Jellyfin (optional)

**Remote Access:**
- https://mesh.nxcore.tail79107c.ts.net/ → MeshCentral
- https://nxcore.tail79107c.ts.net:4443/ → AeroCaller
- RustDesk: Direct IP:21115-21119

**Data & Storage:**
- https://s3.nxcore.tail79107c.ts.net/ → MinIO (S3 API)
- https://minio.nxcore.tail79107c.ts.net/ → MinIO Console
- https://search.nxcore.tail79107c.ts.net/ → Meilisearch

**Observability:**
- https://status.nxcore.tail79107c.ts.net/ → Uptime Kuma
- https://prometheus.nxcore.tail79107c.ts.net/ → Prometheus
- https://grafana.nxcore.tail79107c.ts.net/ → Grafana
- https://logs.nxcore.tail79107c.ts.net/ → Dozzle

**Admin:**
- https://portainer.nxcore.tail79107c.ts.net/ → Portainer
- https://sync.nxcore.tail79107c.ts.net/ → Syncthing

**Forms & Messaging:**
- https://forms.nxcore.tail79107c.ts.net/ → Formbricks
- https://mail.nxcore.tail79107c.ts.net/ → Mailpit

---

## Deployment Phases

### ✅ **DONE** (Currently Deployed)
- Traefik
- Tailscale (host + certs)
- File Sharing System (Drop & Go + File Manager)
- NXCore Dashboard (Live Monitor)
- n8n (needs DB migration)
- FileBrowser (Legacy)
- Portainer (needs admin setup)
- AeroCaller
- coturn
- Watchtower
- node_exporter

### 🔵 **PHASE A: Foundation** (Deploy Next)
1. docker-socket-proxy
2. PostgreSQL 16
3. Redis
4. Authelia
5. Landing Page (custom HTML)

**Estimated time:** 45 minutes  
**Order:** socket-proxy → postgres → redis → authelia → landing

### 🟢 **PHASE B: Browser Workspaces** (Deploy After Phase A)
6. Web Desktop (KasmVNC)
7. Code Studio (code-server)
8. JupyterLab
9. OnlyOffice
10. draw.io
11. Excalidraw
12. BytePad (Etherpad)

**Estimated time:** 60 minutes  
**Why:** Requires Authelia for SSO protection

### 🟡 **PHASE C: AI & Automation**
13. Ollama
14. Open WebUI
15. Kong (API gateway)

**Estimated time:** 30 minutes  
**Why:** AI provides instant value, Kong enables API consolidation

### 🟠 **PHASE D: Data & Storage**
16. MinIO
17. Meilisearch

**Estimated time:** 20 minutes  
**Why:** Needed for backups, media, and search features

### 🔴 **PHASE E: Observability**
18. Prometheus
19. Grafana
20. Loki + Promtail
21. Uptime Kuma
22. cAdvisor
23. Blackbox Exporter
24. Dozzle

**Estimated time:** 60 minutes  
**Why:** Critical for monitoring as you scale up services

### 🟣 **PHASE F: Media**
25. Navidrome
26. CopyParty
27. Jellyfin (optional)

**Estimated time:** 30 minutes  
**Why:** EchoVerse and music streaming

### ⚫ **PHASE G: Remote & Forms**
28. MeshCentral
29. RustDesk (hbbs + hbbr)
30. Syncthing
31. Formbricks
32. Mailpit

**Estimated time:** 45 minutes

### ⚪ **PHASE H: Optional/Advanced**
33. Keycloak
34. Cloudflare Tunnel
35. Other specialized tools

**Deploy:** Only if needed

---

## Total Deployment Timeline

- **Week 1:** Clean install (9 services) + Phase A (5 services) = **14 services**
- **Week 2:** Phase B (7 workspace services) + Phase C (3 AI/API) = **24 services**
- **Week 3:** Phase D (2 data) + Phase E (7 observability) = **33 services**
- **Week 4:** Phase F (3 media) + Phase G (5 remote/forms) = **41 services**
- **Future:** Phase H as needed

---

## Resource Requirements

**Minimum:**
- CPU: 8 cores (physical or vCPU)
- RAM: 32 GB
- Disk: 500 GB SSD
- Network: Gigabit

**Recommended:**
- CPU: 12+ cores
- RAM: 64 GB
- Disk: 1 TB NVMe SSD
- GPU: NVIDIA (8GB+ VRAM) for Ollama
- Network: Gigabit + Tailscale

**Storage Breakdown:**
- `/srv/core/data/` → 200 GB (databases, app data)
- `/srv/media/` → 300 GB (music, videos)
- `/srv/core/backups/` → 100 GB (automated backups)
- Docker images → 50 GB

---

## Security Model

**Private (Default):**
- All services accessible only via Tailscale VPN
- Tailscale certs for HTTPS
- No public internet exposure

**Protected (SSO/MFA via Authelia):**
- Code Studio
- Office Suite
- AI Assistant
- Admin tools (Portainer, Grafana, Kong Admin)
- JupyterLab
- Dozzle

**Public (Optional - via Cloudflare Tunnel + Authelia):**
- Landing page (read-only status)
- Forms (Formbricks)
- Select API endpoints (via Kong)

---

**This is the complete map. Ready to start with Phase A?**

