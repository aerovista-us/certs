# AeroVista Internal CA Pack

This bundle gives you a **self‑hosted PKI** for internal HTTPS on AeroVista devices:
- Public site `aerovista.us` remains on Firebase with public certs.
- Internal services (Tailscale/MagicDNS or private zone) use **self‑signed** certs issued by **your own CA**.
- All AeroVista PCs trust your Root CA (installed at imaging), so internal pages show a green lock.

---

## Contents

```
AeroVista-Internal-CA-Pack/
├─ defaults.json                # Tweak defaults (org, hosts, days) if desired
├─ scripts/
│  ├─ makecerts.sh              # Main generator (Root, Intermediate, server cert + SANs)
│  ├─ renew.sh                  # Simple renewal wrapper
│  ├─ hosts.txt                 # List of internal hostnames (SANs) for the server cert
│  └─ install_root_ca.ps1       # Windows installer for Root CA (for imaging/GPO)
├─ configs/
│  ├─ traefik/
│  │  ├─ dynamic/certs.yml      # Traefik dynamic TLS config (points to mounted certs)
│  │  └─ compose-snippet.yml    # Snippet to mount certs + enable file provider
│  └─ unbound/
│     └─ private-internal-zone.conf   # Example private zone for Unbound (internal.av)
└─ docs/
   └─ README.md (this file)
```

---

## Quick Start (TL;DR)

1. **Do NOT** override public `aerovista.us` in Unbound. Keep Firebase as-is.
2. Optionally create a private zone (e.g., `internal.av`) in Unbound for clean internal names.
3. Generate your CA + server certs:
   ```bash
   cd scripts
   ./makecerts.sh ../out ./hosts.txt
   ```
4. Copy output to your Traefik host:
   - `av-internal.fullchain.crt` and `av-internal.key` → `/srv/core/traefik/certs/`
   - Ensure `/srv/core/traefik/dynamic/certs.yml` exists (provided here).
5. Mount the certs and dynamic provider in your `compose.yml` (see `configs/traefik/compose-snippet.yml`).
6. **Install the Root CA** on AeroVista PCs (during imaging or via GPO) so browsers trust your internal TLS:
   ```powershell
   # Run as Administrator on Windows
   C:\AeroVista\certs\install_root_ca.ps1 -CertPath "C:\AeroVista\certs\av-root-ca.crt"
   ```
7. Restart Traefik and visit internal URLs from a trusted AeroVista PC.

---

## Detailed Steps

### 1) Design: Public vs Internal

- **Public**: `aerovista.us` (Firebase, public CAs). No changes.
- **Internal**: Tailscale/MagicDNS or a private zone (e.g., `*.internal.av`) for services like Traefik, Grafana, Portainer, Files, Status.
- All internal HTTPS uses your self-signed server cert **signed by your Intermediate CA**, which chains to your **Root CA** that you preinstall on AeroVista PCs.

### 2) Generate CA + Server Cert

Run the generator:
```bash
cd scripts
# Edit hosts.txt to include all internal hostnames
vi hosts.txt

# Generate into ../out
./makecerts.sh ../out ./hosts.txt
```

Artifacts (in `out/`):
- `av-root-ca.crt` / `av-root-ca.key` (KEEP THE ROOT KEY OFFLINE)
- `av-int-ca.crt` / `av-int-ca.key` (intermediate used to sign server certs)
- `av-internal.key` (server private key)
- `av-internal.crt` (server cert)
- `av-internal.fullchain.crt` (server + intermediate, use this in Traefik)

### 3) Traefik Configuration

Copy files to server:
```
/srv/core/traefik/certs/av-internal.key
/srv/core/traefik/certs/av-internal.fullchain.crt
/srv/core/traefik/dynamic/certs.yml     # from configs/traefik/dynamic
```

Ensure your `compose.yml` includes:
```yaml
services:
  traefik:
    volumes:
      - /srv/core/traefik:/traefik
      - /srv/core/traefik/certs:/traefik/certs:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    command:
      - --providers.file.directory=/traefik/dynamic
      - --providers.file.watch=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
```

Per internal router (example):
```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.portainer.rule=Host(`portainer.nxcore.tail79107c.ts.net`)
  - traefik.http.routers.portainer.entrypoints=websecure
  - traefik.http.routers.portainer.tls=true
```

**Note:** Do not configure ACME/certresolver for internal names when using your self-signed certificate file—Traefik will serve the configured `tls.certificates`.

### 4) Install Root CA on Clients

**Windows 10/11 (Edge/Chrome use OS store)**  
During imaging or via GPO/Intune, run:
```powershell
# As Administrator
C:\AeroVista\certs\install_root_ca.ps1 -CertPath "C:\AeroVista\certs\av-root-ca.crt"
```
- GPO: Computer Configuration → Policies → Windows Settings → Security Settings → Public Key Policies → **Trusted Root Certification Authorities** → Import.
- Firefox: set policy `security.enterprise_roots.enabled = true` (recommended).

**Linux**  
```bash
sudo cp av-root-ca.crt /usr/local/share/ca-certificates/aerovista-root-ca.crt
sudo update-ca-certificates
```

**Containers (as clients)**  
Add the root CA to images or mount host CA bundle:
```dockerfile
COPY av-root-ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
```

### 5) Unbound: Private Internal Zone (Optional but Recommended)

Use a clean internal suffix (`internal.av`) instead of long MagicDNS names, then map to Tailscale IPs:

`/etc/unbound/unbound.conf.d/private-internal-zone.conf`
```text
server:
    local-zone: "internal.av." static
    local-data: "traefik.internal.av. A 100.115.9.61"
    local-data: "grafana.internal.av. A 100.115.9.61"
    local-data: "portainer.internal.av. A 100.115.9.61"
```

Reload Unbound:
```bash
sudo unbound-checkconf && sudo systemctl reload unbound
```

**Do NOT** override `aerovista.us` or public subdomains in Unbound; let public DNS resolve to Firebase/Internet.

### 6) Testing

From a trusted AeroVista PC:
```bash
curl -v https://traefik.nxcore.tail79107c.ts.net
curl -v https://grafana.nxcore.tail79107c.ts.net
```
Browser should show a valid lock (issuer: *AeroVista ROOT CA*).

### 7) Renewal

When within ~60–90 days of expiry, run:
```bash
cd scripts
./renew.sh
```
Replace files on Traefik and reload:
```bash
docker compose -f /srv/core/compose.yml up -d traefik
```

### 8) Revocation & Key Hygiene

- Keep `av-root-ca.key` offline (USB vault). If the Intermediate key is ever compromised, revoke it by rotating a new Intermediate (and re-issuing server certs).
- To rotate the server key/cert, re-run `makecerts.sh` and redeploy.
- Consider auditing where the Root CA is installed; remove from devices that don’t need internal access.

---

## Troubleshooting

- **Browser still warns**: Ensure the **Root CA** is installed in the OS trust store. Check date/time on client.
- **TLS handshake fails**: Confirm `certs.yml` path and Traefik can read `/traefik/certs/*` (permissions).
- **Wrong certificate served**: Remove any `tls.certresolver=*` labels on internal routers; Traefik might try ACME instead of your file cert.
- **Hostname mismatch**: Add the hostname to `hosts.txt`, regenerate, redeploy.
- **Unbound conflicts**: Make sure no `local-data` exists for `aerovista.us` (apex or public subs).

---

## Roadmap (Optional Future Work)

- Public automation (Let’s Encrypt DNS-01) via Cloudflare or your existing DNS if reliable.
- Split certs per service (Granularity), still signed by Intermediate.
- Shorter-lived certs + scheduled renewal jobs on NXCore with notification to your Daily Brief Builder.
- Add policy for Firefox trust via `policies.json` in your imaging pipeline.
