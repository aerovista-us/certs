# NXCore-Control (Windows Operator Pack)

This pack lets you manage **NXCore** (192.168.7.209/22) from a Windows workstation using
built-in OpenSSH + PowerShell, with optional automation via **Cursor** (.cursorrules).

## Quick Start
1. Unzip anywhere (e.g., `C:\NXCore-Control`).
2. Open **PowerShell** as admin and run:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   .\scripts\ps\sync-config.ps1
   ```
3. SSH in fast:
   ```bat
   scripts\ssh-nxcore.bat
   ```

## Layout
- `.cursorrules` → Cursor agent instructions & tool-usage policy.
- `scripts\` → Handy `ssh` / `scp` wrappers. PowerShell deploy/sync jobs in `scripts\ps`.
- `docker\` → Example docker-compose files for core services (n8n, FileBrowser).
- `agent\` → Agent rules + systemd unit for a simple file-watcher "cursor-agent".
- `ai\` → Local AI bootstrap (Ollama + lightweight API skeleton).
- `configs\` → Example UFW and Tailscale ACL templates.
- `utils\windows\` → Optional setup helpers for your Windows box (OpenSSH, winget, path checks).
- `inventory\hosts.ini` → Future-proofing for Ansible/WinRM/WSL.

> Host: **nxcore**  |  IPv4: **192.168.7.209**  |  CIDR: **/22**

---
**AeroVista LLC** • Command node: **NXCore**
