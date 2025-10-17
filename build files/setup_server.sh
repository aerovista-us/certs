#!/usr/bin/env bash
# setup_server.sh — NXCore baseline setup for Ubuntu 24.04
# Run as root: sudo bash setup_server.sh
set -euo pipefail

log(){ echo -e "\e[32m[+] $*\e[0m"; }
warn(){ echo -e "\e[33m[!] $*\e[0m"; }

log "Update & essentials"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg lsb-release net-tools htop unzip jq ufw   haveged irqbalance smartmontools lm-sensors ethtool openssh-server

log "Timezone & TRIM"
timedatectl set-timezone America/Los_Angeles || true
systemctl enable --now fstrim.timer || true

log "Tailscale"
if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | bash
fi
tailscale up --ssh || warn "Run 'tailscale up --ssh' later if auth required."

log "UFW"
ufw allow OpenSSH
ufw --force enable

log "Docker CE + Compose"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log "Docker daemon.json"
cat >/etc/docker/daemon.json <<'JSON'
{ "log-driver": "json-file", "log-opts": { "max-size": "10m", "max-file": "3" }, "features": { "buildkit": true } }
JSON
systemctl restart docker

log "Sysctl tuning"
cat >/etc/sysctl.d/99-nxcore.conf <<'SYSCTL'
vm.swappiness=10
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=1024
SYSCTL
sysctl --system

log "Create media folders & perms (adjust later if using RAID)"
groupadd -f media
mkdir -p /srv/media /srv/media/music /srv/media/video /srv/media/images /srv/media/_ingest /srv/media/_staging
chown -R :media /srv/media
chmod -R 775 /srv/media

log "Baseline complete. Next steps:"
echo "1) Mount /srv/media (btrfs RAID1 or mdadm RAID1) and verify."
echo "2) Unzip AeroVista_All_in_One_Installer.zip to /opt/aerovista"
echo "3) Create server/.env with MagicDNS + secrets"
echo "4) Start gateway, nxcore_bootstrap, fleet_layer (compose up -d)"
echo "5) Enable media-backup.timer"
