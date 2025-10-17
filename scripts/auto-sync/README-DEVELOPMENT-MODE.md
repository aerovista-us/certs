# 🛠️ NXCore Development Mode & Inbox Sync

This guide explains how to manage auto-sync during development and use the inbox sync system for easy file transfers.

## 🎯 **The Problem**

During development, auto-sync can be problematic:
- ❌ **Local changes get overwritten** when you push to GitHub
- ❌ **Loss of work** during active development
- ❌ **Interruptions** from automatic updates
- ❌ **Hard to test** local changes

## 🚀 **The Solution**

### **Development Mode Manager**
- ✅ **Disable auto-sync** during development
- ✅ **Enable auto-sync** for production
- ✅ **Manual sync** when needed
- ✅ **Status monitoring** and control

### **Inbox Sync System**
- ✅ **Easy file transfers** from Windows to server
- ✅ **Automatic GitHub sync** of specific folder
- ✅ **No conflicts** with main auto-sync
- ✅ **Simple drop-and-sync** workflow

## 🛠️ **Development Mode**

### **Enable Development Mode (Disable Auto-Sync)**
```bash
# SSH into server
ssh root@nxcore.tail79107c.ts.net
cd /srv/core

# Disable auto-sync
./scripts/auto-sync/development-mode.sh dev
```

**Result:**
- ✅ Auto-sync is **DISABLED**
- ✅ Local changes are **SAFE**
- ✅ You can develop without interruptions
- ✅ No risk of losing work

### **Enable Production Mode (Enable Auto-Sync)**
```bash
# When ready for production
./scripts/auto-sync/development-mode.sh prod
```

**Result:**
- ✅ Auto-sync is **ENABLED**
- ✅ Server stays in sync with GitHub
- ✅ Automatic updates resume
- ⚠️ Local changes will be overwritten

### **Check Current Status**
```bash
./scripts/auto-sync/development-mode.sh status
```

**Shows:**
- Current mode (Development/Production)
- Auto-sync status (Enabled/Disabled)
- Service status
- Recent activity

### **Manual Sync (One-Time)**
```bash
# Pull latest changes without enabling auto-sync
./scripts/auto-sync/development-mode.sh sync
```

## 📁 **Inbox Sync System**

### **How It Works**
1. **Drop files** into `/srv/core/inbox/` on the server
2. **Inbox sync** automatically detects new files
3. **Files are committed** to GitHub automatically
4. **Easy file transfer** from Windows to server

### **Setup Inbox Sync**
```bash
# Create systemd service for continuous sync
./scripts/auto-sync/inbox-sync.sh setup-service

# Start the service
./scripts/auto-sync/inbox-sync.sh start
```

### **Use Inbox Sync**
```bash
# Copy files to inbox
cp /path/to/file.txt /srv/core/inbox/

# Or use SCP from Windows
scp file.txt root@nxcore.tail79107c.ts.net:/srv/core/inbox/

# Files are automatically synced to GitHub!
```

### **Inbox Sync Commands**
```bash
# One-time sync
./scripts/auto-sync/inbox-sync.sh sync

# List files in inbox
./scripts/auto-sync/inbox-sync.sh list

# Clean old files (remove files older than 7 days)
./scripts/auto-sync/inbox-sync.sh clean 7

# Check service status
./scripts/auto-sync/inbox-sync.sh status
```

## 🎯 **Development Workflow**

### **Start Development Session**
```bash
# 1. SSH into server
ssh root@nxcore.tail79107c.ts.net
cd /srv/core

# 2. Enable development mode
./scripts/auto-sync/development-mode.sh dev

# 3. Verify auto-sync is disabled
./scripts/auto-sync/development-mode.sh status
```

### **During Development**
```bash
# Make local changes safely
nano docker/compose-traefik.yml
# ... make your changes ...

# Test your changes
docker-compose -f docker/compose-traefik.yml restart traefik

# Your changes are safe - auto-sync is disabled!
```

### **Transfer Files from Windows**
```bash
# From Windows PowerShell
scp C:\path\to\file.txt root@nxcore.tail79107c.ts.net:/srv/core/inbox/

# File is automatically synced to GitHub!
```

### **End Development Session**
```bash
# 1. Commit your changes to GitHub
git add .
git commit -m "Development changes"
git push origin master

# 2. Enable production mode
./scripts/auto-sync/development-mode.sh prod

# 3. Verify auto-sync is enabled
./scripts/auto-sync/development-mode.sh status
```

## 🚨 **Important Notes**

### **Development Mode**
- ✅ **Safe for development** - no overwrites
- ❌ **No automatic updates** - manual sync needed
- ✅ **Full control** over when updates happen
- ⚠️ **Remember to re-enable** for production

### **Inbox Sync**
- ✅ **Independent of main auto-sync** - no conflicts
- ✅ **Automatic GitHub sync** - no manual commits needed
- ✅ **Easy file transfer** - just drop and go
- ⚠️ **Files are committed** - make sure they're ready

## 🎯 **Real-World Examples**

### **Example 1: Development Session**
```bash
# Start development
ssh root@nxcore.tail79107c.ts.net
cd /srv/core
./scripts/auto-sync/development-mode.sh dev

# Make changes
nano configs/landing/index.html
# ... edit the landing page ...

# Test changes
docker-compose -f docker/compose-landing.yml restart landing

# Transfer config file from Windows
# (From Windows) scp config.json root@nxcore.tail79107c.ts.net:/srv/core/inbox/

# Commit and push when ready
git add .
git commit -m "Updated landing page and config"
git push origin master

# Re-enable production mode
./scripts/auto-sync/development-mode.sh prod
```

### **Example 2: Quick File Transfer**
```bash
# From Windows - transfer a script
scp C:\scripts\new-script.sh root@nxcore.tail79107c.ts.net:/srv/core/inbox/

# File is automatically synced to GitHub!
# No need to SSH in or commit manually
```

### **Example 3: Emergency Fix**
```bash
# Emergency situation - need to fix something
ssh root@nxcore.tail79107c.ts.net
cd /srv/core

# Disable auto-sync to prevent overwrites
./scripts/auto-sync/development-mode.sh dev

# Make emergency fix
nano docker/compose-portainer.yml
# ... fix the issue ...

# Test the fix
docker-compose -f docker/compose-portainer.yml restart portainer

# Commit the fix
git add .
git commit -m "Emergency fix: portainer configuration"
git push origin master

# Re-enable auto-sync
./scripts/auto-sync/development-mode.sh prod
```

## 🔧 **Troubleshooting**

### **Auto-Sync Still Running**
```bash
# Check service status
systemctl status nxcore-webhook.service
systemctl status nxcore-cron-sync.timer

# Force stop if needed
systemctl stop nxcore-webhook.service
systemctl stop nxcore-cron-sync.timer
```

### **Inbox Sync Not Working**
```bash
# Check service status
./scripts/auto-sync/inbox-sync.sh status

# Check logs
journalctl -u nxcore-inbox-sync.service -f

# Manual sync
./scripts/auto-sync/inbox-sync.sh sync
```

### **Files Not Syncing**
```bash
# Check inbox directory
ls -la /srv/core/inbox/

# Check git status
cd /srv/core
git status

# Manual sync
./scripts/auto-sync/inbox-sync.sh sync
```

## 🎉 **Benefits**

### **For Development**
- ✅ **No lost work** during development
- ✅ **Full control** over updates
- ✅ **Easy file transfers** from Windows
- ✅ **Safe testing** of local changes

### **For Production**
- ✅ **Automatic updates** when enabled
- ✅ **Consistent deployment** across servers
- ✅ **Easy file sharing** via inbox
- ✅ **Version control** of all changes

### **For Team Collaboration**
- ✅ **Shared development workflow**
- ✅ **Easy file transfers** between team members
- ✅ **Consistent environment** management
- ✅ **Clear development/production** separation

## 🚀 **Getting Started**

1. **SSH into your server**
2. **Enable development mode**: `./scripts/auto-sync/development-mode.sh dev`
3. **Set up inbox sync**: `./scripts/auto-sync/inbox-sync.sh setup-service`
4. **Start developing** - your changes are safe!
5. **Use inbox** for easy file transfers
6. **Re-enable production mode** when ready

**Your development workflow is now safe and efficient!** 🎯
