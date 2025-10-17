# Server_Image — Linux Desktop Server (AeroVista)

This guide builds a small, reliable **Linux desktop server** for AeroVista. It hosts internal services like the **AeroCoreOS — Staff Call** signaling/static site, the **n8n automation stack**, and future dashboards—reachable privately over **Tailscale**.

Target OS: **Ubuntu 24.04 LTS** (desktop or server).

---

## 0) Goals

- Private-only access via Tailscale (MagicDNS + `tailscale serve` or tailscale certs)
- Dockerized apps where sensible (n8n + Postgres, Traefik/NGINX optional)
- Systemd-managed Node services (Staff Call)
- Routine backups (restic), logs, and monitoring (node_exporter)

---

## 1) Base OS & user

```bash
# Install Ubuntu 24.04 LTS
sudo apt update && sudo apt -y upgrade
sudo apt -y install curl git jq unzip ufw fail2ban
sudo timedatectl set-timezone America/Los_Angeles  # adjust as needed
```

Create a service user:
```bash
sudo adduser --disabled-password --gecos "" avsvc
sudo usermod -aG sudo avsvc
```

---

## 2) Networking — Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh --accept-dns=true
# Enable MagicDNS in admin console (once)
tailscale ip -4
```

**Option A: Tailscale Serve (recommended)**
```bash
# Map HTTPS to a local port later (e.g., 8443)
sudo tailscale serve https / http://127.0.0.1:8443
sudo tailscale serve status
```

**Option B: Built-in TLS with tailscale certs**
```bash
HOST=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
sudo tailscale cert $HOST
# Files appear in current dir; use them with your Node/NGINX TLS configs.
```

---

## 3) Node.js & Docker

```bash
# Node.js LTS via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt -y install nodejs

# Docker Engine
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
sudo usermod -aG docker avsvc
newgrp docker
```

Optional helpers:
```bash
sudo apt -y install nginx  # if you prefer NGINX over tailscale serve
```

---

## 4) Deploy AeroCoreOS — Staff Call

```bash
sudo mkdir -p /opt/aerocoreos-staff-call
sudo chown -R avsvc:avsvc /opt/aerocoreos-staff-call
cd /opt/aerocoreos-staff-call
# Copy the branded bundle contents here (index.staff.html, app.staff.js, server.staff.js, etc.)
npm install
```

Create a **systemd** service:

`/etc/systemd/system/aerocoreos-staff-call.service`
```ini
[Unit]
Description=AeroCoreOS Staff Call (PeerJS + static)
After=network-online.target

[Service]
Type=simple
User=avsvc
Group=avsvc
WorkingDirectory=/opt/aerocoreos-staff-call
ExecStart=/usr/bin/node server.staff.js
Restart=on-failure
Environment=PORT=8443
# For built-in TLS, add:
# Environment=USE_HTTPS=1
# Environment=KEY_PATH=/opt/aerocoreos-staff-call/host.magicdns.ts.net.key
# Environment=CERT_PATH=/opt/aerocoreos-staff-call/host.magicdns.ts.net.crt

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now aerocoreos-staff-call
journalctl -u aerocoreos-staff-call -f
```

If using **Tailscale Serve**:
```bash
sudo tailscale serve https / http://127.0.0.1:8443
```

Open: `https://<magicdns>/index.staff.html`

---

## 5) n8n Automation Stack (Docker Compose)

`/opt/n8n/docker-compose.yml`
```yaml
version: "3.9"
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: n8npass
      POSTGRES_DB: n8n
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped

  n8n:
    image: n8nio/n8n:latest
    depends_on:
      - postgres
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8npass
      - N8N_HOST=n8n.local
      - N8N_PROTOCOL=http
      - N8N_PORT=5678
      - WEBHOOK_URL=http://n8n.local/
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    restart: unless-stopped

volumes:
  pgdata:
  n8n_data:
```

Bring it up:
```bash
mkdir -p /opt/n8n
cd /opt/n8n
docker compose up -d
```

Expose via **tailscale serve**:
```bash
sudo tailscale serve --https=443 /n8n http://127.0.0.1:5678
```

(Or use NGINX/Traefik and tailscale certs.)

---

## 6) Backups (restic to S3-compatible)

```bash
sudo apt -y install restic
export RESTIC_REPOSITORY="s3:https://s3.us-west-2.amazonaws.com/yourbucket"
export RESTIC_PASSWORD="change-me"
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
restic init
```

Nightly cron (example):
```bash
sudo bash -c 'cat >/etc/cron.daily/backup-restic <<EOF
#!/bin/bash
export RESTIC_REPOSITORY="s3:https://s3.us-west-2.amazonaws.com/yourbucket"
export RESTIC_PASSWORD="change-me"
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
/usr/bin/restic backup /opt/aerocoreos-staff-call /opt/n8n
/usr/bin/restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
EOF'
sudo chmod +x /etc/cron.daily/backup-restic
```

---

## 7) Monitoring

- **node_exporter** (Prometheus) or **netdata** for quick web UI.
```bash
docker run -d --name=node_exporter --pid="host" --net="host" --restart unless-stopped quay.io/prometheus/node-exporter:latest
```

---

## 8) Firewall / hardening

```bash
sudo ufw allow OpenSSH
sudo ufw enable
# If exposing NGINX instead of tailscale serve:
# sudo ufw allow 80/tcp
# sudo ufw allow 443/tcp

# Fail2ban (defaults are fine); enable jail.local tweaks as needed.
```

SSH via tailnet:
```bash
ssh avsvc@<magicdns>
```

---

## 9) Maintenance

- Update monthly: `sudo apt update && sudo apt -y upgrade`
- Rotate restic repo passwords/keys per policy.
- `docker compose pull && docker compose up -d` for n8n updates.
- For Staff Call updates: replace files in `/opt/aerocoreos-staff-call`, then `sudo systemctl restart aerocoreos-staff-call`.

---

## 10) Future

- Migrate mesh voice to an SFU for larger rooms (LiveKit/Janus) behind tailscale serve.
- Add Promtail + Loki (log aggregation).
- Add Postgres backups with `pg_dump` alongside restic.