# OpenWebUI Path-Based Routing Fix

## Problem Summary

OpenWebUI was showing an error when accessed via path-based routing at `https://nxcore.tail79107c.ts.net/ai`:

```
Open WebUI Backend Required
Oops! You're using an unsupported method (frontend only). Please serve the WebUI from the backend.
```

## Root Cause

OpenWebUI wasn't properly configured for subpath deployment. The application expected to be served from the root path, but we were using Traefik's `StripPrefix` middleware which removed the `/ai` prefix before forwarding to the container.

## Solution Implemented

### 1. Added WEBUI_BASE_PATH Environment Variable
```yaml
environment:
  - WEBUI_BASE_PATH=/ai
```

This tells OpenWebUI to expect requests at the `/ai` path and handle the base path internally.

### 2. Removed StripPrefix Middleware
```yaml
# REMOVED:
# - traefik.http.middlewares.openwebui-strip.stripprefix.prefixes=/ai
# - traefik.http.routers.openwebui.middlewares=openwebui-strip@docker
```

Since OpenWebUI now handles the base path internally, we don't need Traefik to strip the prefix.

### 3. Updated Configuration
The final OpenWebUI configuration:
```yaml
services:
  openwebui:
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
      - WEBUI_NAME=AeroVista AI Assistant
      - WEBUI_AUTH=true
      - WEBUI_URL=https://nxcore.tail79107c.ts.net/ai
      - WEBUI_BASE_PATH=/ai  # Key addition
    labels:
      - traefik.http.routers.openwebui.rule=Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/ai`)
      - traefik.http.routers.openwebui.entrypoints=websecure
      - traefik.http.routers.openwebui.tls=true
      - traefik.http.routers.openwebui.priority=50
      - traefik.http.services.openwebui.loadbalancer.server.port=8080
```

## How It Works

1. **Traefik** receives requests to `https://nxcore.tail79107c.ts.net/ai/*`
2. **Traefik** forwards the full path (including `/ai`) to OpenWebUI
3. **OpenWebUI** sees the `WEBUI_BASE_PATH=/ai` environment variable
4. **OpenWebUI** handles the base path internally and serves the correct content
5. **User** sees the OpenWebUI interface properly loaded

## Deployment

### From Windows (Recommended)
```powershell
.\scripts\deploy-openwebui-fix.ps1
```

### From Server
```bash
chmod +x /srv/core/fix-openwebui-routing.sh
sudo /srv/core/fix-openwebui-routing.sh
```

## Testing

After deployment, test these endpoints:

```bash
# Main page should load without errors
curl -k https://nxcore.tail79107c.ts.net/ai

# Health endpoint should return OK
curl -k https://nxcore.tail79107c.ts.net/ai/health

# API endpoint should be accessible
curl -k https://nxcore.tail79107c.ts.net/ai/api/v1/health
```

## Expected Results

- ✅ OpenWebUI loads properly at `https://nxcore.tail79107c.ts.net/ai`
- ✅ No more "frontend only" error
- ✅ All static assets (CSS, JS, images) load correctly
- ✅ API endpoints work properly
- ✅ Chat interface functions normally

## Troubleshooting

### If OpenWebUI still shows errors:

1. **Check container logs:**
   ```bash
   docker logs openwebui -f
   ```

2. **Verify environment variables:**
   ```bash
   docker exec openwebui env | grep WEBUI
   ```

3. **Test direct container access:**
   ```bash
   curl http://localhost:8080/health
   ```

4. **Check Traefik routing:**
   ```bash
   curl -k https://nxcore.tail79107c.ts.net/api/http/routers | jq '.[] | select(.rule | contains("ai"))'
   ```

### Common Issues:

- **Static assets not loading**: Check that `WEBUI_BASE_PATH` is set correctly
- **API calls failing**: Verify that the base path is consistent across all requests
- **Redirect loops**: Ensure no conflicting middleware is applied

## Files Modified

- `docker/compose-openwebui.yml` - Added `WEBUI_BASE_PATH` and removed `StripPrefix`
- `scripts/fix-openwebui-routing.sh` - Deployment script for the fix
- `scripts/deploy-openwebui-fix.ps1` - Windows deployment script

## Alternative Solutions

If the `WEBUI_BASE_PATH` approach doesn't work, alternative solutions include:

1. **Use subdomain routing** instead of path-based routing
2. **Use a reverse proxy** like nginx in front of OpenWebUI
3. **Modify OpenWebUI's static file serving** configuration

---

**OpenWebUI Routing Fix** - *Resolved path-based routing for AI interface* 🤖
