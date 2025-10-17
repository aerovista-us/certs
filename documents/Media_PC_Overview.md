# Media PC — High-Level Overview (Second Server)

## Goal
- **Source of truth for media** (music, video, images) with safe storage and fast LAN access.
- **Private streaming & previews** for the team (music + video).
- **Distribution node** to push selected folders to 20–30 workstations via Syncthing.
- **Zero WAN exposure**; everything lives on your Tailscale.

## Hardware Baseline (Dell Tower)
- **CPU:** modern Intel (Quick Sync helps Jellyfin) or AMD Ryzen.
- **RAM:** 16–32 GB (32 GB if ZFS or Immich).
- **Storage:**
  - 2× 4–8 TB HDD (mirror) for main media pool.
  - 1× 500 GB+ SSD (cache/metadata/apps).
  - External USB SSD/HDD(s) for rotation/off-site backups.
- **NIC:** 1 GbE OK; 2.5 GbE preferred if many simultaneous reads.
- **UPS:** small line-interactive UPS for clean shutdowns.

## OS Options
### Option A — Ubuntu Server 24.04 LTS (recommended)
- FS: **ZFS mirror** (resilient, snapshots) or **btrfs RAID1** (lighter, snapshots).
- Use Docker/Compose for apps; Traefik (or Caddy) as local gateway.

### Option B — TrueNAS SCALE
- ZFS management and snapshots with a friendly GUI; SMB/NFS built-in.
- Less flexible than Ubuntu for custom stacks.

> Recommend **Ubuntu 24.04 + ZFS mirror** for data pool + Docker apps.

## Network & Security
- **Tailscale** on the media server (MagicDNS: `media.tailXXXX.ts.net`).
- Keep services **private**; optionally reverse through **NXCore Traefik** for one TLS entrypoint (SNI: `video.*`, `music.*`).
- **UFW:** allow `tailscale0` and SMB on LAN if needed; otherwise closed.

## Directory & Shares
```
/srv/media/               # ZFS/btrfs pool mount
  music/
    artists/Artist/Album/{WAV,FLAC,MP3,artwork/}
    releases/Year/Project/
  video/
    projects/Year/Client_Project/
    exports/Year/Client_Project/
  images/
    catalogs/Year/Event/
  _ingest/                # drop zone
  _staging/               # clean/tag here before publish

/srv/apps/                # containers’ data (configs, DBs, caches)
```

## Core Software Stack (Docker on Ubuntu)
- **Tailscale** – private networking & certs if desired.
- **Samba (SMB)** – Windows/macOS shares for editors.
- **Syncthing** – distribute selected folders (read-only to most workstations).
- **Jellyfin** – video library & streaming (enable Quick Sync/NVIDIA if present).
- **Navidrome** – music streaming (fast, tiny, great metadata).
- **FileBrowser** *(optional)* – quick web file manager.
- **Traefik** *(optional here)* – local 443 gateway with Tailscale certs.
- **Netdata** *(or Prometheus + node-exporter)* – health/metrics.
- **Backup tools:** `rsync`/`restic` + ZFS/btrfs snapshots.

### Optional Apps (later)
- **Immich** for photo management (needs Postgres + Redis; heavier).
- **Audioserve** for audiobooks.
- **Paperless** if you extend beyond media into docs.

## Ports (tailnet-only)
- **Jellyfin:** 8096 (HTTP) / 8920 (HTTPS) → better behind Traefik 443.
- **Navidrome:** 4533 → also behind Traefik 443.
- **Syncthing:** 8384 (GUI), 22000/TCP+UDP (data), 21027/UDP (discovery).
- **SMB:** 445/TCP (LAN only).
- **Netdata:** 19999 (or reverse it too).

## Users, Groups, Permissions
- Create **media** group; add service users and editor accounts.
- Data pool owned by `media:media` with `775` perms so SMB and services can write.
- Run Syncthing as a non-root user in the `media` group.

## Storage Plan
### ZFS Mirror (2× HDDs)
- Pool: `tank` → dataset `tank/media` mounted at `/srv/media`.
- Enable compression (`lz4`), snapshots, `atime=off`.
- Apps/configs on SSD dataset (`tank/apps` at `/srv/apps`) or separate single SSD.

### Backups
- Nightly ZFS snapshot; weekly `zfs send` or `rsync` to external SSD.
- Keep rolling **7 daily + 4 weekly** snapshots.
- Optional: **restic** to cloud/object storage for off-site automation.

## Workflows
- **Ingest** → drop to `/srv/media/_ingest`.
- **Stage/Tag** → move to `_staging`, normalize names, tag, generate proxies if needed.
- **Publish** → move to final `/srv/media/{music,video,images}`; refresh Jellyfin/Navidrome.
- **Distribute** → Syncthing auto-shares `exports/` (video) + curated `music/` to workstation groups.

## Day‑0 Build (Ubuntu Path)
1) Install **Ubuntu Server 24.04** (minimal), set hostname `av-media-01`.
2) `apt update && apt upgrade -y`, install: `docker`, docker compose plugin, `tailscale`, `samba`, `rsync`, `net-tools`, `htop`.
3) Join **Tailscale**; confirm MagicDNS resolves.
4) Create **ZFS mirror** (`zpool create tank mirror /dev/sdX /dev/sdY`), datasets:
   - `tank/media` → `/srv/media`
   - `tank/apps`  → `/srv/apps`
5) Create `media` group + users; set ownership on `/srv/media`.
6) Bring up Docker apps (compose under `/srv/apps/<app>`). Put UIs behind Traefik or publish LAN-only.
7) Configure **SMB** shares for `media/exports` and (optionally) `music`.
8) Seed **Syncthing**; read-only to most nodes; full write for editors.

## Day‑1 Configuration
- Add **hardware transcoding** to Jellyfin (Intel Quick Sync/NVIDIA).
- Point **Navidrome** library to `/srv/media/music`.
- Create **SMB users** for editors; map to `media` group.
- Set up **snapshots** + **rsync/restic** timer.
- Add **Netdata** (or Prometheus exporters) for CPU/disk temps, I/O, etc.

## Ongoing Ops
- Quarterly scrub of ZFS pool; monitor SMART.
- Snapshot/backup checks; quarterly restore test.
- Library hygiene: tag/rename in `_staging` before publish.
- Capacity plan: when pool hits ~70–80%, schedule disk upgrades.

## Integration with NXCore
- NXCore remains **automations/gateway**; Media PC provides **storage + streaming**.
- If you want one front door, set NXCore Traefik routes:
  - `https://video.nxcore.tail…` → Jellyfin on Media PC
  - `https://music.nxcore.tail…` → Navidrome on Media PC
- Syncthing: Media PC is the **source of truth**; NXCore can be an **introducer/cache** if useful.
