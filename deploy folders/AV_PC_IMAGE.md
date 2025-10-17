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