# Path-Based Routing Deployment Guide

## Overview

This deployment uses **path-based routing** under a single Tailscale hostname (`nxcore.tail79107c.ts.net`) instead of subdomains. This approach works perfectly with Tailscale's single-hostname certificates.

## Architecture

**Single Hostname:** `nxcore.tail79107c.ts.net`
**All Services:** Accessible via paths like `/grafana`, `/prometheus`, `/files`, etc.

## Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Landing** | https://nxcore.tail79107c.ts.net/ | Main dashboard |
| **Traefik** | https://nxcore.tail79107c.ts.net/traefik/ | Traefik dashboard |
| **Auth** | https://nxcore.tail79107c.ts.net/auth/ | Authelia SSO |
| **Grafana** | https://nxcore.tail79107c.ts.net/grafana/ | Monitoring dashboards |
| **Prometheus** | https://nxcore.tail79107c.ts.net/prometheus/ | Metrics collection |
| **Status** | https://nxcore.tail79107c.ts.net/status/ | Uptime monitoring |
| **Files** | https://nxcore.tail79107c.ts.net/files/ | File browser |
| **Portainer** | https://nxcore.tail79107c.ts.net/portainer/ | Container management |
| **AeroCaller** | https://nxcore.tail79107c.ts.net/aerocaller/ | WebRTC calling |

## Deployment Steps

### 1. Create Tailscale Certificate (5 min)

```bash
# SSH to NXCore
ssh glyph@100.115.9.61

# Create certificate directory
sudo mkdir -p /etc/ssl/tailscale

# Generate Tailscale certificate for single hostname
sudo tailscale cert \
  --cert-file /etc/ssl/tailscale/nxcore.tail79107c.ts.net.crt \
  --key-file  /etc/ssl/tailscale/nxcore.tail79107c.ts.net.key \
  nxcore.tail79107c.ts.net

# Set proper permissions
sudo chown root:root /etc/ssl/tailscale/nxcore.tail79107c.ts.net.*
sudo chmod 600 /etc/ssl/tailscale/nxcore.tail79107c.ts.net.key
sudo chmod 644 /etc/ssl/tailscale/nxcore.tail79107c.ts.net.crt
```

### 2. Deploy Updated Configuration (10 min)

```powershell
# From Windows PowerShell (in NXCore-Control directory)
.\scripts\ps\deploy-containers.ps1 -Service traefik
```

This will:
- Copy dynamic configuration files to `/opt/nexus/traefik/dynamic/`
- Deploy Traefik with path-based routing
- Mount Tailscale certificates

### 3. Deploy Foundation Services (15 min)

```powershell
.\scripts\ps\deploy-containers.ps1 -Service foundation
```

### 4. Deploy Additional Services (as needed)

```powershell
# Observability stack
.\scripts\ps\deploy-containers.ps1 -Service observability

# AI services
.\scripts\ps\deploy-containers.ps1 -Service ai

# Individual services
.\scripts\ps\deploy-containers.ps1 -Service portainer
.\scripts\ps\deploy-containers.ps1 -Service filebrowser
```

## Configuration Files

### Traefik Dynamic Configuration

**Location:** `/opt/nexus/traefik/dynamic/`

**Files:**
- `tailscale-certs.yml` - Points to Tailscale certificates
- `tailnet-routes.yml` - Path-based routing rules
- `traefik-dynamic.yml` - Middleware and TLS options

### Key Features

1. **Single Certificate:** Uses one Tailscale cert for all services
2. **Path Stripping:** Removes `/service` prefix before forwarding to containers
3. **Secure Headers:** Adds security headers to all responses
4. **Backend Transport:** Handles HTTPS backends (Portainer, AeroCaller) with skip-verify

## App Configuration

### Grafana
```yaml
environment:
  - GF_SERVER_ROOT_URL=https://nxcore.tail79107c.ts.net/grafana/
```

### Prometheus (Optional)
```yaml
command:
  - --web.external-url=https://nxcore.tail79107c.ts.net/prometheus/
```

### Authelia
```yaml
session:
  domain: nxcore.tail79107c.ts.net
```

## Testing

### Certificate Validation
```bash
# Check certificate
echo | openssl s_client -connect nxcore.tail79107c.ts.net:443 -servername nxcore.tail79107c.ts.net 2>/dev/null | openssl x509 -noout -subject -issuer -enddate
```

### Service Health Checks
```bash
# Test all path-based routes
curl -I https://nxcore.tail79107c.ts.net/traefik/
curl -I https://nxcore.tail79107c.ts.net/portainer/
curl -I https://nxcore.tail79107c.ts.net/grafana/
curl -I https://nxcore.tail79107c.ts.net/prometheus/
curl -I https://nxcore.tail79107c.ts.net/files/
curl -I https://nxcore.tail79107c.ts.net/auth/
curl -I https://nxcore.tail79107c.ts.net/status/
curl -I https://nxcore.tail79107c.ts.net/aerocaller/
```

## Troubleshooting

### Certificate Issues
- Ensure Tailscale certificate exists: `ls -l /etc/ssl/tailscale/`
- Check Traefik mounts: `sudo docker inspect traefik | grep -A 10 Mounts`
- Verify certificate is valid: `openssl x509 -in /etc/ssl/tailscale/nxcore.tail79107c.ts.net.crt -text -noout`

### Routing Issues
- Check Traefik logs: `sudo docker logs traefik --tail 50`
- Verify dynamic config: `sudo docker exec traefik cat /etc/traefik/dynamic/tailnet-routes.yml`
- Test internal connectivity: `sudo docker exec traefik wget -qO- http://grafana:3000/`

### App Configuration Issues
- Grafana 404: Check `GF_SERVER_ROOT_URL` is set correctly
- Portainer 502: Verify HTTPS backend with skip-verify
- Authelia redirects: Check session domain matches hostname

## Security Notes

1. **Tailscale-Only:** All services are accessible only via Tailscale network
2. **Single Certificate:** No wildcard certificates needed
3. **Path Isolation:** Each service runs in its own path namespace
4. **Secure Headers:** Security headers applied to all responses

## Benefits

1. **Simplified Certificates:** One certificate for all services
2. **Easier DNS:** No subdomain management needed
3. **Clean URLs:** Consistent path-based structure
4. **Tailscale Native:** Works perfectly with Tailscale's certificate system
5. **Future-Proof:** Easy to add new services under new paths

## Migration from Subdomains

If migrating from subdomain-based routing:

1. **Backup Current State:** `sudo docker ps > current-containers.txt`
2. **Deploy New Configuration:** Follow steps above
3. **Test All Services:** Verify all path-based URLs work
4. **Update Bookmarks:** Change all saved URLs to path-based format
5. **Clean Up:** Remove old subdomain configurations

## Auto-Renewal

Tailscale certificates auto-renew, but you can set up monitoring:

```bash
# Check certificate expiry
openssl x509 -in /etc/ssl/tailscale/nxcore.tail79107c.ts.net.crt -noout -enddate

# Set up monitoring alert for expiry
# (Add to your monitoring system)
```

---

**Status:** ✅ Ready for deployment with path-based routing
**Certificate:** Single Tailscale cert for `nxcore.tail79107c.ts.net`
**Routing:** All services under `/service` paths
