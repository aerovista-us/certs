\# Private Split-DNS via Tailscale with Traefik + Porkbun (Internal-Only)



\*End-to-end guide for keeping services private on your tailnet while using first-class HTTPS.\*



> \*\*Goal\*\*

> Serve internal apps at friendly hostnames like `grafana.aerovista.us`, `files.aerovista.us`, etc., \*\*only inside Tailscale\*\*.

> TLS certs are automated via \*\*ACME DNS-01 (Porkbun)\*\*, so there’s no port-80/443 exposure to the public internet.

> DNS resolution is handled privately via \*\*Tailscale Split-DNS\*\* → your own resolver.



---



\## 0) At a glance



\* \*\*Transport / identity\*\*: Tailscale (MagicDNS + ACLs).

\* \*\*DNS\*\*: Your own resolver (Unbound or CoreDNS) authoritative for `aerovista.us` (internal view), advertised via Tailscale \*\*Split-DNS\*\*.

\* \*\*Ingress\*\*: Traefik on NXCore (Docker).

\* \*\*Certificates\*\*: Traefik ACME \*\*DNS-01\*\* using \*\*Porkbun\*\* API (\*\*auto-issue/renew\*\*, supports wildcards).

\* \*\*Exposure\*\*: Private only (bind Traefik to Tailscale/lan IP and/or firewall public).

\* \*\*Future\*\* (optional): Make selected hosts public later by adding public DNS \& firewall rules—no re-architecture needed.



---



\## 1) Prerequisites



\* \*\*Tailscale\*\* running on all client devices + NXCore, \*\*MagicDNS enabled\*\*.

\* Admin access to \*\*Porkbun\*\* DNS (domain: `aerovista.us`).

\* NXCore on Ubuntu 22.04/24.04 (or similar) with Docker installed.

\* Traefik container planned on NXCore.

\* (Optional) A working `docker-compose.yml` for your apps (Grafana, Prometheus, etc.).



---



\## 2) Decide your internal names



Pick the subdomains you want reachable inside the tailnet:



```

grafana.aerovista.us

prometheus.aerovista.us

status.aerovista.us

files.aerovista.us

auth.aerovista.us

traefik.aerovista.us

```



> Tip: Keep a short list now; you can add more later with one DNS record + one router.



---



\## 3) Install a private DNS resolver on NXCore



\### Option A: \*\*Unbound\*\* (simple, recommended)



```bash

sudo apt update

sudo apt install -y unbound

```



Create the main config:



```bash

sudo tee /etc/unbound/unbound.conf.d/nxcore.conf >/dev/null <<'EOF'

server:

&nbsp; interface: 0.0.0.0

&nbsp; do-ip6: yes

&nbsp; prefetch: yes

&nbsp; access-control: 100.64.0.0/10 allow   # Tailscale range

&nbsp; access-control: 10.0.0.0/8 allow      # adjust for your LANs as needed

&nbsp; access-control: 192.168.0.0/16 allow



\# Default recursion for everything (public)

forward-zone:

&nbsp; name: "."

&nbsp; forward-addr: 1.1.1.1

&nbsp; forward-addr: 8.8.8.8

EOF



sudo systemctl enable --now unbound

```



Create an \*\*authoritative\*\* local zone for your internal view of `aerovista.us`:



```bash

TS\_IP="<your\_server\_tailscale\_ip>"  # e.g., 100.101.102.103

sudo tee /etc/unbound/unbound.conf.d/zone-aerovista.conf >/dev/null <<EOF

server:

&nbsp; local-zone: "aerovista.us." static

&nbsp; # Authoritative answers for selected hosts (internal subdomains):

&nbsp; local-data: "grafana.aerovista.us. A ${TS\_IP}"

&nbsp; local-data: "prometheus.aerovista.us. A ${TS\_IP}"

&nbsp; local-data: "status.aerovista.us. A ${TS\_IP}"

&nbsp; local-data: "files.aerovista.us. A ${TS\_IP}"

&nbsp; local-data: "auth.aerovista.us. A ${TS\_IP}"

&nbsp; local-data: "traefik.aerovista.us. A ${TS\_IP}"

EOF



sudo systemctl restart unbound

```



> You are \*\*not\*\* changing public DNS at Porkbun for these names. This is an \*\*internal\*\* authoritative view only.



\### (Alternative) CoreDNS (if you prefer)



CoreDNS works great too, but Unbound is fine for most setups. Skip unless you have a reason.



---



\## 4) Tell Tailscale to use your resolver for this domain (Split-DNS)



\* Open \*\*Tailscale Admin → DNS\*\*.

\* \*\*Keep MagicDNS enabled\*\*.

\* Under \*\*Split DNS\*\*, \*\*Add domain\*\* → `aerovista.us`.

\* \*\*Nameserver\*\* → `NXCore\_IP:53` (use the NXCore \*\*Tailscale IP\*\*, e.g., `100.101.102.103`).

\* Save. Reconnect clients.



\*\*Verify from a client (Windows PowerShell):\*\*



```powershell

nslookup grafana.aerovista.us

nslookup files.aerovista.us

```



You should see answers returning the NXCore \*\*Tailscale IP\*\* you set in Unbound.



---



\## 5) Secure Traefik’s bind / firewall (private only)



Make sure Traefik isn’t exposed to the public internet:



\* \*\*Easiest\*\*: Bind Traefik’s entrypoint to the Tailscale IP only.

&nbsp; Example static flag: `--entrypoints.websecure.address=100.101.102.103:443`



\* Or keep `:443` and \*\*UFW\*\* to allow only tailnet/LAN:



&nbsp; ```bash

&nbsp; sudo ufw default deny incoming

&nbsp; sudo ufw allow from 100.64.0.0/10 to any port 443 proto tcp

&nbsp; # (Add local LAN ranges if needed)

&nbsp; sudo ufw enable

&nbsp; ```



---



\## 6) Traefik with ACME DNS-01 (Porkbun)



Create directory layout:



```bash

sudo mkdir -p /srv/traefik /srv/traefik/certs

sudo touch /srv/traefik/acme.json

sudo chmod 600 /srv/traefik/acme.json

```



\*\*`traefik.yml` (static config):\*\*



```yaml

entryPoints:

&nbsp; websecure:

&nbsp;   address: "100.101.102.103:443"   # or ":443" + firewall, see step 5



providers:

&nbsp; docker: {}

&nbsp; file:

&nbsp;   directory: /etc/traefik

&nbsp;   watch: true



certificatesResolvers:

&nbsp; le-dns:

&nbsp;   acme:

&nbsp;     email: ops@aerovista.us

&nbsp;     storage: /etc/traefik/acme.json

&nbsp;     dnsChallenge:

&nbsp;       provider: porkbun

&nbsp;       delayBeforeCheck: 20

```



\*\*`docker-compose.yml` (Traefik + sample Grafana):\*\*



```yaml

version: "3.9"



networks:

&nbsp; web:

&nbsp;   external: false



services:

&nbsp; traefik:

&nbsp;   image: traefik:latest

&nbsp;   command:

&nbsp;     - --configFile=/etc/traefik/traefik.yml

&nbsp;   ports:

&nbsp;     - "443:443"

&nbsp;     # - "8080:8080"   # dashboard (bind to localhost or protect w/ auth)

&nbsp;   environment:

&nbsp;     - PORKBUN\_API\_KEY=${PORKBUN\_API\_KEY}

&nbsp;     - PORKBUN\_SECRET\_API\_KEY=${PORKBUN\_SECRET\_API\_KEY}

&nbsp;   volumes:

&nbsp;     - /var/run/docker.sock:/var/run/docker.sock:ro

&nbsp;     - /srv/traefik/traefik.yml:/etc/traefik/traefik.yml:ro

&nbsp;     - /srv/traefik:/etc/traefik

&nbsp;   networks: \[web]

&nbsp;   restart: unless-stopped



&nbsp; grafana:

&nbsp;   image: grafana/grafana:latest

&nbsp;   networks: \[web]

&nbsp;   labels:

&nbsp;     - "traefik.enable=true"

&nbsp;     - "traefik.http.routers.grafana.rule=Host(`grafana.aerovista.us`)"

&nbsp;     - "traefik.http.routers.grafana.entrypoints=websecure"

&nbsp;     - "traefik.http.routers.grafana.tls.certresolver=le-dns"

&nbsp;     - "traefik.http.services.grafana.loadbalancer.server.port=3000"

&nbsp;   restart: unless-stopped

```



Create a `.env` next to the compose with your Porkbun API creds:



```

PORKBUN\_API\_KEY=pb\_XXXXXXXXXXXXXXXXXXXXXXXX

PORKBUN\_SECRET\_API\_KEY=pb\_sec\_XXXXXXXXXXXXXXXXXXXXXXXX

```



Bring it up:



```bash

cd /srv/traefik

docker compose up -d

```



> Traefik will solve ACME via \*\*DNS-01\*\* (no public ports) and obtain certs for `grafana.aerovista.us`.

> Add more services by repeating the labels, changing only the hostname and internal port.



---



\## 7) Verify end-to-end



From a tailnet client:



```powershell

\# DNS (Split-DNS through Tailscale → Unbound)

nslookup grafana.aerovista.us



\# HTTPS (should be 200/302; first hit may take a few seconds while ACME runs)

curl.exe -I https://grafana.aerovista.us



\# Inspect served cert

openssl s\_client -connect grafana.aerovista.us:443 -servername grafana.aerovista.us | openssl x509 -noout -subject -issuer -dates

```



If you see a valid issuer (Let’s Encrypt) and correct dates, you’re done.



---



\## 8) Add the rest of your services



Duplicate the service block (or labels) per app:



```yaml

\# Prometheus

\- "traefik.http.routers.prom.rule=Host(`prometheus.aerovista.us`)"

\- "traefik.http.routers.prom.entrypoints=websecure"

\- "traefik.http.routers.prom.tls.certresolver=le-dns"

\- "traefik.http.services.prom.loadbalancer.server.port=9090"



\# Uptime Kuma

\- "traefik.http.routers.status.rule=Host(`status.aerovista.us`)"

\- "traefik.http.routers.status.entrypoints=websecure"

\- "traefik.http.routers.status.tls.certresolver=le-dns"

\- "traefik.http.services.status.loadbalancer.server.port=3001"



\# FileBrowser

\- "traefik.http.routers.files.rule=Host(`files.aerovista.us`)"

\- "traefik.http.routers.files.entrypoints=websecure"

\- "traefik.http.routers.files.tls.certresolver=le-dns"

\- "traefik.http.services.files.loadbalancer.server.port=8080"



\# Authelia

\- "traefik.http.routers.auth.rule=Host(`auth.aerovista.us`)"

\- "traefik.http.routers.auth.entrypoints=websecure"

\- "traefik.http.routers.auth.tls.certresolver=le-dns"

\- "traefik.http.services.auth.loadbalancer.server.port=9091"



\# Traefik dashboard (protect this!)

\- "traefik.http.routers.traefik.rule=Host(`traefik.aerovista.us`)"

\- "traefik.http.routers.traefik.entrypoints=websecure"

\- "traefik.http.routers.traefik.tls.certresolver=le-dns"

\- "traefik.http.routers.traefik.service=api@internal"

```



> \*\*Protect admin routes\*\* (Authelia/OIDC/basic-auth middleware) and/or bind dashboard to localhost and use SSH/Tailscale port-forward for access.



---



\## 9) Operational notes



\* \*\*Renewals\*\*: Automatic via Traefik/ACME DNS-01. No cron required.

\* \*\*Adding hosts\*\*: Add an A record in Unbound’s zone (to the TS IP) + add a Traefik router with the new host.

\* \*\*Telemetry\*\*: Ship Traefik logs to Loki/ELK; alert on 5xx spikes and ACME failures.

\* \*\*Backups\*\*: Back up `/srv/traefik/acme.json` and your compose files.

\* \*\*Firewall\*\*: Keep 443 reachable only from tailnet/LAN.

\* \*\*Tailscale ACLs\*\*: Lock down who can reach NXCore’s TS IP on 443.



---



\## 10) Troubleshooting quick hits



| Symptom                          | Likely cause                                        | Fix                                                                                           |

| -------------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------- |

| `nslookup` fails                 | Split-DNS not configured, or resolver not reachable | Add Split-DNS for `aerovista.us` to NXCore TS IP; check Unbound is running and allowed ranges |

| 404 at `https://host`            | Router rule mismatch                                | Check `Host(...)` exactly; watch `docker logs traefik`                                        |

| 502/Bad Gateway                  | Wrong internal port or service network              | Verify app port; put app and Traefik on the \*\*same Docker network\*\*                           |

| TLS cert never appears           | ACME DNS-01 failed                                  | Check Porkbun API keys; add `delayBeforeCheck`; inspect Traefik logs for ACME                 |

| Browser warns “insecure”         | Hitting via IP or wrong host                        | Always use the \*\*hostname\*\* that matches the router; verify cert with `openssl s\_client`      |

| Works on one device, not another | Device not on tailnet or stale DNS                  | Reconnect Tailscale on the device; `ipconfig /flushdns` on Windows                            |



---



\## 11) (Optional later) Make a page public



When you want, e.g., `status.aerovista.us` public:



1\. Create \*\*public DNS\*\* at Porkbun (A/AAAA) pointing to a public IP that reaches Traefik (or use a public proxy).

2\. Open/forward firewall/ingress appropriately.

3\. Keep the same Traefik router labels (already do TLS via DNS-01).

4\. Consider \*\*rate-limits\*\*, \*\*WAF\*\*, and \*\*HSTS\*\* for public endpoints.



> Public vs private can be decided \*\*per host\*\* without changing the internal design.



---



\## 12) Appendix: Unbound zone edits



Add or change records in `/etc/unbound/unbound.conf.d/zone-aerovista.conf`:



```bash

\# Add a new internal host

echo '  local-data: "admin.aerovista.us. A 100.101.102.103"' | sudo tee -a /etc/unbound/unbound.conf.d/zone-aerovista.conf

sudo systemctl restart unbound

```



---



\### You’re set



You now have private, friendly URLs with real HTTPS—no internet exposure—scaling cleanly as you add services. When you’re ready to publish a subset, you can do it host-by-host with minimal changes.



