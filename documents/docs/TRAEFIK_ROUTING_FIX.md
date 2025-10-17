# Traefik Routing Fix

## Problem Summary

The Traefik routing system had two main issues:

1. **Container Naming**: Traefik container wasn't named consistently, causing `docker logs traefik` to fail
2. **Route Conflicts**: Landing page was catching all requests including `/api/*`, preventing Traefik's internal API from working

## Root Cause

The landing page had a catch-all route with `PathPrefix(/)` and priority 1, which intercepted requests to `/api/http/routers` and forwarded them to the landing app instead of Traefik's internal API.

## Solution Implemented

### 1. Fixed Traefik Container Naming
- Ensured `container_name: traefik` in all Traefik compose files
- This allows `docker logs traefik` to work consistently

### 2. Added Explicit Traefik API Routes
```yaml
# Traefik API (JSON) at /api -> NO strip
- traefik.http.routers.traefik-api.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/api`)
- traefik.http.routers.traefik-api.entrypoints=websecure
- traefik.http.routers.traefik-api.tls=true
- traefik.http.routers.traefik-api.service=api@internal
- traefik.http.routers.traefik-api.priority=100

# Traefik Dashboard at /dash -> STRIP /dash
- traefik.http.routers.traefik-dash.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/dash`)
- traefik.http.routers.traefik-dash.entrypoints=websecure
- traefik.http.routers.traefik-dash.tls=true
- traefik.http.routers.traefik-dash.service=api@internal
- traefik.http.routers.traefik-dash.priority=100
- traefik.http.middlewares.traefik-dash-strip.stripprefix.prefixes=/dash
- traefik.http.routers.traefik-dash.middlewares=traefik-dash-strip@docker
```

### 3. Updated Service Routing
- **n8n**: Changed from subdomain to path-based routing (`/n8n`)
- **OpenWebUI**: Changed from subdomain to path-based routing (`/ai`)
- Added proper `StripPrefix` middlewares for all services
- Set appropriate priorities (100 for Traefik, 50 for services, 1 for landing)

## Priority System

| Priority | Service | Route | Purpose |
|----------|---------|-------|---------|
| 100 | Traefik API | `/api/*` | Internal API access |
| 100 | Traefik Dashboard | `/dash/*` | Dashboard access |
| 50 | Services | `/service/*` | Application routing |
| 1 | Landing | `/` | Catch-all fallback |

## Files Modified

- `docker/compose-traefik.yml` - Added explicit API and dashboard routes
- `docker/compose-n8n.yml` - Changed to path-based routing with StripPrefix
- `docker/compose-openwebui.yml` - Changed to path-based routing with StripPrefix
- `scripts/fix-traefik-routing.sh` - Deployment script for fixes
- `scripts/deploy-traefik-fixes.ps1` - Windows deployment script

## Deployment

### From Windows (Recommended)
```powershell
.\scripts\deploy-traefik-fixes.ps1
```

### From Server
```bash
chmod +x /srv/core/fix-traefik-routing.sh
sudo /srv/core/fix-traefik-routing.sh
```

## Testing

After deployment, test these endpoints:

```bash
# Traefik API should return JSON
curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[].rule'

# Traefik Dashboard should load
curl -kI https://nxcore.tail79107c.ts.net/dash

# Services should be accessible
curl -kI https://nxcore.tail79107c.ts.net/n8n
curl -kI https://nxcore.tail79107c.ts.net/ai
```

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **Traefik API** | `/api/http/routers` | JSON API for routing info |
| **Traefik Dashboard** | `/dash` | Web dashboard |
| **Landing Page** | `/` | Main control panel |
| **n8n** | `/n8n` | Workflow automation |
| **AI Service** | `/ai` | OpenWebUI interface |

## Debugging

### Check Container Status
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"
```

### View Traefik Logs
```bash
docker logs traefik -f
```

### Test Route Matching
```bash
curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[] | {rule: .rule, priority: .priority}'
```

## Prevention

To prevent similar issues in the future:

1. **Always use explicit routes** for Traefik's internal services
2. **Set appropriate priorities** - higher numbers = higher priority
3. **Use path-based routing** for consistency
4. **Test API endpoints** after routing changes
5. **Monitor Traefik logs** for routing conflicts

---

**Traefik Routing Fix** - *Resolved container naming and route conflicts* 🔧
