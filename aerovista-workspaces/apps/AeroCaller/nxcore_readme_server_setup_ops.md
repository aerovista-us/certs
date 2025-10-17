# NXCore Server – README

> Primary hostnames: `nxcore` (OS & Tailscale device name)
>
> Tailnet FQDN: `nxcore.tail79107c.ts.net`
>
> Tailscale IP (example from setup): `100.115.9.61`

This document captures how we provisioned and operate **NXCore** – the replacement primary server with local AI and core services. It includes network setup (Tailscale), Docker runtime, services (FileBrowser & n8n), and day‑2 ops (updates, logs, troubleshooting).

---

## 1) Base OS
- **Ubuntu**: 24.04 LTS (noble)
- **Hostname**
  ```bash
  sudo hostnamectl set-hostname nxcore
  ```

---

## 2) Networking – Tailscale
### Install via APT repository (recommended)
```bash
# Add key + repo (Ubuntu 24.04 "noble")
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
  | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/ubuntu noble main" \
  | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null

sudo apt update
sudo apt install -y tailscale
sudo systemctl enable --now tailscaled
```

### Join tailnet
```bash
# Interactive (browser prompt)
sudo tailscale up --ssh --hostname nxcore
# or with an auth key (preferred for automation)
# sudo tailscale up --ssh --hostname nxcore --authkey tskey-xxxxxxxx
```

### Verify / rename device later
```bash
tailscale status --self
# if renaming after first join:
sudo tailscale set --hostname nxcore    # or: sudo tailscale up --hostname nxcore --ssh
```

### Optional: Subnet routing
```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-tailscale.conf
sudo sysctl --system
# adjust routes to your LAN if desired
# sudo tailscale up --ssh --hostname nxcore --advertise-routes=192.168.4.0/22
```

---

## 3) Docker Runtime
```bash
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release
# (Docker CE install assumed done previously)

# Ensure daemon is enabled
sudo systemctl enable --now docker

# Add current user to docker group (no sudo for docker)
sudo usermod -aG docker "$USER"
# then either relogin or:
newgrp docker <<<'true'
```

**Quick checks**
```bash
systemctl is-active docker && docker --version
id -nG | tr ' ' '\n' | grep -x docker || echo "not in docker group"
ls -l /var/run/docker.sock
```

---

## 4) Service Layout & Data Paths
```
/srv/core/
  ├─ compose-filebrowser.yml
  ├─ compose-n8n.yml
  ├─ filebrowser/           # DB & (optional) /config for FileBrowser
  │   ├─ filebrowser.db
  │   └─ config/
  └─ n8n_data/              # n8n persistent state (~/.n8n)
```

Create/permission:
```bash
sudo mkdir -p /srv/core/filebrowser/config /srv/core/n8n_data
sudo install -o 1000 -g 1000 -m 0644 /dev/null /srv/core/filebrowser/filebrowser.db
sudo chown -R 1000:1000 /srv/core/filebrowser /srv/core/n8n_data
```

---

## 5) FileBrowser (HTTP on /fb via :8080)
Compose file (`/srv/core/compose-filebrowser.yml`):
```yaml
services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    user: "1000:1000"
    ports: ["8080:80"]
    command:
      - --baseurl=/fb
      - --address=0.0.0.0
      - --port=80
      - --database=/database/filebrowser.db
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /srv/core:/srv
      - /srv/core/filebrowser:/database
      - /srv/core/filebrowser/config:/config
    restart: unless-stopped
```
Deploy / verify:
```bash
docker compose -p fb -f /srv/core/compose-filebrowser.yml up -d
curl -sS http://127.0.0.1:8080/fb/ | head -n2
```
Access (Tailscale IP):
- **FileBrowser:** `http://100.115.9.61:8080/fb/`

_First login shows a random admin password in logs. Change it immediately._
```bash
sudo docker logs filebrowser --tail=50
# change password if needed
# docker exec filebrowser filebrowser users update admin --password 'NEW_STRONG_PASSWORD'
```

---

## 6) n8n (HTTP on :5678)
Compose file (`/srv/core/compose-n8n.yml`):
```yaml
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    user: "1000:1000"
    ports: ["5678:5678"]
    environment:
      - GENERIC_TIMEZONE=America/Los_Angeles
      - N8N_PROTOCOL=http
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_DIAGNOSTICS_ENABLED=false
      # Optional (if serving behind HTTPS host later):
      # - N8N_EDITOR_BASE_URL=https://nxcore.tail79107c.ts.net/
      # - WEBHOOK_URL=https://nxcore.tail79107c.ts.net/
    volumes:
      - /srv/core/n8n_data:/home/node/.n8n
    restart: unless-stopped
```
Deploy / verify:
```bash
docker compose -p n8n -f /srv/core/compose-n8n.yml up -d
ss -tulpen | egrep ':5678' || true
```
Access (Tailscale IP):
- **n8n:** `http://100.115.9.61:5678`

> If you later access n8n over HTTPS, and see the “secure cookie” warning on HTTP, either disable secure cookie for private tailnet access (`N8N_SECURE_COOKIE=false`) or put HTTPS in front (see §7).

---

## 7) Optional: HTTPS front-door via Tailscale Serve (new CLI)
The new `serve` syntax runs in the background and automatically provisions certs for your MagicDNS FQDN.

**Example A: n8n at `/`, FileBrowser at `/fb`**
```bash
sudo tailscale serve reset
sudo tailscale serve --bg http://localhost:5678
sudo tailscale serve --bg --set-path /fb http://localhost:8080
tailscale serve status
# Open: https://nxcore.tail79107c.ts.net/   and  https://nxcore.tail79107c.ts.net/fb
```

**Example B: FileBrowser at `/`, n8n at `/n8n` (n8n path-aware)**
```bash
# adjust n8n compose to set:
#   N8N_PATH=/n8n
#   N8N_EDITOR_BASE_URL=https://nxcore.tail79107c.ts.net/n8n/
#   WEBHOOK_URL=https://nxcore.tail79107c.ts.net/n8n/

sudo tailscale serve reset
sudo tailscale serve --bg http://localhost:8080
sudo tailscale serve --bg --set-path /n8n http://localhost:5678
```

---

## 8) Day‑2 Ops
### Start/Stop/Status
```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
docker logs filebrowser --tail=100
docker logs n8n --tail=100
```

### Updating containers
```bash
# pull latest images and recreate
/docker compose -p fb  -f /srv/core/compose-filebrowser.yml pull && \
 docker compose -p fb  -f /srv/core/compose-filebrowser.yml up -d

docker compose -p n8n -f /srv/core/compose-n8n.yml pull && \
 docker compose -p n8n -f /srv/core/compose-n8n.yml up -d
```

### Firewall (UFW)
UFW is currently **inactive**. If enabling, allow Tailscale and app ports:
```bash
sudo ufw allow in on tailscale0
sudo ufw allow 22/tcp 8080/tcp 5678/tcp
sudo ufw enable
sudo ufw status verbose
```

---

## 9) Troubleshooting Cheatsheet
- **Is Docker running / permissions?**
  ```bash
  systemctl is-active docker || sudo systemctl enable --now docker
  groups $USER | grep -q docker || echo "add user to docker group"
  ```
- **Is a service listening?**
  ```bash
  ss -tulpen | egrep ':8080|:5678' || echo 'no listeners'
  ```
- **FileBrowser DB path issues** (should be `/database/filebrowser.db` inside container):
  ```bash
  docker logs filebrowser --tail=80 | egrep 'database|Using database|does not exist'
  docker inspect filebrowser --format '{{range .Mounts}}{{.Destination}} <- {{.Source}}{{printf "\n"}}{{end}}'
  # initialize (only once):
  docker exec -u 1000:1000 filebrowser filebrowser config init -a 0.0.0.0 -p 80 -d /database/filebrowser.db
  # or enforce via CLI flags in compose (see §5)
  ```
- **n8n EACCES on ~/.n8n/config**: ensure host dir ownership is 1000:1000.
  ```bash
  sudo chown -R 1000:1000 /srv/core/n8n_data
  ```
- **Tailscale Serve rules (new CLI)**
  ```bash
  tailscale serve status
  sudo tailscale serve reset
  sudo tailscale serve --bg http://localhost:8080
  sudo tailscale serve --bg --set-path /n8n http://localhost:5678
  ```

---

## 10) Nice-to‑have Add‑ons (Optional)
- **Portainer (Docker UI)** @ `https://<FQDN>:9443`
  ```yaml
  # /srv/core/compose-portainer.yml
  services:
    portainer:
      image: portainer/portainer-ce:latest
      container_name: portainer
      restart: unless-stopped
      ports: ["9443:9443"]
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /srv/core/portainer:/data
  ```
  ```bash
  docker compose -f /srv/core/compose-portainer.yml up -d
  ```
- **Watchtower** (auto-update containers daily)
  ```yaml
  # /srv/core/compose-watchtower.yml
  services:
    watchtower:
      image: containrrr/watchtower:latest
      container_name: watchtower
      restart: unless-stopped
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
      command: --cleanup --include-restarting --interval 86400
  ```
  ```bash
  docker compose -f /srv/core/compose-watchtower.yml up -d
  ```

---

## 11) Current Endpoints (as deployed)
- **FileBrowser (HTTP):** `http://100.115.9.61:8080/fb/`
- **n8n (HTTP):** `http://100.115.9.61:5678`
- **Optional HTTPS via MagicDNS** using Tailscale Serve (see §7)

---

## 12) Change Log (highlights)
- Added Tailscale APT repo; installed 1.88.x; device joined & renamed to `nxcore`.
- Brought up Docker; added user to `docker` group.
- Deployed FileBrowser with persistent DB at `/srv/core/filebrowser/filebrowser.db` and base URL `/fb`.
- Deployed n8n with persistent data at `/srv/core/n8n_data`.
- (Optional) Tailscale Serve tested; new CLI syntax (`serve --bg`, `--set-path`).

---

## 13) To‑Do / Next Steps (optional)
- Enable **MagicDNS** & keep HTTPS via Tailscale Serve for both apps.
- Add **Portainer** & **Watchtower** for management & updates.
- Define **backup** policy for `/srv/core/**` and n8n data.
- Consider deploying **Ollama** or other local AI services behind the same pattern.

---

**Owner:** Timbr  
**Repo/Folder (Windows client):** `D:\NeXuS\NXCore-Control` (control scripts & automation live here)

