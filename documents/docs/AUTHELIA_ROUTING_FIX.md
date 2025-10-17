# Authelia Routing Fix

## Problem Summary

The `/auth/` endpoint was returning a 502 Bad Gateway error:

```
Bad Gateway
Failed to load resource: the server responded with a status of 502 (Bad Gateway)
```

## Root Cause Analysis

Multiple issues were identified:

1. **Traefik routing disabled**: `traefik.enable=false` in the Authelia compose file
2. **Network connectivity**: Authelia container wasn't properly connected to the `gateway` network
3. **Missing Traefik labels**: No routing configuration for path-based access
4. **Duplicate configurations**: Two different Authelia configurations in different compose files

## Solution Implemented

### 1. Enabled Traefik Routing
```yaml
labels:
  - traefik.enable=true  # Changed from false
```

### 2. Added Path-Based Routing Configuration
```yaml
labels:
  - traefik.http.routers.authelia.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/auth`)
  - traefik.http.routers.authelia.entrypoints=websecure
  - traefik.http.routers.authelia.tls=true
  - traefik.http.routers.authelia.priority=50
  - traefik.http.middlewares.authelia-strip.stripprefix.prefixes=/auth
  - traefik.http.routers.authelia.middlewares=authelia-strip@docker
  - traefik.http.services.authelia.loadbalancer.server.port=9091
```

### 3. Ensured Network Connectivity
```yaml
networks:
  - gateway  # Required for Traefik access
  - backend  # Required for database/Redis access
```

### 4. Maintained ForwardAuth Middleware
```yaml
- traefik.http.middlewares.authelia.forwardAuth.authResponseHeaders=Remote-User,Remote-Groups,Remote-Name,Remote-Email
```

## How It Works

1. **Traefik** receives requests to `https://nxcore.tail79107c.ts.net/auth/*`
2. **Traefik** strips the `/auth` prefix using `StripPrefix` middleware
3. **Traefik** forwards the request to `authelia:9091`
4. **Authelia** processes the request and returns the response
5. **Traefik** serves the response to the client

## Deployment

### From Windows (Recommended)
```powershell
.\scripts\deploy-authelia-fix.ps1
```

### From Server
```bash
chmod +x /srv/core/fix-authelia-routing.sh
sudo /srv/core/fix-authelia-routing.sh
```

## Testing

After deployment, test these endpoints:

```bash
# Main page should load without 502 errors
curl -k https://nxcore.tail79107c.ts.net/auth

# Health endpoint should return OK
curl -k https://nxcore.tail79107c.ts.net/auth/api/health

# Direct container access should work
curl http://localhost:9091/api/health
```

## Expected Results

- ✅ Authelia loads properly at `https://nxcore.tail79107c.ts.net/auth`
- ✅ No more 502 Bad Gateway errors
- ✅ Login interface displays correctly
- ✅ Health endpoints respond properly
- ✅ ForwardAuth middleware available for other services

## Troubleshooting

### If Authelia still shows 502 errors:

1. **Check container status:**
   ```bash
   docker ps | grep authelia
   ```

2. **Check container logs:**
   ```bash
   docker logs authelia -f
   ```

3. **Verify network connectivity:**
   ```bash
   docker network inspect gateway
   docker network inspect backend
   ```

4. **Test direct container access:**
   ```bash
   curl http://localhost:9091/api/health
   ```

5. **Check Traefik routing:**
   ```bash
   curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[] | select(.rule | contains("auth"))'
   ```

### Common Issues:

- **Container not running**: Check if Authelia container is started and healthy
- **Network issues**: Ensure both `gateway` and `backend` networks exist
- **Configuration errors**: Verify Authelia configuration files are valid
- **Port conflicts**: Ensure port 9091 is not used by other services

## Configuration Requirements

### Authelia Configuration
Ensure `/opt/nexus/authelia/configuration.yml` exists with proper settings:

```yaml
server:
  host: 0.0.0.0
  port: 9091

authentication_backend:
  file:
    path: /config/users_database.yml

access_control:
  default_policy: deny
  rules:
    - domain: "nxcore.tail79107c.ts.net"
      policy: one_factor
```

### Environment Variables
Required environment variables:
- `AUTHELIA_JWT_SECRET`
- `AUTHELIA_SESSION_SECRET`
- `AUTHELIA_STORAGE_ENCRYPTION_KEY`
- `REDIS_PASSWORD`
- `AUTHELIA_DB_PASSWORD`

## Files Modified

- `docker/compose-authelia.yml` - Added proper Traefik routing configuration
- `scripts/fix-authelia-routing.sh` - Deployment script for the fix
- `scripts/deploy-authelia-fix.ps1` - Windows deployment script

## Integration with Other Services

Once Authelia is working, it can be used as a ForwardAuth middleware for other services:

```yaml
labels:
  - traefik.http.routers.service.middlewares=authelia@docker
```

This will require authentication for the service through Authelia.

---

**Authelia Routing Fix** - *Resolved 502 Bad Gateway for authentication service* 🔐
