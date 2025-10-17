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