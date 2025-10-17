# Collaborator PC — Start-to-Finish Task List (Windows 11 Pro)
_Generated: 2025-10-12_

This checklist is for preparing a **Collaborator** workstation that joins the AeroVista ecosystem (tailnet access, core tools, PWAs, and sane security defaults).

---

## Phase 0 — Hardware & Firmware Prep
- [ ] Record model/serial; asset tag applied
- [ ] BIOS/UEFI updated; **TPM 2.0** enabled; **Secure Boot** on (unless a tool needs it off)
- [ ] Disable **Fast Boot**; enable virtualization (VT-x/AMD-V)
- [ ] Update storage/firmware utilities; baseline health (SMART)

---

## Phase 1 — Windows 11 Install & OOBE
- [ ] Fresh install **Windows 11 Pro** (latest ISO)  
- [ ] **Skip Microsoft account** (local admin) using `Shift+F10` → `OOBE\BYPASSNRO` → “I don’t have internet” → “Continue with limited setup”
- [ ] Create local admin: **av-admin** (temp) with strong password
- [ ] Set PC name standard: **AV-COLLAB-<name>**

---

## Phase 2 — Updates, Drivers, and Policies
- [ ] Run **Windows Update** until clear (quality + optional drivers if needed)
- [ ] Install OEM chipset/GPU/Wi-Fi/Bluetooth drivers as needed
- [ ] Power plan: **Balanced** (laptop) or **High performance** (desktop)
- [ ] Disable sleep for plugged-in (to avoid missed syncs/calls)

---

## Phase 3 — Core Access & Identity
- [ ] Install **Tailscale** → sign in to tailnet; verify MagicDNS & device appears
- [ ] (Optional) Tag device in admin as `tag:collaborator`
- [ ] Configure device name in Tailscale as **av-collab-<name>**
- [ ] **Install NXCore SSL Certificate** (see Certificate Installation section below)
- [ ] Test tailnet access to `files.<domain>` / CopyParty and internal UIs

---

## Phase 4 — Security Baseline
- [ ] **BitLocker** on (save recovery key to org vault)  
- [ ] **Windows Defender** active; reputation-based protection on
- [ ] Enable **Firewall** (default) + allowlist for needed apps only
- [ ] Disable **RDP** (unless explicitly required)  
- [ ] Create standard user **av-user**; keep **av-admin** for elevation
- [ ] Screensaver/lock: 10–15 min

---

## Phase 5 — Foundation Apps
- [ ] Browsers: Edge (PWA host) + Chrome (optional)
- [ ] **7-Zip**, **VLC**
- [ ] **Git** + **VS Code** (include extensions: Docker, Prettier)
- [ ] **Node.js** via **nvm-windows** → set **22.19.0** default
- [ ] **Docker Desktop** (optional for dev collaborators)
- [ ] **RustDesk** client (if adopting), pre-config for tailnet server (optional)

---

## Phase 6 — AeroVista Apps & Shortcuts
- [ ] Pin PWAs: **Daily Brief Builder**, **AeroVista AdminCenter**, **File Gateway**, **AeroCoreOS Dashboard**
- [ ] Create desktop/taskbar shortcuts (organization folder: `C:\AeroVista\Shortcuts`)
- [ ] Verify access to internal services (n8n UI, Portainer read-only if applicable)

---

## Phase 7 — Collaboration & Content
- [ ] Configure **VS Code Settings Sync** (if desired)
- [ ] Install communication tools (as needed): Teams/Slack/Zoom (org standards)
- [ ] Map helpful tailnet bookmarks (browser favorites bar)
- [ ] Confirm audio/video devices (mic/cam) for **Staff Call** sessions

---

## Phase 8 — Staff Call Ready
- [ ] Open **index.staff.html** endpoint (served from server) over tailnet
- [ ] Confirm mic permissions prompt appears
- [ ] Join test room; verify audio in/out with another tailnet peer

---

## Phase 9 — Ops Hygiene
- [ ] Create `C:\AeroVista\apps\VERSION.txt` (tool versions) and log date
- [ ] Enable **Windows Restore Point** and create baseline snapshot
- [ ] Export a **Device Handover Sheet** (specs, keys location, contacts)
- [ ] Add device to **asset register**

---

## Phase 10 — Final Review & Sign‑off
- [ ] Non-admin day-to-day account verified (av-user)
- [ ] Admin password vaulted; BitLocker key vaulted
- [ ] All PWAs launch; tailnet resources reachable
- [ ] Print/sign digital sign-off; deliver to collaborator

---

## Quick Next Actions
1) Run Windows Update + drivers to green status.  
2) Join Tailscale + verify MagicDNS.  
3) Turn on BitLocker and vault the recovery key.  
4) Install core apps (VS Code, Git, 7-Zip, VLC, nvm/Node 22.19.0).  
5) Pin the PWAs and perform a Staff Call smoke test.

---

## Notes
- Use local admin at OOBE; convert to standard **av-user** for daily ops.  
- Keep **av-admin** for elevation only.  
- If collaborator needs dev tools, include Docker Desktop; else omit to reduce noise.

---

## NXCore SSL Certificate Installation

### **Purpose**
Install the NXCore self-signed certificate to enable seamless HTTPS access to all NXCore services without browser security warnings.

### **Installation Steps**

1. **Download Certificate**
   ```powershell
   # Download from NXCore server
   scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./
   ```

2. **Install Certificate**
   ```powershell
   # Method 1: PowerShell (Recommended)
   Import-Certificate -FilePath "self-signed.crt" -CertStoreLocation "Cert:\LocalMachine\Root"
   
   # Method 2: Command Line
   certutil -addstore -user Root self-signed.crt
   
   # Method 3: GUI
   certlm.msc
   # Navigate to: Trusted Root Certification Authorities > Certificates
   # Right-click > All Tasks > Import > Select self-signed.crt
   ```

3. **Verify Installation**
   ```powershell
   # Check certificate is installed
   Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
   
   # Test HTTPS access
   Test-NetConnection -ComputerName "grafana.nxcore.tail79107c.ts.net" -Port 443
   ```

4. **Test Browser Access**
   - Open browser and navigate to `https://grafana.nxcore.tail79107c.ts.net/`
   - Verify no security warnings appear
   - Test other NXCore subdomains

### **Benefits**
- ✅ No browser security warnings for NXCore services
- ✅ Seamless HTTPS access to monitoring dashboards
- ✅ Professional user experience from first use
- ✅ Access to all Phase B workspace services

---

**Owner:** Glyph · **Status Key:** ☑ Done · ☐ Not done · ◐ In progress
