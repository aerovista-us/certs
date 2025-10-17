# AeroVista Image Build Playbook — PC + Server (v1.1)

_Generated: 2025-10-12_

Consolidates the Windows **Golden PC Image** steps and the **Linux Desktop‑Server** steps into a single playbook. Adds a concise appendix for skipping Microsoft account during OOBE.

---

# AeroVista Image Build Playbook (PC + Server)


> Generated: 2025-10-10 06:20:28 • Scope: Windows PC Image + Linux Server Image • Owner: AeroVista (Timbr)

## ⚡ Quick‑Action Checklists (Pin Me)

### ✅ PC Setup — Existing Windows 11 Pro Workstation
- [ ] **System Ready**: Windows 11 Pro installed, updated, local admin account configured
- [ ] Install core networking: **Tailscale**, **RustDesk** (from `av-rustdesk-desktop-pack.zip`), verify remote access
- [ ] Install AeroVista apps (see _PC App List_ below)
- [ ] **Install NXCore SSL Certificate** (see _Certificate Installation_ below)
- [ ] Drop **Staff Call bundle** and wire **autostart** with `Start-AeroCoreOS-StaffCall.bat`
- [ ] Configure browsers, certificates, and CSP/Firewall rules per policy
- [ ] Validate system: network, Staff Call, RustDesk, Tailscale, **NXCore access**
- [ ] Document setup completion and certificate thumbprint

### ✅ Server Image — Ubuntu Desktop‑Server (Call‑Center Linux)
- [ ] Install Ubuntu 24.04 LTS (minimal) + OpenSSH; set hostname & static IP (or DHCP reservation)
- [ ] Join **Tailscale**; enable tailnet SSH; lock down inbound WAN
- [ ] Install Docker & Docker Compose; create service user; enable log rotation
- [ ] Deploy **n8n + Postgres + Traefik/NGINX** stack; TLS (Let's Encrypt) via Traefik or reverse proxy
- [ ] Seed AeroVista/Nexus workflows; set env secrets; set backups (pg_dump + volume snapshots)
- [ ] Systemd services enabled; health checks; uptime/alerting
- [ ] Observability: logs, metrics dashboards; cost/project budgets
- [ ] Harden: firewall (ufw), fail2ban, automatic security updates
- [ ] Document versions; store compose & .env in repo (no secrets); push SOP updates


## Table of Contents
- [Quick‑Action Checklists](#-quickaction-checklists-pin-me)
- [1. Golden PC Image (Windows)](#1-golden-pc-image-windows)
- [2. NXCore SSL Certificate Installation](#2-nxcore-ssl-certificate-installation)
- [3. Drop‑and‑Go Staff Call Bundle](#3-dropandgo-staff-call-bundle)
- [4. RustDesk Desktop Pack](#4-rustdesk-desktop-pack)
- [5. PC App List (Include in Image)](#5-pc-app-list-include-in-image)
- [6. Server Image (Ubuntu Desktop‑Server)](#6-server-image-ubuntu-desktopserver)
- [7. Assets & Scripts](#7-assets--scripts)
- [8. Post‑Image Validation](#8-postimage-validation)
- [9. Troubleshooting Notes](#9-troubleshooting-notes)
- [10. Revision & Sources](#10-revision--sources)

## 1. Golden PC Image (Windows)

# AV_PC_IMAGE — Golden Windows Image for AeroVista Workstations

This playbook builds the **first golden image** and rolls it out to multiple AeroVista desktops. It assumes Windows 11 Pro and a small/medium environment using **Tailscale** instead of a domain.

---

## 0) Goals

- Consistent, locked‑down workstation with AeroVista tools preloaded
- One‑click **AeroCoreOS — Staff Call** on boot
- PWA shortcuts for web apps (AeroCoreOS, Daily Brief Builder, AdminCenter, etc.)
- Private networking via Tailscale; minimal public footprint
- Repeatable capture/deployment (Clonezilla/MDT/Autopilot alternatives documented)

---

## 1) Prepare the Reference Machine (“golden”)

1. **Install Windows 11 Pro** (latest ISO). Create a local admin: `av-admin`.
2. **Update**: Windows Update + OEM drivers.
3. **Security & baseline**
   - Enable **BitLocker** on system drive (TPM + PIN if desired).
   - Turn on **SmartScreen**; disable consumer experiences.
   - Set **Power**: High performance (no sleep for plugged‑in desktops).
   - Turn off hibernation: `powercfg -h off` (optional).
4. **Folders**
   - `C:\AeroVista\apps\` (zips, node services, scripts)
   - `C:\AeroVista\logs\`
   - `C:\AeroVista\shortcuts\`
5. **Install baseline software**
   - **Tailscale** (login to tailnet; enable MagicDNS)
   - **Node.js LTS** (x64)
   - **Git** + Git Credential Manager
   - **VS Code** (extensions: GitHub Copilot or preferred, ESLint, Prettier)
   - **7‑Zip**, **VLC**
   - (Optional) **Docker Desktop** (only for dev workstations)
6. **Browser policies** (Edge/Chrome)
   - Allow PWA install.
   - Microphone permissions → `https://<your-magicdns>` and `http://localhost` = **Allow**.
   - Auto-update enabled.

---

## 2) Install AeroVista payloads

> Keep everything under `C:\AeroVista\apps\...` for easy servicing.

1. **AeroCoreOS — Staff Call**
   - Extract `aerocoreos-staff-call-branded.zip` to `C:\AeroVista\apps\staff-call\`
   - Test: `node server.staff.js` → open `http://localhost:8443`  
   - Configure HTTPS (tailnet):  
     Open an elevated prompt and run:
     ```bat
     tailscale serve https / http://127.0.0.1:8443
     tailscale serve status
     ```
   - Auto‑start on login: copy **Start-AeroCoreOS-StaffCall.bat** to:
     `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` for each profile (or use Task Scheduler for all users).

2. **AeroCoreOS / Dashboards / PWA shortcuts**
   - Visit each app URL on the tailnet:  
     - AeroCoreOS Dashboard (web tile set)  
     - Daily Brief Builder  
     - AdminCenter  
     - File Gateway (CopyParty or internal portal)  
   - In Edge/Chrome → **Install** as app (PWA).  
   - Pin to Start / Taskbar as needed.

3. **Productivity apps (offline‑first)** — if packaging as PWAs or Electron
   - BytePad, TasksPro, Contacts‑SQL, Projects‑SQL (use your latest builds/links).
   - Place installers/binaries under `C:\AeroVista\apps\productivity\` and add shortcuts.

4. **RydeSync‑Next + EchoVerse Player**
   - If these are web apps, install as PWA shortcuts.
   - If local helpers exist, place them in `C:\AeroVista\apps\sync\`.

5. **Telemetry/tools (optional)**
   - ByteSysScan (HW inventory script). Add a scheduled task to run weekly and drop JSON to `C:\AeroVista\logs\inventory\`.

---

## 3) Lock down & finalize

1. **Create a standard user** account (e.g., `av-user`) for daily operation.
2. **Disable admin elevation prompts** for standard user (leave UAC on; use admin creds when needed).
3. **Edge/Chrome**: sign out of personal profiles; ensure app mode shortcuts open with the right profile.
4. **Cleanup**: empty temp folders; `disk cleanup` → system files.
5. **Sysprep** (Generalize)
   ```powershell
   %WINDIR%\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /mode:vm
   ```
   - **Do not** auto‑launch user apps before Sysprep.
   - After shutdown, proceed to capture.

---

## 4) Capture the image

**Option A — Clonezilla** (simple & fast)
1. Boot Clonezilla USB.
2. Save disk to image on an external drive or network share.
3. Name: `AV_W11_YYYYMMDD_v1`.

**Option B — MDT (Microsoft Deployment Toolkit)** (more scalable)
1. Build an MDT share and import captured WIM or create a full task sequence.
2. Inject drivers, set post‑install tasks (copy `C:\AeroVista\…` content if not baked in).

**Option C — Intune Autopilot** (if you move to Azure AD)
1. Register hardware hashes.
2. Use WinGet packages and configuration profiles to push the payloads and PWAs.

---

## 5) Deploy to additional PCs

**Clonezilla restore**
1. Boot target PC with Clonezilla.
2. Restore the image.
3. At OOBE, create local standard user or connect to tailnet onboarding flow.
4. Verify:
   - Tailscale is logged in (or prompt ops to login once).
   - Staff Call is reachable at `https://<magicdns>/index.staff.html` or via local `http://localhost:8443`.
   - PWA shortcuts exist and open.

**Post‑deploy script (optional)**
- A small PowerShell script can:
  - Join Tailscale (`tailscale up --operator=<user>`),  
  - Re‑run `tailscale serve` mapping,  
  - Copy shortcuts into `C:\ProgramData\Microsoft\Windows\Start Menu\Programs`.

---

## 6) Maintenance & updates

- Keep a **changelog** in `C:\AeroVista\apps\VERSION.txt`.
- Monthly: update Node LTS, Edge/Chrome, Tailscale.
- Staff Call updates → replace folder and restart user session (the `.bat` handles deps).

---

## Appendix — PWA pinning via Edge (optional)

Export a JSON policy or use Edge Enterprise templates to silently install PWAs:
- `InstallIncludeList` for your tailnet URLs
- Grant mic permissions to the same origins

## 2. NXCore SSL Certificate Installation

# NXCore Certificate Installation for Existing PCs

This section covers installing the NXCore self-signed certificate on existing Windows 11 Pro systems that are already installed and updated with local admin accounts.

---

## 🎯 **Purpose**

Install the NXCore self-signed certificate on existing Windows 11 Pro systems to:
- ✅ **Eliminate browser security warnings** for all NXCore subdomains
- ✅ **Provide seamless HTTPS access** to monitoring and workspace services
- ✅ **Ensure professional user experience** for AeroVista staff
- ✅ **Reduce support tickets** related to certificate warnings

---

## 📋 **Prerequisites**

### **System Requirements**
- **Windows 11 Pro** (already installed and updated)
- **Local Admin Account** (already configured)
- **Network Access** to NXCore server (via Tailscale or direct connection)
- **PowerShell Execution Policy** (allow script execution if needed)

### **Required Files**
- **Certificate File**: `nxcore-self-signed.crt` (from NXCore server)
- **Installation Script**: `install-nxcore-cert.ps1` (automated installation)

### **Certificate Generation**
```bash
# On NXCore server (generate certificate)
ssh glyph@100.115.9.61
sudo mkdir -p /opt/nexus/traefik/certs
cd /opt/nexus/traefik/certs

sudo openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"

sudo chown root:root self-signed.*
sudo chmod 600 self-signed.key
sudo chmod 644 self-signed.crt
```

---

## 🛠️ **Installation Methods**

### **Method 1: Automated PowerShell Script (Recommended)**

Create `install-nxcore-cert.ps1`:

```powershell
# NXCore Certificate Installation Script for PC Imaging
param(
    [string]$CertPath = "nxcore-self-signed.crt",
    [switch]$Silent = $false
)

if (-not $Silent) {
    Write-Host "Installing NXCore Certificate for PC Imaging..." -ForegroundColor Green
}

try {
    # Import certificate to Trusted Root Certification Authorities
    Import-Certificate -FilePath $CertPath -CertStoreLocation "Cert:\LocalMachine\Root"
    
    if (-not $Silent) {
        Write-Host "✅ Certificate installed successfully!" -ForegroundColor Green
        
        # Verify installation
        $cert = Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
        if ($cert) {
            Write-Host "✅ Verification: Certificate found in store" -ForegroundColor Green
            Write-Host "   Subject: $($cert.Subject)" -ForegroundColor Cyan
            Write-Host "   Thumbprint: $($cert.Thumbprint)" -ForegroundColor Cyan
        }
    }
    
    # Test certificate validation
    $testResult = Test-NetConnection -ComputerName "grafana.nxcore.tail79107c.ts.net" -Port 443 -WarningAction SilentlyContinue
    if ($testResult.TcpTestSucceeded) {
        if (-not $Silent) {
            Write-Host "✅ Network connectivity to NXCore verified" -ForegroundColor Green
        }
    }
    
} catch {
    if (-not $Silent) {
        Write-Host "❌ Error installing certificate: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 1
}
```

### **Method 2: Manual Installation**

```powershell
# Manual certificate installation
certlm.msc
# Navigate to: Trusted Root Certification Authorities > Certificates
# Right-click > All Tasks > Import
# Select nxcore-self-signed.crt
# Place in: Trusted Root Certification Authorities
```

### **Method 3: Command Line**

```cmd
# Command line installation
certutil -addstore -user Root nxcore-self-signed.crt
```

---

## 📁 **File Organization for PC Setup**

### **Directory Structure**
```
C:\AeroVista-Setup\
├── certificates\
│   ├── nxcore-self-signed.crt
│   └── install-nxcore-cert.ps1
├── apps\
│   ├── tailscale-setup.exe
│   ├── rustdesk-desktop-pack.zip
│   └── [other AeroVista apps]
└── scripts\
    ├── Start-AeroCoreOS-StaffCall.bat
    └── post-setup-validation.ps1
```

### **Integration with PC Setup Process**

1. **Copy certificate files** to target PC
2. **Run installation script** on existing system
3. **Verify installation** and test connectivity
4. **Continue with other AeroVista setup tasks**

---

## 🔧 **Integration Steps**

### **Step 1: Prepare Certificate Files**

```powershell
# Create AeroVista setup directory
New-Item -ItemType Directory -Path "C:\AeroVista-Setup\certificates" -Force

# Copy certificate from NXCore server (if you have SSH access)
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt C:\AeroVista-Setup\certificates\nxcore-self-signed.crt

# Or download via web browser (after NXCore is accessible)
# Navigate to: https://nxcore.tail79107c.ts.net/certs/self-signed.crt
# Save to: C:\AeroVista-Setup\certificates\nxcore-self-signed.crt

# Copy installation script
Copy-Item "install-nxcore-cert.ps1" "C:\AeroVista-Setup\certificates\"
```

### **Step 2: Install on Existing PC**

```powershell
# Run on existing Windows 11 Pro system
Set-Location "C:\AeroVista-Setup\certificates"

# Check PowerShell execution policy
Get-ExecutionPolicy
# If needed: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run installation script
.\install-nxcore-cert.ps1

# Verify installation
Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
```

### **Step 3: Test Certificate Installation**

```powershell
# Test HTTPS connectivity to NXCore services
$services = @(
    "grafana.nxcore.tail79107c.ts.net",
    "prometheus.nxcore.tail79107c.ts.net",
    "status.nxcore.tail79107c.ts.net",
    "files.nxcore.tail79107c.ts.net"
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "https://$service/" -UseBasicParsing -TimeoutSec 10
        Write-Host "✅ $service : $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ $service : $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

---

## 🧪 **Validation Checklist**

### **Pre-Installation Validation**
- [ ] Certificate file downloaded from NXCore server
- [ ] Installation script tested on clean Windows system
- [ ] PowerShell execution policy allows script execution
- [ ] Network connectivity to NXCore server verified

### **Post-Installation Validation**
- [ ] Certificate appears in Trusted Root Certification Authorities
- [ ] HTTPS connectivity to NXCore subdomains works
- [ ] No browser security warnings on first visit
- [ ] Test browser access to NXCore services
- [ ] Document certificate thumbprint for reference

---

## 🔄 **Certificate Renewal Process**

### **Annual Renewal**
1. **Generate new certificate** on NXCore server (before expiration)
2. **Update setup assets** with new certificate
3. **Test new certificate** on existing system
4. **Deploy new certificate** to all existing workstations
5. **Update setup documentation** with new certificate

### **Automated Renewal Script**
```powershell
# Certificate renewal for existing PCs
param(
    [string]$NewCertPath = "nxcore-self-signed-new.crt"
)

Write-Host "Renewing NXCore Certificate..." -ForegroundColor Green

# Remove old certificate
$oldCert = Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
if ($oldCert) {
    Remove-Item -Path "Cert:\LocalMachine\Root\$($oldCert.Thumbprint)" -Force
    Write-Host "Removed old certificate: $($oldCert.Thumbprint)" -ForegroundColor Yellow
}

# Install new certificate
Import-Certificate -FilePath $NewCertPath -CertStoreLocation "Cert:\LocalMachine\Root"
Write-Host "Installed new certificate" -ForegroundColor Green

# Verify installation
$newCert = Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
if ($newCert) {
    Write-Host "Verification: New certificate installed successfully" -ForegroundColor Green
    Write-Host "Thumbprint: $($newCert.Thumbprint)" -ForegroundColor Cyan
}
```

---

## 📋 **PC Setup Workflow Integration**

### **Updated PC Setup Checklist (Existing Windows 11 Pro)**
- [ ] **System Ready**: Windows 11 Pro installed, updated, local admin account configured
- [ ] Install core networking: Tailscale, RustDesk, verify remote access
- [ ] Install AeroVista apps (see PC App List below)
- [ ] **Install NXCore SSL Certificate** (this section)
- [ ] Drop Staff Call bundle and wire autostart with `Start-AeroCoreOS-StaffCall.bat`
- [ ] Configure browsers, certificates, and CSP/Firewall rules per policy
- [ ] Validate system: network, Staff Call, RustDesk, Tailscale, **NXCore access**
- [ ] Document setup completion and certificate thumbprint

---

## 🔗 **Related Documentation**

- [Certificate Installation Guide](../docs%2010.14.25/CERTIFICATE_INSTALLATION_GUIDE.md)
- [SSL Certificate Strategy](../docs%2010.14.25/SSL_CERTIFICATE_STRATEGY.md)
- [NXCore Quick Reference](../docs%2010.14.25/QUICK_REFERENCE.md)

---

*This section ensures all existing AeroVista workstations are configured with NXCore certificate trust, providing seamless access to all infrastructure services.*

---

## 3. Drop‑and‑Go Staff Call Bundle

# AeroCoreOS — Staff Call (Drop‑and‑Go Bundle)

One‑click, room‑less voice for AeroVista staff, designed to run inside your **Tailscale** tailnet. No sign‑in, no accounts—everyone just opens the page and hits **Join**. This bundle is ready to unzip and run.

---

## ✨ Features
- **One‑click Staff Call** (mesh WebRTC via PeerJS; ideal for ~2–8 people)
- **Tailnet‑native**: use `tailscale serve https` or built‑in TLS with Tailscale certs
- **Zero login** (org prefix auto‑discovers peers)
- **Mic picker**, **Push‑to‑Talk (PTT)**, **Mute toggle**, **VU meter**, **participant count**
- **PWA**: installable as an app with icons and offline cache

---

## 📦 What’s Included
```
/ (bundle root)
├─ index.staff.html          # AeroCoreOS‑styled UI
├─ app.staff.js              # One‑click mesh call logic (org prefix, discovery, auto‑call)
├─ server.staff.js           # Static hosting + PeerJS signaling (allow_discovery:true)
├─ manifest.webmanifest      # PWA metadata
├─ sw.js                     # Service worker (caches local assets)
├─ icon-192.png
├─ icon-256.png
├─ icon-512.png
├─ apple-touch-icon.png
└─ Start-AeroCoreOS-StaffCall.bat   # Windows autostart script (optional)
```

**Requirements**
- Node.js LTS (18+ recommended)
- Tailscale installed & logged in on host and clients (for private tailnet use)
- Windows only (for `.bat` autostart). macOS/Linux can run `node server.staff.js` and use system services.

---

## 🚀 Quick Start (Tailnet)
> Works on Windows/macOS/Linux. The simplest path is **Tailscale Serve** (lets browsers use the mic via HTTPS).

```bash
# 1) Unzip this bundle on a Tailscale‑joined host
npm install
node server.staff.js              # serves http://localhost:8443

# 2) Map HTTPS via Tailscale (in another terminal)
tailscale serve https / http://127.0.0.1:8443
```

Open **https://<your-magicdns-name>/index.staff.html** from any AeroVista device on the tailnet → click **Join Staff Call**.

> **Tip:** `tailscale serve status` shows the current mapping. Use `tailscale serve --help` to remove or change it.

---

## 🪟 Windows Auto‑Start (Optional)
Use the included **Start-AeroCoreOS-StaffCall.bat** so the server starts at login and maps HTTPS automatically:

1. Place the **.bat** in the same folder as `server.staff.js` (this bundle’s root).  
2. Press **Win+R** → type `shell:startup` → Enter.  
3. Copy **Start-AeroCoreOS-StaffCall.bat** into that Startup folder.

The script will:
- create a log at `%LOCALAPPDATA%\AeroVista\StaffCall\logs\server_*.log`
- install deps if missing
- start the server minimized (skips if port is already listening)
- run `tailscale serve https / http://127.0.0.1:8443` if the Tailscale CLI is available

**Edit inside the .bat** if needed:
```
PORT=8443
USE_HTTPS=0          # 0 = use Tailscale Serve (recommended), 1 = built‑in TLS
KEY_PATH=            # set when USE_HTTPS=1
CERT_PATH=           # set when USE_HTTPS=1
```

---

## 🔐 Built‑In TLS (Alternative to Serve)
If you prefer the Node server to terminate TLS directly with Tailscale certs:

```bash
sudo tailscale cert <host.magicdns.ts.net>
USE_HTTPS=1 KEY_PATH=./<host>.key CERT_PATH=./<host>.crt node server.staff.js
```

Open **https://<host.magicdns.ts.net>/index.staff.html**.

---

## 🖥️ Using the App
- Click **Join Staff Call** to enter; you’ll auto‑call anyone else in the staff mesh.
- **Mute** toggles your mic; enable **PTT** to talk while holding **Spacebar**.
- Use the **Mic** dropdown to switch inputs (persists per device).
- Click **Install App** to add it as a PWA (Chrome/Edge/Brave).

---

## 🧩 How It Works
- Each client gets an ID like `av-staff-abc123` (no visible rooms).
- The server exposes `/peerjs` with `allow_discovery:true` so clients can list peers and auto‑call.
- On a Tailscale tailnet, peers usually connect via 100.x or DERP—no TURN required.

**Scaling note:** mesh is perfect for huddles (~2–8). For larger groups, we can swap in an SFU (LiveKit/Janus/mediasoup) later without changing the Join UX.

---

## 🛠️ Troubleshooting
- **No mic prompt** → Load via `https://<magicdns>` (or `http://localhost`)—browsers require a secure context.
- **No peers found** → Make sure you’re using *this* server’s `/peerjs` (not the public cloud) and Tailscale is connected.
- **Choppy audio / CPU high** → Close heavy apps; for big groups, move to an SFU.
- **Change port** → Edit `PORT` in `.bat` or run `PORT=9000 node server.staff.js`.
- **Reset Tailscale Serve** → `tailscale serve status` / `tailscale serve --help`.

---

## 📄 License / Notes
- Internal AeroVista tool. Keep any certs/keys private; do **not** commit them.
- Audio only (no recording). Add policies to your staff handbook as needed.


## 3. RustDesk Desktop Pack
Use the provided `av-rustdesk-desktop-pack.zip` to install and preconfigure RustDesk for AeroVista.
**Quick steps:**
1. Extract the ZIP to a working directory.
2. Run the included installer or place the portable binary as documented.
3. Apply the provided `rustdesk.cfg`/ID-Server settings (if included) to point at your tailnet/self-hosted rendezvous (if applicable).
4. Test: confirm you can remote into the workstation from a known-good admin device over Tailscale.

## 4. PC App List (Include in Image)

```
AeroVista PC Image — App Inclusion List (Draft)
================================================

Core (install/shortcut on every PC)
- AeroCoreOS Shell/Dashboard (PWA tile set; web-first)
- AeroCoreOS — Staff Call (one-click mesh voice; Tailscale tailnet)
- Daily Brief Builder (HTML/PWA)
- AdminCenter (internal admin console)
- File Gateway (internal file portal / CopyParty client shortcut)
- ByteSysScan (hardware + inventory scan/telemetry)

Productivity (offline-first apps; include where relevant)
- BytePad (notes)
- TasksPro (tasks/kanban)
- Contacts-SQL
- Projects-SQL

Comms & Sync
- RydeSync‑Next (group travel / ride / chat / music sync)
- RydeBeats‑Sync (music sync companion)
- EchoVerse Player (loops/audio content launcher)

Creative / R&D (optional per role)
- SkyForge — Ascension Awaits (prototype launcher)
- EchoVerse Tools (prompt pads, loop pack viewer)
- Synthetic Souls / SwampHop launchers (as available)

Ops / Reporting (optional per site)
- Daily/Weekly Ops Reports (HTML/PWA pages)
- CX Pulse Web Link (Power Apps/Power BI portal)
- NFL report dashboards (seasonal; optional)
- Borderlands Tips site link (optional personal-use)

Third‑Party Baseline (not AeroVista apps, but include in image)
- Tailscale (auto-login to tailnet)
- Node.js LTS
- Git + Git Credential Manager
- Visual Studio Code (extensions baseline)
- 7‑Zip
- VLC
- Edge/Chrome policies (PWA install allowed, mic permissions whitelisted for tailnet URL)
- (Optional) Docker Desktop if this workstation will run local services

Notes
- Favor PWA installs / Start Menu shortcuts for web apps (managed via Edge/Chrome).
- Centralize AeroVista payloads under C:\AeroVista\ (scripts, zips, logs, shortcuts).
```

## 5. Server Image (Ubuntu Desktop‑Server)

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


## 6. Assets & Scripts

- **Start‑AeroCoreOS‑StaffCall.bat** — Autostart script  
  [Download the .bat](sandbox:/mnt/data/Start-AeroCoreOS-StaffCall.bat)

- **AeroCoreOS Staff Call Bundle** — Branded drop‑and‑go set  
  [Download the bundle ZIP](sandbox:/mnt/data/aerocoreos-staff-call-branded.zip)

- **RustDesk Desktop Pack** — Prepped installer/configs for deployment  
  [Download the RustDesk pack](sandbox:/mnt/data/av-rustdesk-desktop-pack.zip)


## 7. Post‑Image Validation
- Networking: DHCP/static IP, DNS, internet reachability, Tailscale connected, RustDesk reachable.
- Security: AV/Defender configured, updates current, local firewall rules applied, admin/user roles correct.
- AeroVista Apps: Launch smoke test for each critical app; confirm logging/telemetry where applicable.
- Staff Call: Autostarts on login; UI loads; endpoints accessible; close/reopen behavior correct.
- Performance: Boot time, CPU/RAM idle, disk space; no error popups in Event Viewer / journalctl.


## 8. Troubleshooting Notes
- **SMB/RDP Changes After Updates**: Re‑check Windows Features (SMB1 disabled by default), firewall rules, and RDP settings.
- **Dell Firmware/BIOS Guard Prompts**: Safe to update on most workstations; for custom Linux servers, pin known‑good BIOS first, then update once validated.
- **Sysprep Failures**: Remove Store apps that block sysprep; clear pending updates; run `sysprep /generalize /oobe /shutdown` from admin cmd.
- **n8n Stack Start Issues**: Verify Compose versions, open ports, Traefik labels, and that DNS/TLS are valid. Check container logs.


## 9. Revision & Sources
- Generated: 2025-10-10 06:20:28
- Source files stitched:
  - `AV_PC_IMAGE.md`
  - `README-DropAndGo.md`
  - `aerovista-pc-app-list.txt`
  - `Server_Image.md`
- Bundled assets linked:
  - `Start-AeroCoreOS-StaffCall.bat`
  - `aerocoreos-staff-call-branded.zip`
  - `av-rustdesk-desktop-pack.zip`


---

## Appendix — Original Golden PC Image Notes

# AV_PC_IMAGE — Golden Windows Image for AeroVista Workstations

This playbook builds the **first golden image** and rolls it out to multiple AeroVista desktops. It assumes Windows 11 Pro and a small/medium environment using **Tailscale** instead of a domain.

---

## 0) Goals

- Consistent, locked‑down workstation with AeroVista tools preloaded
- One‑click **AeroCoreOS — Staff Call** on boot
- PWA shortcuts for web apps (AeroCoreOS, Daily Brief Builder, AdminCenter, etc.)
- Private networking via Tailscale; minimal public footprint
- Repeatable capture/deployment (Clonezilla/MDT/Autopilot alternatives documented)

---

## 1) Prepare the Reference Machine (“golden”)

1. **Install Windows 11 Pro** (latest ISO). Create a local admin: `av-admin`.
2. **Update**: Windows Update + OEM drivers.
3. **Security & baseline**
   - Enable **BitLocker** on system drive (TPM + PIN if desired).
   - Turn on **SmartScreen**; disable consumer experiences.
   - Set **Power**: High performance (no sleep for plugged‑in desktops).
   - Turn off hibernation: `powercfg -h off` (optional).
4. **Folders**
   - `C:\AeroVista\apps\` (zips, node services, scripts)
   - `C:\AeroVista\logs\`
   - `C:\AeroVista\shortcuts\`
5. **Install baseline software**
   - **Tailscale** (login to tailnet; enable MagicDNS)
   - **Node.js LTS** (x64)
   - **Git** + Git Credential Manager
   - **VS Code** (extensions: GitHub Copilot or preferred, ESLint, Prettier)
   - **7‑Zip**, **VLC**
   - (Optional) **Docker Desktop** (only for dev workstations)
6. **Browser policies** (Edge/Chrome)
   - Allow PWA install.
   - Microphone permissions → `https://<your-magicdns>` and `http://localhost` = **Allow**.
   - Auto-update enabled.

---

## 2) Install AeroVista payloads

> Keep everything under `C:\AeroVista\apps\...` for easy servicing.

1. **AeroCoreOS — Staff Call**
   - Extract `aerocoreos-staff-call-branded.zip` to `C:\AeroVista\apps\staff-call\`
   - Test: `node server.staff.js` → open `http://localhost:8443`  
   - Configure HTTPS (tailnet):  
     Open an elevated prompt and run:
     ```bat
     tailscale serve https / http://127.0.0.1:8443
     tailscale serve status
     ```
   - Auto‑start on login: copy **Start-AeroCoreOS-StaffCall.bat** to:
     `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` for each profile (or use Task Scheduler for all users).

2. **AeroCoreOS / Dashboards / PWA shortcuts**
   - Visit each app URL on the tailnet:  
     - AeroCoreOS Dashboard (web tile set)  
     - Daily Brief Builder  
     - AdminCenter  
     - File Gateway (CopyParty or internal portal)  
   - In Edge/Chrome → **Install** as app (PWA).  
   - Pin to Start / Taskbar as needed.

3. **Productivity apps (offline‑first)** — if packaging as PWAs or Electron
   - BytePad, TasksPro, Contacts‑SQL, Projects‑SQL (use your latest builds/links).
   - Place installers/binaries under `C:\AeroVista\apps\productivity\` and add shortcuts.

4. **RydeSync‑Next + EchoVerse Player**
   - If these are web apps, install as PWA shortcuts.
   - If local helpers exist, place them in `C:\AeroVista\apps\sync\`.

5. **Telemetry/tools (optional)**
   - ByteSysScan (HW inventory script). Add a scheduled task to run weekly and drop JSON to `C:\AeroVista\logs\inventory\`.

---

## 3) Lock down & finalize

1. **Create a standard user** account (e.g., `av-user`) for daily operation.
2. **Disable admin elevation prompts** for standard user (leave UAC on; use admin creds when needed).
3. **Edge/Chrome**: sign out of personal profiles; ensure app mode shortcuts open with the right profile.
4. **Cleanup**: empty temp folders; `disk cleanup` → system files.
5. **Sysprep** (Generalize)
   ```powershell
   %WINDIR%\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /mode:vm
   ```
   - **Do not** auto‑launch user apps before Sysprep.
   - After shutdown, proceed to capture.

---

## 4) Capture the image

**Option A — Clonezilla** (simple & fast)
1. Boot Clonezilla USB.
2. Save disk to image on an external drive or network share.
3. Name: `AV_W11_YYYYMMDD_v1`.

**Option B — MDT (Microsoft Deployment Toolkit)** (more scalable)
1. Build an MDT share and import captured WIM or create a full task sequence.
2. Inject drivers, set post‑install tasks (copy `C:\AeroVista\…` content if not baked in).

**Option C — Intune Autopilot** (if you move to Azure AD)
1. Register hardware hashes.
2. Use WinGet packages and configuration profiles to push the payloads and PWAs.

---

## 5) Deploy to additional PCs

**Clonezilla restore**
1. Boot target PC with Clonezilla.
2. Restore the image.
3. At OOBE, create local standard user or connect to tailnet onboarding flow.
4. Verify:
   - Tailscale is logged in (or prompt ops to login once).
   - Staff Call is reachable at `https://<magicdns>/index.staff.html` or via local `http://localhost:8443`.
   - PWA shortcuts exist and open.

**Post‑deploy script (optional)**
- A small PowerShell script can:
  - Join Tailscale (`tailscale up --operator=<user>`),  
  - Re‑run `tailscale serve` mapping,  
  - Copy shortcuts into `C:\ProgramData\Microsoft\Windows\Start Menu\Programs`.

---

## 6) Maintenance & updates

- Keep a **changelog** in `C:\AeroVista\apps\VERSION.txt`.
- Monthly: update Node LTS, Edge/Chrome, Tailscale.
- Staff Call updates → replace folder and restart user session (the `.bat` handles deps).

---

## Appendix — PWA pinning via Edge (optional)

Export a JSON policy or use Edge Enterprise templates to silently install PWAs:
- `InstallIncludeList` for your tailnet URLs
- Grant mic permissions to the same origins


## Appendix — Skip Microsoft Account (MSA) on Windows 11 OOBE (Local Account Path)

> Works on Windows 11 22H2/23H2/24H2. Use when you want **local accounts** on golden images.

**Method A — Bypass with `OOBE\BYPASSNRO` (most reliable)**
1) At the “Let’s connect you to a network” or Microsoft sign-in screen, press **Shift+F10** to open Command Prompt.  
2) Run: `OOBE\BYPASSNRO` and press **Enter**. The PC will reboot.  
3) After reboot, you’ll see **“I don’t have internet”** → click it → **Continue with limited setup**.  
4) You’ll be prompted to create a **local account** (e.g., `av-admin`).

**Method B — Physically/Logically disconnect network**
- Unplug Ethernet; on Wi‑Fi page choose **I don’t have internet** (or disable Wi‑Fi via airplane key).  
- If stuck, press **Shift+F10** → run `ipconfig /release` (wired) or `netsh wlan disconnect` (wireless), then go back a screen.

**Notes**
- Post‑OOBE, you can still join **Tailscale** and any org services.  
- For imaging labs, keep a **USB NIC switch** handy to kill network during OOBE quickly.
