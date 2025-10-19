# NXCore Infrastructure - Windows Implementation Guide

## 🖥️ **Environment Setup**

You are working on a **Windows development machine** with the NXCore infrastructure running on a **Linux server**.

### **Current Setup**
- **Windows Machine**: `D:\NeXuS\NXCore-Control` (Development/Control)
- **Linux Server**: `100.115.9.61` (Production Infrastructure)
- **Connection**: SSH via Tailscale network
- **User**: `glyph@100.115.9.61`

---

## 🚀 **Quick Start Implementation**

### **Option 1: Simple Batch File (Recommended)**
```cmd
# Double-click or run from command prompt
run-audit-fixes.bat
```

This will give you a menu to:
1. Test services only
2. Deploy fixes to server  
3. Run local tests
4. Show server status

### **Option 2: PowerShell Script**
```powershell
# Test services
.\scripts\windows-to-server-deployment.ps1 -TestOnly

# Deploy fixes
.\scripts\windows-to-server-deployment.ps1 -DeployFixes

# Run local tests
.\scripts\windows-to-server-deployment.ps1 -RunTests
```

### **Option 3: Direct Commands**

#### **Test Current Status**
```cmd
# Run comprehensive test
node ..\comprehensive-test.js

# Test specific services
curl -k https://nxcore.tail79107c.ts.net/
curl -k https://nxcore.tail79107c.ts.net/grafana/
```

#### **Deploy Fixes to Server**
```cmd
# Copy scripts to server
scp scripts\comprehensive-fix-implementation.sh glyph@100.115.9.61:/srv/core/scripts/

# SSH to server and run fixes
ssh glyph@100.115.9.61 "chmod +x /srv/core/scripts/comprehensive-fix-implementation.sh && /srv/core/scripts/comprehensive-fix-implementation.sh"
```

---

## 📋 **Implementation Steps**

### **Step 1: Test Current Status**
```cmd
# Run the batch file
run-audit-fixes.bat
# Choose option 1: Test services only
```

### **Step 2: Deploy Critical Fixes**
```cmd
# Run the batch file
run-audit-fixes.bat
# Choose option 2: Deploy fixes to server
```

### **Step 3: Verify Results**
```cmd
# Run the batch file
run-audit-fixes.bat
# Choose option 4: Show server status
```

---

## 🛠️ **Available Tools**

### **Testing Tools**
1. **`comprehensive-test.js`** - Node.js HTTP testing
2. **`playwright-service-tester.js`** - Browser-based testing
3. **`enhanced-service-monitor.py`** - Python monitoring

### **Fix Scripts**
1. **`comprehensive-fix-implementation.sh`** - Main fix script (runs on server)
2. **`windows-to-server-deployment.ps1`** - Windows deployment script
3. **`run-audit-fixes.bat`** - Simple batch file interface

### **Documentation**
1. **`NXCore-Audit-Improvement-Plan.md`** - Detailed improvement plan
2. **`NXCore-Audit-Summary.md`** - Executive summary
3. **`README-Windows-Implementation.md`** - This guide

---

## 🔧 **Prerequisites**

### **Windows Machine Requirements**
- **PowerShell** (for deployment scripts)
- **Node.js** (for testing scripts)
- **Python** (for enhanced monitoring)
- **SSH client** (for server connection)
- **SCP** (for file transfer)

### **Server Requirements**
- **Docker** and **Docker Compose**
- **Python 3** (for monitoring scripts)
- **Node.js** (for testing scripts)
- **SSH access** as `glyph` user

---

## 📊 **Expected Results**

### **Before Fixes**
- **Success Rate**: 42% (5/12 services working)
- **Critical Issues**: 7 services with problems
- **Security Issues**: Default credentials and placeholder secrets

### **After Fixes**
- **Success Rate**: 83%+ (10/12 services working)
- **Remaining Issues**: 2 services (AeroCaller, Portainer)
- **Security**: Hardened credentials and secrets

### **Final Target**
- **Success Rate**: 90%+ (11/12 services working)
- **Security**: Production-ready security controls
- **Monitoring**: Comprehensive service monitoring

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **SSH Connection Failed**
```cmd
# Test SSH connection
ssh glyph@100.115.9.61 "echo 'Connection test'"

# If failed, check Tailscale status
# Visit: https://login.tailscale.com/a/l56b871101866f
```

#### **Scripts Not Found**
```cmd
# Check if scripts exist
dir scripts\
dir scripts\*.ps1
dir scripts\*.sh
```

#### **Permission Denied**
```cmd
# Make scripts executable on server
ssh glyph@100.115.9.61 "chmod +x /srv/core/scripts/*.sh"
```

#### **Node.js Not Found**
```cmd
# Install Node.js on Windows
# Download from: https://nodejs.org/
# Or use: winget install OpenJS.NodeJS
```

#### **Python Not Found**
```cmd
# Install Python on Windows
# Download from: https://python.org/
# Or use: winget install Python.Python.3
```

---

## 📈 **Progress Tracking**

### **Phase 1: Critical Fixes (24 hours)**
- [ ] Fix Traefik routing issues (5 services)
- [ ] Fix service configuration issues (2 services)
- [ ] Implement security hardening
- [ ] **Target**: 83% success rate

### **Phase 2: Service Optimization (48 hours)**
- [ ] Complete service setup
- [ ] Implement SSL certificates
- [ ] Enhanced monitoring
- [ ] **Target**: 92% success rate

### **Phase 3: System Enhancement (1 week)**
- [ ] Performance optimization
- [ ] Advanced monitoring
- [ ] Documentation updates
- [ ] **Target**: 90%+ success rate

---

## 🎯 **Quick Commands Reference**

### **Test Services**
```cmd
# Local test
node ..\comprehensive-test.js

# Server test
ssh glyph@100.115.9.61 "cd /srv/core && node comprehensive-test.js"
```

### **Deploy Fixes**
```cmd
# Copy and run fix script
scp scripts\comprehensive-fix-implementation.sh glyph@100.115.9.61:/srv/core/scripts/
ssh glyph@100.115.9.61 "chmod +x /srv/core/scripts/comprehensive-fix-implementation.sh && /srv/core/scripts/comprehensive-fix-implementation.sh"
```

### **Check Server Status**
```cmd
# Check containers
ssh glyph@100.115.9.61 "docker ps"

# Check Traefik
ssh glyph@100.115.9.61 "curl -k https://nxcore.tail79107c.ts.net/api/http/routers"
```

### **View Logs**
```cmd
# View fix logs
ssh glyph@100.115.9.61 "tail -f /srv/core/logs/comprehensive-fix.log"

# View service logs
ssh glyph@100.115.9.61 "docker logs portainer"
ssh glyph@100.115.9.61 "docker logs aerocaller"
```

---

## 📞 **Support**

If you encounter issues:

1. **Check the logs**: `/srv/core/logs/` on the server
2. **Verify SSH connection**: `ssh glyph@100.115.9.61`
3. **Check Docker status**: `ssh glyph@100.115.9.61 "docker ps"`
4. **Review documentation**: `docs/NXCore-Audit-Improvement-Plan.md`

---

**Ready to implement? Run `run-audit-fixes.bat` and choose your option!**
