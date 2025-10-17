# AeroCaller Coturn Pack (Tailnet-Only)

This pack installs **coturn** on your Tailscale host to provide STUN/TURN for WebRTC.
Choose **Docker** or **native** install. Defaults target host **nxcore** and realm **nxcore.tail**—edit as needed.

## Contents
- `.env` – Edit host/realm/creds and port range.
- `docker-compose.yml` – Host-networked coturn.
- `install_coturn_docker.sh` – One-command Docker deployment.
- `install_coturn_native.sh` – Ubuntu/Debian native service.
- `verify_turn.sh` – Quick allocation test.
- `generate_turn_cred.js` – Helper for `use-auth-secret` creds.
- `client_snippets.md` – WebRTC ICE config examples.

## Quick Start (Docker)
```bash
cp .env.example .env   # if this file is named .env.example in your environment
# (Here it's already named .env — just edit it)
# Edit TURN_HOST/REALM/creds in .env
sudo bash install_coturn_docker.sh
```

## Quick Start (Native Ubuntu/Debian)
```bash
sudo bash install_coturn_native.sh
```

## Ports (open on the coturn host, tailnet-only is fine)
- UDP/TCP 3478 (STUN/TURN)
- UDP 49160–49200 (relay port range)
- Optional: TCP 5349 (TURN over TLS)

## Client config (WebRTC)
Use `client_snippets.md`. Typical block:
```js
const iceServers = [
  { urls: "stun:nxcore:3478" },
  { urls: "turn:nxcore:3478?transport=udp", username: "auser", credential: "apass" },
];
```

## Notes
- Prefer **host network** for Docker to avoid UDP issues.
- Do **not** put coturn behind Traefik/NGINX.
- For multi-user or public settings, switch to `use-auth-secret` and generate time-limited credentials.
- Keep relay port range tight to limit attack surface.
- Tailscale ACLs can further restrict access to your tailnet only.
