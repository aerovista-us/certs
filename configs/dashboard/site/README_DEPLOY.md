# Daily Brief Builder — Deployment (NXCore + Traefik)

This package includes:
- `site/` — static assets (HTML/CSS/JS) + `docs/postgresql_sop.md`.
- A sample Docker service that publishes the site at `/brief/` via Traefik, using your existing TLS.

## 1) Copy files to server
```bash
sudo mkdir -p /srv/brief
sudo rsync -av site/ /srv/brief/
```

## 2) Add a service to your compose
In `/srv/core/compose.yml` (or a dedicated compose), add:

```yaml
services:
  brief:
    image: nginx:stable-alpine
    container_name: brief
    restart: unless-stopped
    networks:
      - gateway
    volumes:
      - /srv/brief:/usr/share/nginx/html:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.brief.rule=PathPrefix(`/brief`)"
      - "traefik.http.routers.brief.entrypoints=websecure"
      - "traefik.http.routers.brief.tls=true"
      - "traefik.http.services.brief.loadbalancer.server.port=80"
      - "traefik.docker.network=gateway"
```

> If you are using path-based routing behind a single tailnet hostname (e.g., `nxcore.tail79107c.ts.net`), visiting `https://nxcore.tailXYZ.ts.net/brief/` will load the page.

## 3) Apply
```bash
cd /srv/core
sudo docker compose up -d brief
```

## 4) Optional: Add internal doc routes
You can serve docs at `/docs/` by mounting additional static files and adding labels (or simply link to files within `/brief/`).

## 5) Maintenance
- Update content by syncing to `/srv/brief/`
- No container restart is needed for static file changes

---

### Notes
- The PostgreSQL SOP is plain Markdown. The page currently renders it as plain text for simplicity. Later you can add a client-side renderer.
- Update the "Infra Shortcuts" paths to match your environment.
