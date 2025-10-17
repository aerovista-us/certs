# AeroVista Workspaces (Browser-First)

Goal: a teammate can forget their laptop and still get 90% of work done from a browser.

## What’s included

- **Webtop (XFCE desktop in browser)** — run classic GUI apps like **GIMP**, **Inkscape**, **Audacity**, etc.
- **code-server** — VS Code in the browser, great for Node/Python work.
- **JupyterLab** — notebooks/data science.
- **OnlyOffice DocumentServer** — Docs/Sheets/Slides in the browser.
- **draw.io** + **Excalidraw** — diagrams and whiteboarding.
- **BytePad** (stub) — drop your web build into `apps/bytepad/`.
- **AudioMass** (stub) — drop the static AudioMass bundle into `apps/audiomass/`.

All services come with Traefik label stubs and use `%PRIVATE_HOST%` / `%PUBLIC_HOST%` placeholders.

## Quick start

```bash
# Requires: Traefik running on network "traefik_proxy"
# Create network if not already present
docker network create traefik_proxy || true

# Bring up web desktop + code + notebooks
docker compose -f compose.workspaces.yml up -d webtop-user1 code-user1 jupyterlab
```

## Hostnames (edit to match your env)

- Webtop: `https://ws1.%PRIVATE_HOST%`
- VS Code: `https://code1.%PRIVATE_HOST%`
- Jupyter: `https://nb.%PRIVATE_HOST%`
- OnlyOffice: `https://office.%PUBLIC_HOST%`
- draw.io: `https://draw.%PUBLIC_HOST%`
- Excalidraw: `https://x.%PUBLIC_HOST%`
- BytePad: `https://bytepad.%PRIVATE_HOST%`
- AudioMass: `https://audio.%PRIVATE_HOST%`

## Storage

- Per-user home (webtop/code): `ws-user1-home` volume
- Shared workspace: `ws-shared` volume

Mount additional project folders as needed.

## Installing desktop apps inside Webtop

Open Webtop → terminal:
```bash
sudo apt update
sudo apt install -y gimp inkscape audacity ffmpeg
```
(You can bake these into a derived image later.)

## Audio / mic notes

- Webtop supports playback in browser; live mic capture **inside** VNC-based desktops is limited.
- For simple trims and fades without recording, use **AudioMass** (in-browser, no install).
- For real recording: prefer local DAW or a small native capture tool, then upload for edits.

## Security

- Put all services behind **Authelia** (SSO/MFA) or keep them private-only via Tailscale certs.
- Create a copy of `webtop-user1` and `code-user1` per user, each with separate volumes.

## Integrate with Landing Page

Add these entries to your landing page config:
- Webtop, Code, Jupyter, OnlyOffice, draw.io, Excalidraw, BytePad, AudioMass
and set the base hosts via **Configure URLs**.
