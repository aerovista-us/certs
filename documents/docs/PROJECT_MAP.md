# NXCore-Control Project Map

**Purpose:** Windows operator pack to deploy and manage AeroVista infrastructure on NXCore server  
**Primary Goal:** Build complete "work from any browser" platform for AeroVista team

---

## 🗺️ Navigation Guide

### 📖 Start Here (in order)

1. **[README.md](README.md)** - Project overview & quick start
2. **[docs/CLEAN_INSTALL_GUIDE.md](docs/CLEAN_INSTALL_GUIDE.md)** - Step-by-step deployment (30 min)
3. **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** - Command cheat sheet & troubleshooting

### 📋 Planning & Architecture

4. **[docs/AEROVISTA_COMPLETE_STACK.md](docs/AEROVISTA_COMPLETE_STACK.md)** - All 41 services mapped (versions, ports, URLs)
5. **[docs/MULTI_NODE_ARCHITECTURE.md](docs/MULTI_NODE_ARCHITECTURE.md)** - How to scale to 6 nodes
6. **[docs/CLEAN_INSTALL_SUMMARY.md](docs/CLEAN_INSTALL_SUMMARY.md)** - Before/after comparison, top 10 mistakes

### 🆘 If Things Break

7. **[docs/TROUBLESHOOTING_COMPLETE_REPORT.md](docs/TROUBLESHOOTING_COMPLETE_REPORT.md)** - Analysis of all known issues & fixes

---

## 📁 Project Structure (Clean)

```
NXCore-Control/
├── 📖 README.md                    ← Project overview
├── 🗺️ PROJECT_MAP.md              ← This file (navigation)
├── ⚙️ cursor.json                  ← Cursor tasks (Deploy buttons)
├── 📏 .cursorrules                 ← AI agent instructions
│
├── 📚 docs/                        ← **ALL DOCUMENTATION HERE**
│   ├── CLEAN_INSTALL_GUIDE.md      ← Main deployment guide ⭐
│   ├── QUICK_REFERENCE.md          ← Commands & troubleshooting
│   ├── AEROVISTA_COMPLETE_STACK.md ← Full service inventory
│   ├── MULTI_NODE_ARCHITECTURE.md  ← Scaling to multiple servers
│   ├── CLEAN_INSTALL_SUMMARY.md    ← Summary & learnings
│   └── TROUBLESHOOTING_COMPLETE_REPORT.md ← Issue analysis
│
├── 🐳 docker/                      ← **DOCKER COMPOSE FILES**
│   ├── compose-traefik.yml         ← Reverse proxy (deploy first!)
│   ├── compose-n8n.yml             ← Workflow automation
│   ├── compose-filebrowser.yml     ← File browser
│   ├── compose-portainer.yml       ← Container management UI
│   ├── compose-aerocaller.yml      ← WebRTC calling app
│   └── traefik-dynamic.yml         ← Traefik middleware/TLS config
│
├── 📜 scripts/                     ← **DEPLOYMENT SCRIPTS**
│   ├── ps/                         ← PowerShell scripts (Windows)
│   │   └── deploy-containers.ps1   ← Main deployment script ⭐
│   ├── clean-wipe-nxcore.sh        ← Reset script (use before clean install)
│   ├── ssh-nxcore.bat              ← Quick SSH connection
│   └── scp-to-nxcore.bat           ← Quick file copy
│
├── 📱 apps/                        ← **APPLICATION SOURCE CODE**
│   └── AeroCaller/                 ← WebRTC staff calling app
│       ├── server.staff.js         ← Node.js server
│       ├── app.staff.js            ← Client-side app
│       ├── index.staff.html        ← Main page
│       └── package.json            ← Dependencies
│
├── ⚙️ configs/                     ← **CONFIGURATION TEMPLATES**
│   ├── tailscale-acl.json          ← Tailscale access control
│   └── ufw-rules.txt               ← Firewall rules
│
├── 🛠️ utils/                       ← **UTILITIES & HELPERS**
│   ├── coturn/                     ← TURN server for WebRTC
│   │   ├── docker-compose.yml      ← Coturn deployment
│   │   ├── README.md               ← Setup guide
│   │   └── *.sh                    ← Helper scripts
│   └── windows/                    ← Windows setup tools
│       ├── install-ssh.ps1         ← Install OpenSSH on Windows
│       └── winget-install.bat      ← Install common tools
│
└── 🗄️ build files/                ← **ARCHIVE (reference only)**
    ├── media-backup.*              ← Systemd backup scripts
    ├── *_Checklist_*.md            ← Build checklists
    └── *.csv                       ← Inventory/audit data
```

---

## 🎯 Deployment Phases (Your Current Status)

### ✅ **COMPLETED**
- [x] Created complete documentation set (6 guides)
- [x] Updated all compose files for Traefik-first architecture
- [x] Prepared clean install guide
- [x] Analyzed 200 pages of troubleshooting logs

### 🔵 **NEXT: Phase A - Foundation (Deploy These 5 Services)**
**Estimated time:** 45 minutes

1. **docker-socket-proxy** - Secure Docker socket access
2. **PostgreSQL 16** - Primary database
3. **Redis** - Cache & queues
4. **Authelia** - SSO/MFA gateway
5. **Landing Page** - Status dashboard

**How to deploy:**
```powershell
# Will be automated in deploy-containers.ps1
# For now: follow docs/CLEAN_INSTALL_GUIDE.md Phase 1-5
```

### 🟢 **FUTURE: Phase B - Browser Workspaces**
- Web Desktop (KasmVNC)
- Code Studio (VS Code in browser)
- JupyterLab
- OnlyOffice
- draw.io, Excalidraw, BytePad

### 🟡 **FUTURE: Phase C - AI & Automation**
- Ollama (LLM runtime)
- Open WebUI (AI chat)
- Kong (API gateway)

### 🟠 **FUTURE: Phase D-H** - Data, Media, Observability, etc.
See **[docs/AEROVISTA_COMPLETE_STACK.md](docs/AEROVISTA_COMPLETE_STACK.md)** for full roadmap

---

## 🚀 Quick Commands

### Deploy Services (from Windows)
```powershell
# Deploy Traefik (reverse proxy - MUST be first)
.\scripts\ps\deploy-containers.ps1 -Service traefik

# Deploy individual services
.\scripts\ps\deploy-containers.ps1 -Service n8n
.\scripts\ps\deploy-containers.ps1 -Service filebrowser
.\scripts\ps\deploy-containers.ps1 -Service portainer
.\scripts\ps\deploy-containers.ps1 -Service aerocaller

# Deploy everything
.\scripts\ps\deploy-containers.ps1 -Service all
```

### SSH to Server
```bash
# Quick connect
scripts\ssh-nxcore.bat

# Or manually
ssh glyph@192.168.7.209
```

### Check Status (on server)
```bash
# All containers
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Specific service
sudo docker logs <service> --tail 50

# Network health
sudo docker network inspect gateway
```

---

## 📊 Service URLs (After Deployment)

**Replace `tail79107c` with your actual Tailscale tailnet ID**

### Core Services
- **Landing Page:** https://nxcore.tail79107c.ts.net/
- **Traefik Dashboard:** https://traefik.nxcore.tail79107c.ts.net/
- **Authelia (SSO):** https://auth.nxcore.tail79107c.ts.net/

### Apps (Current)
- **n8n:** https://n8n.nxcore.tail79107c.ts.net/
- **FileBrowser:** https://files.nxcore.tail79107c.ts.net/
- **Portainer:** https://portainer.nxcore.tail79107c.ts.net/
- **AeroCaller:** https://nxcore.tail79107c.ts.net:4443/

### Future Apps (Phase B+)
- **Web Desktop:** https://desktop.nxcore.tail79107c.ts.net/
- **Code Studio:** https://code.nxcore.tail79107c.ts.net/
- **AI Assistant:** https://ai.nxcore.tail79107c.ts.net/
- **JupyterLab:** https://jupyter.nxcore.tail79107c.ts.net/
- **Office Suite:** https://office.nxcore.tail79107c.ts.net/
- [See full list in AEROVISTA_COMPLETE_STACK.md](docs/AEROVISTA_COMPLETE_STACK.md#url-map-all-services)

---

## 🧹 Files to Ignore/Delete

The following files are **reference only** or **outdated** - safe to ignore:

### Archive/Reference (in `build files/`)
- `*.zip` - Old bundles (keep for reference)
- `*_Checklist_*.md` - Build checklists (pre-clean-install)
- `*.csv` - Inventory data (snapshot)
- Old backup scripts (replaced by clean install guide)

### Duplicates
- `docker/compose-portainer.ee.fixed.yml` - Old version (use `compose-portainer.yml`)
- `docker/compose-portainer.ee.yml` - Enterprise version (use CE version)
- `Terminal_hell.docx` - Analyzed, info is now in TROUBLESHOOTING_COMPLETE_REPORT.md
- `PS CUserstrcam scp build filesmedia.txt` - Terminal log (analyzed)

### Incomplete/Experimental
- `aerovista-workspaces/` - Incomplete workspace configs (replaced by complete stack)
- `all.in.one.installer/` - Old installer (replaced by clean install guide)
- `apps/AeroCaller/design concept/` - Design drafts (app is built)

---

## 🎓 Learning Path

**If you're new to this project:**

1. Read **[README.md](README.md)** (5 min)
2. Skim **[docs/AEROVISTA_COMPLETE_STACK.md](docs/AEROVISTA_COMPLETE_STACK.md)** (10 min) - see the big picture
3. Follow **[docs/CLEAN_INSTALL_GUIDE.md](docs/CLEAN_INSTALL_GUIDE.md)** (30 min) - deploy Phase 1-3
4. Keep **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** open for commands

**If something breaks:**
- Check **[docs/TROUBLESHOOTING_COMPLETE_REPORT.md](docs/TROUBLESHOOTING_COMPLETE_REPORT.md)**

**When you're ready to scale:**
- Read **[docs/MULTI_NODE_ARCHITECTURE.md](docs/MULTI_NODE_ARCHITECTURE.md)**

---

## 🔧 Development Workflow

### Making Changes

1. **Edit compose files** in `docker/` folder
2. **Test locally:** `.\scripts\ps\deploy-containers.ps1 -Service <name>`
3. **Verify:** `ssh glyph@192.168.7.209 "sudo docker logs <service>"`
4. **Document** changes in appropriate doc file

### Adding New Services

1. Create `docker/compose-<service>.yml`
2. Add to `scripts/ps/deploy-containers.ps1` (add to ValidateSet)
3. Add to `cursor.json` (create Cursor task)
4. Document in `docs/AEROVISTA_COMPLETE_STACK.md`
5. Update this PROJECT_MAP.md

### Updating Documentation

- **Quick fixes/commands** → `docs/QUICK_REFERENCE.md`
- **New troubleshooting** → `docs/TROUBLESHOOTING_COMPLETE_REPORT.md`
- **Architecture changes** → `docs/MULTI_NODE_ARCHITECTURE.md`
- **Service additions** → `docs/AEROVISTA_COMPLETE_STACK.md`

---

## 📞 Support & Resources

### Internal Docs (This Repo)
- All `.md` files in `docs/` folder
- This `PROJECT_MAP.md` file

### External Resources
- **Traefik:** https://doc.traefik.io/traefik/
- **Tailscale:** https://tailscale.com/kb/
- **Docker Compose:** https://docs.docker.com/compose/
- **n8n:** https://docs.n8n.io/

### Quick Links
- **NXCore SSH:** `ssh glyph@192.168.7.209`
- **Tailscale Admin:** https://login.tailscale.com/admin/
- **Service Status:** (After deployment) https://status.nxcore.tail79107c.ts.net/

---

## 🎯 Success Metrics

You'll know the project is **working** when:

- [ ] All `docs/` guides are read and understood
- [ ] Clean install completed (Phase 1-9 from CLEAN_INSTALL_GUIDE.md)
- [ ] All service URLs accessible from browser
- [ ] No password prompts (SSH keys configured)
- [ ] No port conflicts (docker ps shows clean)
- [ ] Monitoring dashboards show green (Uptime Kuma, Grafana)
- [ ] Team can access browser workspaces
- [ ] AI assistant responds to queries
- [ ] All docs updated with actual deployment details

---

## 📝 Changelog

### 2025-10-13 - Initial Project Cleanup
- Created complete documentation set (6 guides)
- Consolidated architecture into clear phases
- Removed redundant compose files
- Updated all services for Traefik-first approach
- Created this PROJECT_MAP.md for easy navigation

---

**Last Updated:** 2025-10-13  
**Maintained By:** NXCore-Control Team  
**License:** Private (AeroVista Internal)

