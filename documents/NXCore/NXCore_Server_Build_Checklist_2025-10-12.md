# NXCore Server — Start‑to‑Finish Task List
_Generated: 2025-10-12_

This checklist reflects the full path to production for the **NXCore** server replacing the prior Linux server. Items are checked when there’s strong evidence from your recent logs/messages that they’re already done.

---

## Phase 0 — Hardware & Firmware Prep
- [ ] Record model/serial; asset tag applied
- [ ] BIOS/UEFI updated to target version (Fast Boot **disabled**, VT‑x/VT‑d **enabled**, TPM **enabled**)
- [ ] Boot order verified (NVMe/SATA first), secure boot as required
- [ ] SMART check on disks; baseline health report saved

**Notes:** You asked about pre‑boot BIOS visibility and Fast Boot earlier; treat these as pending until confirmed.

---

## Phase 1 — OS Install (Ubuntu 24.04 LTS)
- [x] Install Ubuntu Server 24.04 LTS (minimal) — hostname **nxcore**
- [x] Create primary admin user; enable **OpenSSH** during install
- [x] System up‑to‑date: `sudo apt update && sudo apt -y full-upgrade`
- [ ] Static IP or DHCP reservation (optional; tailnet primary)
- [ ] Timezone set to America/Los_Angeles; NTP sync verified

**Notes:** You booted to Ubuntu and are replacing the old server; containers are running now, so marking install as complete.

---

## Phase 2 — Identity & Access
- [x] Add admin group + sudoers; SSH key auth added
- [ ] SSH hardening (PasswordAuth=no, PubkeyAuth=yes, fail2ban jail for sshd)
- [ ] Create service user(s) (e.g., `svc-av`); least‑privilege directories

---

## Phase 3 — Network Mesh (Tailscale)
- [x] Install Tailscale and bring up with SSH: `tailscale up --ssh`
- [x] MagicDNS reachable; tailnet IP observed in diagnostics
- [ ] ACLs reviewed; device tagged (e.g., `tag:nxcore`)

**Notes:** Tailnet IPs were visible in your network debug; treating Tailscale as online.

---

## Phase 4 — Runtime & Tooling
- [x] Install Docker Engine + Compose plugin; add admin to `docker` group
- [x] Validate with `docker info` and hello‑world
- [x] Install baseline CLI tools (git, unzip, htop, jq, make, curl, rsync)

---

## Phase 5 — Storage Layout
- [ ] Create and mount **/srv** (data root) — ensure exists and writable
- [ ] Create data subdirs: `/srv/core`, `/srv/backups`, `/srv/files`, `/srv/compose`
- [ ] fstab entries added; reboot validated
- [ ] Permissions/ownership set (e.g., `chown -R root:root` and service-specific as needed)

**Notes:** Filebrowser failed because `/srv` didn’t exist; mark this whole phase as **pending**.

---

## Phase 6 — Core Services (Docker Compose)
- [x] **Traefik** reverse proxy up
- [x] **Portainer** up
- [x] **Redis** up
- [x] **Postgres** up
- [x] **n8n** up
- [x] **CopyParty** file gateway up
- [ ] **FileBrowser** configured (create DB, admin user, correct `--scope=/srv` after Phase 5)
- [ ] **RustDesk** self‑hosted (if adopting), bound to tailnet only

**Evidence:** Your compose output shows these containers running; FileBrowser creation failed previously due to `/srv` not existing.

---

## Phase 7 — AeroVista App Layer
- [ ] Deploy **Staff Call** to `/opt/aerocoreos-staff-call`
- [ ] Create **systemd** service for Staff Call
- [ ] Expose via `tailscale serve https http://127.0.0.1:8443`
- [ ] Smoke test from another tailnet machine (mic prompt, peer connections)
- [ ] Capture version file in `/opt/aerocoreos-staff-call/VERSION`

**Notes:** Planned and documented; no concrete success logs yet—leaving unchecked.

---

## Phase 8 — Security Hardening
- [ ] `ufw` rules (allow 22/tcp from tailnet, allow required service ports or rely on tailnet only)
- [ ] `fail2ban` for sshd and any public ingress
- [ ] Unattended upgrades enabled; reboots managed with `needrestart` or `equinox` cadence
- [ ] Secrets management for env files (restricted perms; consider sops/age if desired)

---

## Phase 9 — Backup & Restore
- [ ] **restic** configured (target: B2/S3 or local disk)
- [ ] Postgres dumps scheduled (cron/systemd timers)
- [ ] n8n exports scheduled
- [ ] CopyParty/file shares snapshot
- [ ] Restore drill documented and tested

---

## Phase 10 — Observability
- [ ] **node_exporter** running
- [ ] **Prometheus + Grafana** (optional) or lightweight healthchecks
- [ ] Alerting rules (CPU, RAM, disk, container restart flaps)

---

## Phase 11 — Domain / Access
- [x] Tailscale **MagicDNS** entries confirmed for nxcore
- [ ] (Optional) Public exposure strategy (Cloudflare Tunnel or none) — risk reviewed

---

## Phase 12 — Ops Hygiene
- [ ] Centralize compose files under `/srv/compose` with `.env` templates
- [ ] Portainer stacks labeled; deployment notes committed to repo
- [ ] Daily/weekly ops checklist created; patch cycle defined

---

## Phase 13 — Finalize & Snapshot
- [ ] Clean unused images/volumes; confirm `docker system df`
- [ ] Document final service versions
- [ ] Create baseline snapshot (Proxmox/Clonezilla or image backup)
- [ ] Update **AeroVista Image Build Playbook v1.1** link in Ops docs

---

## Quick Next Actions (to flip reds to greens)
1) **Create /srv** tree, set ownership/permissions → re-run FileBrowser admin create.  
2) Add **systemd** service for Staff Call + `tailscale serve` binding → run smoke test.  
3) Turn on **ufw + fail2ban**; verify only tailnet entry points.  
4) Stand up **restic** + schedule DB dumps; run one **restore** test.  
5) Add **node_exporter** + a minimal **Grafana** panel (or an external healthcheck).

---

## Scratchpad — Commands You’ll Likely Use

```bash
# Phase 5 — storage
sudo mkdir -p /srv/{core,backups,files,compose}
sudo chown -R root:root /srv
sudo chmod 755 /srv

# Phase 6 — filebrowser (after /srv exists)
docker run --rm -u 1000:1000   -v /srv/core/filebrowser:/database   -v /srv:/srv   filebrowser/filebrowser:latest   users add admin 'REDACTED' --perm.admin --scope /srv   --locale en --database /database/filebrowser.db

# Phase 7 — Staff Call service (example)
sudo tee /etc/systemd/system/staff-call.service >/dev/null <<'EOF'
[Unit]
Description=AeroCoreOS Staff Call
After=network-online.target
Wants=network-online.target

[Service]
User=svc-av
WorkingDirectory=/opt/aerocoreos-staff-call
ExecStart=/usr/bin/node server.staff.js
Restart=always
Environment=NODE_ENV=production
# Bind via Tailscale Serve once running

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now staff-call

# Bind staff call behind Tailscale HTTPS
tailscale serve https / http://127.0.0.1:8443
```

---

**Owner:** Glyph  
**Status Key:** ☑ Done · ☐ Not done · ◐ In progress

