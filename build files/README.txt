Tailnet Single-Host Traefik Bundle
==================================

Serve everything under:
  https://nxcore.tail79107c.ts.net/<app>

Includes routes:
  /traefik, /portainer, /grafana, /prometheus, /files, /auth, /status, /aerocaller

Deploy
------
1) Copy files to Traefik dynamic dir on the host:
   /opt/nexus/traefik/dynamic/tailscale-certs.yml
   /opt/nexus/traefik/dynamic/tailnet-routes.yml

2) Ensure Traefik mounts:
   - /etc/ssl/tailscale:/etc/ssl/tailscale:ro
   - /opt/nexus/traefik/dynamic:/traefik/dynamic:ro

3) Cert already created:
   /etc/ssl/tailscale/nxcore.tail79107c.ts.net.crt
   /etc/ssl/tailscale/nxcore.tail79107c.ts.net.key

4) Remove any tls.certresolver on these tailnet routers (not needed).

5) Hot reload:
   docker kill -s HUP traefik  # or just watch logs; file provider reloads automatically

App base URLs
-------------
- Grafana: set GF_SERVER_ROOT_URL=https://nxcore.tail79107c.ts.net/grafana/
- Prometheus: optional --web.external-url

Optional tailnet-only entrypoint
--------------------------------
- Bind a dedicated entrypoint to tailscale0 IP if you want to keep these off 0.0.0.0:443.

