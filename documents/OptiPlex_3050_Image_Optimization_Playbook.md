# Image Optimization Playbook — Dell OptiPlex 3050 SFF (Windows 11 Pro) & NXCore (Ubuntu 24.04)
_Last updated: 2025-10-13_

## Goals
- Stable, repeatable **golden images** tuned for the 3050 SFF hardware
- Fast boot and snappy UI for editors; predictable performance for server workloads
- Clean networking & storage defaults for our Tailscale/Syncthing/Traefik stack
- Minimal noise (logs, telemetry), safe power & thermal behavior

---

# 1) Ubuntu Server 24.04 (NXCore) — Baseline & Tunings
**Model-agnostic, but aligned with current NXCore hardware.**

## 1.1 Install profile
- **ISO**: Ubuntu Server 24.04 LTS (minimal)  
- **Disk**: mirror the two 512 GB SSDs  
  - **Preferred**: **btrfs RAID1** with `compress=zstd,ssd,autodefrag`  
  - Alt: mdadm RAID1 + ext4 (`noatime`)  
- **Hostname**: `av-nxcore-01`
- **Timezone**: America/Los_Angeles

## 1.2 Packages (post-install)
```bash
sudo apt update && sudo apt -y upgrade
sudo apt -y install openssh-server ca-certificates curl gnupg lsb-release net-tools htop unzip ufw   haveged irqbalance smartmontools lm-sensors ethtool   docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 1.3 Network & firewall
- Reserve static IP via DHCP or set **netplan** static.  
- **Tailscale**: `curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --ssh`  
- **UFW**: allow `OpenSSH` (and leave WAN ports closed; tailnet-only).

## 1.4 Filesystem tuning
- **btrfs** mounts in `/etc/fstab`:
  ```
  UUID=<your-btrfs-uuid> /srv/media btrfs defaults,ssd,compress=zstd,autodefrag 0 0
  ```
- **TRIM** weekly:
  ```bash
  sudo systemctl enable --now fstrim.timer
  ```
- **Health** (monthly scrub if btrfs):
  ```bash
  sudo btrfs scrub start -Bd /srv/media
  ```

## 1.5 Kernel/sysctl (I/O, watchers, swappiness)
```bash
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-nxcore.conf
echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.d/99-nxcore.conf
echo 'fs.inotify.max_user_instances=1024' | sudo tee -a /etc/sysctl.d/99-nxcore.conf
sudo sysctl --system
```
- Rationale: lower swap pressure; enough inotify for Syncthing/FileBrowser.

## 1.6 Docker defaults
`/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "features": { "buildkit": true }
}
```
```bash
sudo systemctl restart docker
```

## 1.7 Services (what to bake into image)
- Tailscale enabled at boot
- `n8n-stack.service` + `n8n-pg-backup.timer`
- FileBrowser compose (DB persisted)
- Fleet layer compose (MeshCentral/RustDesk/Syncthing) but **GUIs proxied via Traefik**
- Traefik gateway (443 only) with `tailnet-only`, `basic-auth`, `rateLimit` middlewares

## 1.8 Health & telemetry
- `smartd` enabled; weekly email or log to syslog
- `logrotate` default OK; avoid excessive verbosity
- Optional: `node-exporter` + Grafana stack

## 1.9 Security
- Unattended security updates:
  ```bash
  sudo apt -y install unattended-upgrades
  sudo dpkg-reconfigure -plow unattended-upgrades
  ```
- SSH: key-based or Tailscale SSH; disable password auth if desired.

---

# 2) Windows 11 Pro (OptiPlex 3050 SFF) — Golden Image Guide

## 2.1 Firmware/BIOS
- Update BIOS via **Dell Command | Update**
- Storage mode: **AHCI**
- **Wake on LAN** enabled; if vPro present, enable **Intel AMT**
- Set **High Performance** power profile in BIOS where applicable

## 2.2 Drivers
- Intel chipset, MEI, and **Intel HD/UHD 630** graphics (Quick Sync)
- Realtek/Intel NIC updated
- Optional: HEVC Video Extensions (Microsoft Store) for better playback support

## 2.3 Base OS prep
- Windows 11 Pro, fully patched
- **Dell Command | Update** installed
- **Power plan**: High performance; disable disk sleep
- **Explorer**: show file extensions; show hidden files
- **OneDrive**: disable auto-backup (if not used)
- **Defender**: leave on; add exclusions for large media caches if needed

## 2.4 Apps (fleet + media)
- **Fleet clients**: Syncthing, RustDesk
- **Media tools** (winget; from our Windows pack)
  - Kdenlive, Blender, OBS, FFmpeg, HandBrake, MKVToolNix
  - Audacity, Ardour
  - GIMP, Krita, Inkscape, digiKam, Darktable, MusicBrainz Picard
- Optional: Aegisub (if a maintained winget identifier is available)

## 2.5 Quick Sync & app presets
- Kdenlive/OBS/HandBrake: enable **Intel Quick Sync** encoders for H.264/H.265
- Ship shared **export presets** (reels, web 1080p/4K, mezzanine) via Syncthing Tools
- Fonts & LUTs synced from NXCore `Tools/`

## 2.6 Storage layout
- NVMe C: OS + apps + `C:\Projects\`
- Optional 2.5\" SSD D: `D:\MediaCache\` for proxies/exports
- Syncthing pulls from `\\NXCore\media\video\exports` and curated `music\`

## 2.7 System policies (optional but recommended)
```powershell
# High performance power scheme
powercfg -setactive SCHEME_MIN

# Show file extensions
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' HideFileExt 0

# Disable hibernation (saves disk space)
powercfg -h off

# Enable Remote Desktop (if needed internally)
# Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server' fDenyTSConnections 0
```

## 2.8 Imaging steps (reference)
1. Clean install → apply all configs above → install fleet/media tools  
2. Remove personal accounts/data; run Disk Cleanup  
3. **Sysprep** (OOBE, generalize, shutdown)  
4. Capture image (DISM/MDT) → deploy to fleet  
5. First-boot script enrolls **Syncthing** and sets RustDesk server address

---

# 3) Post-Image Validation (both)
- Network: Tailscale up; MagicDNS resolves; MeshCentral sees the device  
- Storage: TRIM on, SMART healthy, correct mount options  
- Syncthing: folders connected; RO/RW as intended  
- Media apps: Kdenlive + FFmpeg render a short test; OBS test record with Quick Sync  
- Security: updates current; backups or snapshots scheduled

---

# 4) Appendices

## 4.1 Syncthing ignore template (`.stignore` for media shares)
```
# temp and cache
**/*.tmp
**/*.bak
**/.cache/
**/.thumbnails/
**/*_proxy/*
```

## 4.2 Suggested HandBrake preset (CLI, 1080p web)
```bash
HandBrakeCLI -i INPUT.mp4 -o OUTPUT.mp4 -e x264 -q 20 --aencoder av_aac --mixdown stereo --arate auto   --encoder-preset medium --encoder-tune film --vfr --optimize --width 1920 --height 1080
```

## 4.3 Docker Compose log rotation snippet
```yaml
x-logging: &default-logging
  options:
    max-size: "10m"
    max-file: "3"
  driver: json-file

services:
  yourservice:
    logging: *default-logging
```
