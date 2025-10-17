# NXCore Server Build Guide (Ubuntu 24.04 LTS)
_Last updated: 2025-10-13_

This is the **authoritative, step‑by‑step** for building the Linux server (NXCore) on a clean Ubuntu 24.04 install. It aligns with our all‑in‑one plan: **gateway (Traefik)** → **nxcore_bootstrap (n8n/Postgres/FileBrowser)** → **fleet_layer (MeshCentral/RustDesk/Syncthing)** → **media_on_nxcore (storage + backups)**. Everything stays **private on Tailscale**.

---

## 0) Prereqs
- Hardware: current NXCore box (Linux‑only). Two 512 GB SSDs present.
- Network: admin has Tailscale access + MagicDNS.
- Files: `AeroVista_All_in_One_Installer.zip` staged at `/opt/aerovista` or similar.

---

## 1) Base OS & updates
1. Install **Ubuntu Server 24.04** (minimal). Set hostname (e.g., `av-nxcore-01`).
2. Update packages:
   ```bash
   sudo apt update && sudo apt -y upgrade
   ```

---

## 2) Storage (choose one, then mount at /srv/media)
### A) btrfs RAID1 (preferred for snapshots)
```bash
# Identify disks (replace sdX/sdY)
lsblk -o NAME,SIZE,MODEL
sudo mkfs.btrfs -f -m raid1 -d raid1 /dev/sdX /dev/sdY
sudo mkdir -p /srv/media
UUID=$(sudo blkid -s UUID -o value /dev/sdX)
echo "UUID=$UUID /srv/media btrfs defaults,ssd,compress=zstd,autodefrag 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo systemctl enable --now fstrim.timer
```

### B) mdadm RAID1 + ext4 (also fine)
```bash
sudo apt -y install mdadm
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdX /dev/sdY
sudo mkfs.ext4 -F /dev/md0
sudo mkdir -p /srv/media
UUID=$(sudo blkid -s UUID -o value /dev/md0)
echo "$UUID /srv/media ext4 defaults,noatime 0 0" | sudo tee -a /etc/fstab
sudo mount -a
```

Create folders & permissions:
```bash
sudo groupadd -f media
sudo mkdir -p /srv/media/{music,video,images,_ingest,_staging}
sudo chown -R :media /srv/media
sudo chmod -R 775 /srv/media
```

---

## 3) Network: Tailscale + firewall
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh   # authorize in browser if prompted
sudo ufw allow OpenSSH
sudo ufw --force enable
```

---

## 4) Docker & baseline tuning
Install Docker CE + Compose plugin and sane defaults:
```bash
sudo apt -y install ca-certificates curl gnupg lsb-release net-tools htop unzip jq haveged irqbalance smartmontools lm-sensors ethtool
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update && sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo '{ "log-driver": "json-file", "log-opts": { "max-size": "10m", "max-file": "3" }, "features": { "buildkit": true } }' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```
Sysctl tuning:
```bash
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-nxcore.conf
echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.d/99-nxcore.conf
echo 'fs.inotify.max_user_instances=1024' | sudo tee -a /etc/sysctl.d/99-nxcore.conf
sudo sysctl --system
```

---

## 5) Unpack the All‑in‑One
```bash
sudo mkdir -p /opt/aerovista && cd /opt/aerovista
sudo unzip ~/Downloads/AeroVista_All_in_One_Installer.zip -d .
ls -al
```
Tree (key parts):
```
server/
  gateway/             # Traefik v3 + middlewares
  nxcore_bootstrap/    # n8n + Postgres + FileBrowser
  fleet_layer/         # MeshCentral + RustDesk + Syncthing + dashboard
  media_on_nxcore/     # plan + backup scripts
  aerocaller_coturn_pack/  # TURN (optional)
  install_server.sh    # wrapper
```

---

## 6) Configure MagicDNS hostnames & secrets
Create `/opt/aerovista/server/.env` with:
```
N8N_HOST=...
MESH_HOST=...
SYNC_HOST=...
DASH_HOST=...
API_HOST=...        # if using Kong later
BASIC_AUTH_USER=admin
BASIC_AUTH_HASH=$apr1$...$...
RATE_AVG=60
RATE_BURST=120
TAILSCALE_CERTS=1
```
> We’ll bake these into Traefik/Kong labels and dynamic middlewares.

---

## 7) Bring services online (order matters)
1) **Gateway (Traefik, port 443 only)**
   ```bash
   cd /opt/aerovista/server/gateway
   docker compose up -d
   ```
2) **nxcore_bootstrap** (n8n/Postgres/FileBrowser) — **no host port publishes**, use labels to expose via Traefik.
   ```bash
   cd /opt/aerovista/server/nxcore_bootstrap
   cp .env.example .env   # set N8N_HOST and secrets
   docker compose up -d
   systemctl enable --now n8n-stack.service || true   # if provided
   ```
3) **fleet_layer** (MeshCentral/RustDesk/Syncthing)
   ```bash
   cd /opt/aerovista/server/fleet_layer
   cp .env.example .env   # set FLEET_HOST etc.
   docker compose up -d
   ```
   - GUIs (Mesh/Syncthing) are proxied by Traefik at 443.
   - **Keep data ports published**: RustDesk (21115/21116/21118), Syncthing data (22000/21027).

4) **media_on_nxcore**
   - Ensure `/srv/media` is mounted and permissions set (Step 2).
   - Enable backup timer:
     ```bash
     cd /opt/aerovista/server/media_on_nxcore
     sudo cp media-backup.sh /usr/local/bin/
     sudo chmod +x /usr/local/bin/media-backup.sh
     sudo cp media-backup.service /etc/systemd/system/
     sudo cp media-backup.timer /etc/systemd/system/
     sudo systemctl daemon-reload
     sudo systemctl enable --now media-backup.timer
     ```

5) **(Optional) TURN for WebRTC**
   ```bash
   cd /opt/aerovista/server/aerocaller_coturn_pack
   docker compose up -d
   ```

---

## 8) Port policy (tailnet‑only)
- **Open/Published**: 443 (Traefik), 21114/21115/21116/21118 (RustDesk), 3478 + UDP range (coturn), 22000/21027 (Syncthing data).
- **Everything else** (n8n/Mesh/Syncthing GUIs, dashboard) → via Traefik @ 443 with `tailnet-only`, `basic-auth`, `rateLimit` middlewares.

---

## 9) Verification checklist
- **Tailscale**: `tailscale status --self` OK; MagicDNS resolves.
- **Gateway**: `https://dash.<host>/` (or your chosen host) responds; access logs present.
- **n8n**: `https://n8n.<host>/` loads; basic auth → OK; create a test workflow & webhook.
- **MeshCentral**: `https://mesh.<host>/` loads; agent enrolls one device.
- **Syncthing**: `https://sync.<host>/` GUI proxied; data ports untouched.
- **Media**: `/srv/media` writable; first backup timer run succeeds (check `journalctl -u media-backup.service`).
- **Security**: unattended‑upgrades enabled; SSH via Tailscale only.

---

## 10) Ops notes
- Keep bundles & configs in Git (sanitize secrets).
- Quarterly: test restore from snapshot/rsync backup.
- Capacity: plan disk upgrade when pool ≥ 70–80%.
- Add Grafana later for metrics if needed.

---

**Done.** This guide should live at `/opt/aerovista/server/NXCore_Server_Build_Guide.md` alongside the installer.
