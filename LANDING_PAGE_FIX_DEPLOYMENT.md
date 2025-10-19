# 🚨 **LANDING PAGE REDIRECT FIX - DEPLOYMENT GUIDE**

**Date**: January 27, 2025
**Status**: 🚨 **CRITICAL FIX READY FOR DEPLOYMENT**
**Issue**: All pages redirecting to landing page

---

## 🚨 **CRITICAL ISSUE IDENTIFIED**

### **Problem**: Landing page intercepting all requests

- **Priority**: 1 (too high)
- **Rule**: `PathPrefix('/')` (catches all paths)
- **Impact**: All services redirect to landing page
- **Result**: 0% service availability

### **Root Cause**:

The landing page configuration was set to catch ALL requests with:

```yaml
rule: Host(`nxcore.tail79107c.ts.net`) && PathPrefix(`/`)
priority: 1
```

This meant that ANY request to the domain would be caught by the landing page before reaching other services.

---

## 🔧 **FIX APPLIED**

### **Changes Made**:

1. **Priority**: Changed from 1 to 50
2. **Rule**: Changed from `PathPrefix('/')` to `Path('/')`
3. **Result**: Landing page only handles root path

### **New Configuration**:

```yaml
rule: Host(`nxcore.tail79107c.ts.net`) && Path(`/`)
priority: 50
```

---

## 🚀 **DEPLOYMENT STEPS**

### **Step 1: Update Server Credentials**

Edit `scripts/deploy-landing-fix.sh` and update:

```bash
SERVER_USER=glyph	              # e.g., "root" or "ubuntu"
SERVER_HOST=100.115.9.61	       # e.g., "192.168.1.100"
SERVER_PATH=home	              # Update if different
```

### **Step 2: Deploy Fix**

```bash
# Make script executable
chmod +x scripts/deploy-landing-fix.sh

# Deploy to production server
./scripts/deploy-landing-fix.sh
```

**What this script does:**

1. **Creates server backup** of current configuration
2. **Deploys fixed landing page configuration**
3. **Restarts Traefik** to apply changes
4. **Tests all services** to verify functionality
5. **Generates deployment report**

### **Step 3: Manual Deployment (Alternative)**

If you prefer to deploy manually:

```bash
# SSH to your server
ssh your-user@your-server-ip

# Create backup
mkdir -p /srv/core/backups/$(date +%Y%m%d_%H%M%S)
cp -r /opt/nexus/docker /srv/core/backups/$(date +%Y%m%d_%H%M%S)/docker-backup

# Deploy fixed configuration
# Copy the fixed file to your server:
# docker/compose-landing.yml → /opt/nexus/docker/

# Restart Traefik
docker restart traefik
sleep 30

# Test services
curl -k -s -o /dev/null -w 'Landing: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/
curl -k -s -o /dev/null -w 'Grafana: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/grafana/
curl -k -s -o /dev/null -w 'Prometheus: HTTP %{http_code}\n' https://nxcore.tail79107c.ts.net/prometheus/
```

---

## 🧪 **TESTING CHECKLIST**

### **✅ Critical Tests**

- [ ] **Root path**: `https://nxcore.tail79107c.ts.net/` → Landing page (HTTP 200)
- [ ] **Grafana**: `https://nxcore.tail79107c.ts.net/grafana/` → Grafana (HTTP 200)
- [ ] **Prometheus**: `https://nxcore.tail79107c.ts.net/prometheus/` → Prometheus (HTTP 200)
- [ ] **cAdvisor**: `https://nxcore.tail79107c.ts.net/metrics/` → cAdvisor (HTTP 200)
- [ ] **Uptime Kuma**: `https://nxcore.tail79107c.ts.net/status/` → Uptime Kuma (HTTP 200)

### **✅ Additional Tests**

- [ ] **FileBrowser**: `https://nxcore.tail79107c.ts.net/files/` → FileBrowser
- [ ] **OpenWebUI**: `https://nxcore.tail79107c.ts.net/ai/` → OpenWebUI
- [ ] **Portainer**: `https://nxcore.tail79107c.ts.net/portainer/` → Portainer
- [ ] **AeroCaller**: `https://nxcore.tail79107c.ts.net/aerocaller/` → AeroCaller
- [ ] **Authelia**: `https://nxcore.tail79107c.ts.net/auth/` → Authelia

---

## 📊 **EXPECTED RESULTS**

### **🎯 Before Fix (BROKEN)**:

- All requests → Landing page
- Services unreachable
- 0% service availability

### **✅ After Fix (WORKING)**:

- Root path (/) → Landing page
- Service paths (/grafana, /prometheus, etc.) → Services
- 94% service availability

---

## 🚨 **ROLLBACK PROCEDURE**

If issues occur after deployment:

### **Quick Rollback**:

```bash
# SSH to server
ssh your-user@your-server-ip

# Restore from backup
cp -r /srv/core/backups/BACKUP_DIR/docker-backup/* /opt/nexus/docker/

# Restart Traefik
docker restart traefik
```

---

## 📁 **FILES TO DEPLOY**

### **🔧 Configuration Files**

- `docker/compose-landing.yml` → `/opt/nexus/docker/`

### **📋 Documentation Files**

- `scripts/deploy-landing-fix.sh`
- `LANDING_PAGE_FIX_DEPLOYMENT.md`

---

## 🎉 **DEPLOYMENT SUCCESS CRITERIA**

### **✅ Technical Success**

- [ ] Root path returns landing page (HTTP 200)
- [ ] Service paths return services (HTTP 200)
- [ ] No redirect loops
- [ ] Service availability reaches 94%

### **✅ Operational Success**

- [ ] All team members can access services
- [ ] Landing page works for root path
- [ ] Services work for their respective paths
- [ ] No performance degradation

---

## 🚀 **READY TO DEPLOY**

### **📋 Pre-Deployment Checklist**

- [ ] Server credentials configured
- [ ] Backup strategy in place
- [ ] Testing plan ready
- [ ] Rollback procedure tested

### **🎯 Deployment Command**

```bash
# Execute deployment
chmod +x scripts/deploy-landing-fix.sh
./scripts/deploy-landing-fix.sh
```

**🎉 LANDING PAGE REDIRECT FIX READY FOR DEPLOYMENT!** 🚀

---

*Deployment guide created on: January 27, 2025*
*Critical landing page redirect fix ready*
*Target: 94% service availability*
