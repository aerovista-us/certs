# NXCore Quick Reference Card

## 🚀 Clean Install (Fresh Start)

```bash
# 1. On NXCore (wipe existing):
ssh glyph@192.168.7.209
sudo docker stop $(sudo docker ps -aq) && sudo docker rm $(sudo docker ps -aq)
sudo docker network rm gateway

# 2. On Windows (deploy in order):
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519  # If no key
Get-Content ~/.ssh/id_ed25519.pub | ssh glyph@192.168.7.209 "cat >> ~/.ssh/authorized_keys"

# 3. Deploy services:
.\scripts\ps\deploy-containers.ps1 -Service foundation    # Core infrastructure
.\scripts\ps\deploy-containers.ps1 -Service observability # Monitoring stack
.\scripts\ps\deploy-containers.ps1 -Service ai            # AI services
.\scripts\ps\deploy-containers.ps1 -Service portainer     # Access within 5 min!

# 4. SSL Certificate Fix (Required for workspaces):
ssh glyph@100.115.9.61
sudo mkdir -p /opt/nexus/traefik/certs
cd /opt/nexus/traefik/certs
sudo openssl req -x509 -newkey rsa:4096 -keyout self-signed.key \
    -out self-signed.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=NXCore/CN=*.nxcore.tail79107c.ts.net" \
    -addext "subjectAltName=DNS:*.nxcore.tail79107c.ts.net,DNS:nxcore.tail79107c.ts.net"
sudo chown root:root self-signed.*
sudo chmod 600 self-signed.key
sudo chmod 644 self-signed.crt
sudo docker restart traefik

# 4.5. Install certificate on client PCs (Recommended):
# Download certificate: scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./
# Windows: certlm.msc → Trusted Root Certification Authorities → Import
# macOS: Keychain Access → Import → Trust Always
# Linux: sudo cp self-signed.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates

# 5. Deploy workspaces (after SSL fix):
.\scripts\ps\deploy-containers.ps1 -Service workspaces    # Phase B: Browser workspaces
```

## 📋 Service URLs

### **Working URLs (Current)**
```
Main Dashboard: https://nxcore.tail79107c.ts.net/
Portainer:      http://100.115.9.61:9444/
FileBrowser:    http://100.115.9.61:8080/
Grafana:        http://100.115.9.61:3000/
Prometheus:     http://100.115.9.61:9090/
Uptime Kuma:    http://100.115.9.61:3001/
Dozzle:         http://100.115.9.61:8080/
Authelia:       http://100.115.9.61:9091/
```

### **After SSL Certificate Fix**
```
Traefik:        https://traefik.nxcore.tail79107c.ts.net/
n8n:            https://n8n.nxcore.tail79107c.ts.net/
FileBrowser:    https://files.nxcore.tail79107c.ts.net/
Portainer:      https://portainer.nxcore.tail79107c.ts.net/
Grafana:        https://grafana.nxcore.tail79107c.ts.net/
Prometheus:     https://prometheus.nxcore.tail79107c.ts.net/
AeroCaller:     https://nxcore.tail79107c.ts.net:4443/
```

## 🔧 Common Commands

### Docker Status
```bash
# All containers
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Specific service
sudo docker ps --filter name=n8n
sudo docker logs n8n --tail 50
sudo docker restart n8n
```

### Network Inspection
```bash
# Check gateway network
sudo docker network inspect gateway

# Check if service is on gateway
sudo docker inspect n8n --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}: {{$v.IPAddress}}{{end}}'

# Verify Traefik labels
sudo docker inspect n8n --format '{{range $k,$v := .Config.Labels}}{{println $k "=" $v}}{{end}}' | grep traefik
```

### Traefik Status
```bash
# See all routers
sudo docker exec traefik wget -qO- http://localhost/api/http/routers | jq '.[].name'

# Check logs
sudo docker logs traefik --tail 100 | grep -i error

# Test routing
curl -H "Host: n8n.nxcore.tail79107c.ts.net" http://localhost:80/
```

### Tailscale
```bash
# Status
tailscale status | grep nxcore

# Serve status
sudo tailscale serve status

# Mint new cert
sudo tailscale cert --cert-file=/opt/nexus/traefik/certs/fullchain.pem \
                    --key-file=/opt/nexus/traefik/certs/privkey.pem \
                    nxcore.tail79107c.ts.net
```

## 🆘 Troubleshooting

### Service won't route through Traefik
```bash
# 1. Is it on gateway network?
sudo docker inspect <service> | grep -A10 Networks | grep gateway

# 2. Does Traefik see it?
sudo docker logs traefik | grep <service>

# 3. Are labels correct?
sudo docker inspect <service> | grep traefik

# Fix: Recreate with gateway network
cd /srv/core
sudo docker-compose -f compose-<service>.yml down
sudo docker-compose -f compose-<service>.yml up -d
```

### Port conflict
```bash
# Find what's using the port
sudo ss -ltnp | grep :<port>

# Stop the conflicting container
sudo docker stop <container>

# Or change the port in compose file
```

### Portainer timeout
```bash
# Restart and access IMMEDIATELY (<5 min)
sudo docker restart portainer
# Open: https://portainer.nxcore.tail79107c.ts.net/
# Create admin user fast!
```

### Container unhealthy
```bash
# Check healthcheck command
sudo docker inspect <service> | jq '.[].Config.Healthcheck'

# See failed healthcheck logs
sudo docker inspect <service> | jq '.[].State.Health.Log'

# For Alpine images missing curl:
sudo docker exec <service> apk add --no-cache curl
```

### Can't SSH without password
```bash
# Check SSH key
cat ~/.ssh/id_ed25519.pub

# Verify on server
ssh glyph@192.168.7.209 'cat ~/.ssh/authorized_keys'

# Fix permissions
ssh glyph@192.168.7.209 'chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys'
```

## 🔄 Maintenance

### Update all containers
```bash
# Via Watchtower (automatic every 24h)
sudo docker logs watchtower

# Manual update
cd /srv/core
sudo docker-compose -f compose-traefik.yml pull && sudo docker-compose -f compose-traefik.yml up -d
```

### Backup volumes
```bash
# Portainer
sudo docker run --rm -v portainer_data:/data -v $PWD:/backup alpine \
  tar czf /backup/portainer-$(date +%F).tgz -C /data .

# n8n
sudo docker run --rm -v n8n_data:/data -v $PWD:/backup alpine \
  tar czf /backup/n8n-$(date +%F).tgz -C /data .
```

### Clean up
```bash
# Remove stopped containers
sudo docker container prune

# Remove unused images
sudo docker image prune -a

# Remove unused volumes (CAREFUL!)
sudo docker volume prune

# Full cleanup
sudo docker system prune -af --volumes
```

## 📁 File Locations

### On NXCore
```
/srv/core/                          # Compose files
├── compose-traefik.yml
├── compose-n8n.yml
├── compose-filebrowser.yml
├── compose-portainer.yml
├── compose-aerocaller.yml
├── n8n_data/                       # n8n workflows
└── filebrowser.db                  # FileBrowser database

/opt/nexus/
├── traefik/
│   ├── dynamic/traefik-dynamic.yml # Traefik middleware/TLS config
│   └── certs/                      # Tailscale certificates
│       ├── fullchain.pem
│       └── privkey.pem
├── aerocaller/                     # AeroCaller app files
│   ├── server.staff.js
│   ├── app.staff.js
│   ├── index.staff.html
│   ├── package.json
│   └── certs/                      # Copy of Tailscale certs
└── scripts/                        # Backup scripts, etc.
```

### On Windows
```
D:\NeXuS\NXCore-Control\
├── docs/
│   ├── CLEAN_INSTALL_GUIDE.md      # Step-by-step fresh install
│   ├── TROUBLESHOOTING_COMPLETE_REPORT.md
│   ├── CLEAN_INSTALL_SUMMARY.md
│   └── QUICK_REFERENCE.md          # This file
├── docker/
│   ├── compose-*.yml               # Service definitions
│   └── traefik-dynamic.yml
├── scripts/
│   └── ps/
│       └── deploy-containers.ps1   # Main deployment script
└── apps/AeroCaller/                # Source files for AeroCaller
```

## 🎯 Deployment Checklist

**Before Starting:**
- [ ] NXCore is accessible via SSH
- [ ] Tailscale is running on NXCore
- [ ] You're in `D:\NeXuS\NXCore-Control\` directory

**Clean Install Order:**
1. [ ] SSH keys configured (no password prompts)
2. [ ] Tailscale certs minted
3. [ ] Traefik deployed (creates gateway network)
4. [ ] n8n deployed (first service behind Traefik)
5. [ ] FileBrowser deployed
6. [ ] Portainer deployed + admin created <5 min
7. [ ] AeroCaller deployed
8. [ ] Watchtower + node_exporter running

**Verification:**
- [ ] `sudo docker ps` shows no port conflicts
- [ ] All service URLs accessible from browser
- [ ] `docker network inspect gateway` shows all services
- [ ] No containers show "(unhealthy)"

## 💡 Pro Tips

1. **Always deploy Traefik first** - It creates the gateway network
2. **No published ports for proxied services** - Prevents conflicts
3. **Use `external: true`** for shared networks in compose files
4. **Clear browser cache** if seeing old cached pages
5. **Portainer has 5-min timeout** - Create admin immediately
6. **Alpine images need curl** - Add to startup or use `wget`
7. **Check Traefik logs first** - Most routing issues show there
8. **One routing layer** - Don't mix Tailscale Serve + Traefik

## 📚 Full Documentation

- **Complete Guide:** [docs/CLEAN_INSTALL_GUIDE.md](CLEAN_INSTALL_GUIDE.md)
- **Troubleshooting:** [docs/TROUBLESHOOTING_COMPLETE_REPORT.md](TROUBLESHOOTING_COMPLETE_REPORT.md)
- **Summary:** [docs/CLEAN_INSTALL_SUMMARY.md](CLEAN_INSTALL_SUMMARY.md)

---

**Need help?** Check the troubleshooting report or run:
```bash
sudo docker logs <service> --tail 100
sudo docker inspect <service> | jq
```

