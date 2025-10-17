# 🚀 NXCore Auto-Sync Deployment Guide

This guide will help you deploy the automatic synchronization system on your NXCore server to keep it in sync with the GitHub repository.

## 📋 Prerequisites

- NXCore server with root access
- GitHub repository: `https://github.com/aerovista-us/nxcore`
- Docker and Docker Compose installed
- Git installed on the server

## 🛠️ Step 1: Deploy Auto-Sync System

### SSH into your NXCore server:
```bash
ssh root@nxcore.tail79107c.ts.net
```

### Navigate to the repository directory:
```bash
cd /srv/core
```

### Pull the latest changes (including auto-sync scripts):
```bash
git pull origin master
```

### Make the setup script executable:
```bash
chmod +x scripts/auto-sync/setup-autosync.sh
```

### Run the auto-sync setup:
```bash
sudo ./scripts/auto-sync/setup-autosync.sh install
```

This will:
- ✅ Install required dependencies (netcat, openssl)
- ✅ Create systemd services for webhook receiver and cron sync
- ✅ Configure firewall rules (opens port 8080)
- ✅ Set up log rotation
- ✅ Generate webhook configuration

## 🎯 Step 2: Start Auto-Sync Services

### Start the services:
```bash
sudo systemctl start nxcore-webhook.service
sudo systemctl start nxcore-cron-sync.timer
```

### Enable services to start on boot:
```bash
sudo systemctl enable nxcore-webhook.service
sudo systemctl enable nxcore-cron-sync.timer
```

### Verify services are running:
```bash
sudo systemctl status nxcore-webhook.service
sudo systemctl status nxcore-cron-sync.timer
```

## 🔗 Step 3: Configure GitHub Webhook

### 1. Get the webhook configuration:
```bash
cat /srv/core/scripts/auto-sync/webhook-config.env
```

This will show you:
- Webhook URL: `https://nxcore.tail79107c.ts.net:8080/webhook`
- Webhook Secret: `nxcore-autosync-[timestamp]`

### 2. Configure GitHub Webhook:

1. Go to: https://github.com/aerovista-us/nxcore/settings/hooks
2. Click **"Add webhook"**
3. Set **Payload URL**: `https://nxcore.tail79107c.ts.net:8080/webhook`
4. Set **Content type**: `application/json`
5. Set **Secret**: Copy the secret from the config file
6. Select **"Just the push event"**
7. Click **"Add webhook"**

## 🧪 Step 4: Test the Auto-Sync System

### Run comprehensive tests:
```bash
sudo /srv/core/scripts/auto-sync/test-autosync.sh all
```

### Test individual components:
```bash
# Test webhook receiver
sudo /srv/core/scripts/auto-sync/test-autosync.sh webhook

# Test cron sync
sudo /srv/core/scripts/auto-sync/test-autosync.sh cron

# Check system status
sudo /srv/core/scripts/auto-sync/test-autosync.sh status
```

## 📊 Step 5: Monitor the System

### Check service status:
```bash
# Webhook service
sudo systemctl status nxcore-webhook.service

# Cron sync timer
sudo systemctl status nxcore-cron-sync.timer
```

### View logs:
```bash
# Webhook logs
sudo journalctl -u nxcore-webhook.service -f

# Cron sync logs
sudo journalctl -u nxcore-cron-sync.service -f

# Log files
tail -f /var/log/nxcore-autosync.log
tail -f /var/log/nxcore-cron-sync.log
```

## 🔄 How Auto-Sync Works

### Instant Updates (Webhook)
1. **Push to GitHub** → Webhook sent to server
2. **Signature Verification** → Security check
3. **Git Pull** → Latest changes downloaded
4. **Service Analysis** → Determine what needs restarting
5. **Smart Restart** → Only restart affected services

### Periodic Sync (Cron)
1. **Every 5 minutes** → Check for new commits
2. **If updates found** → Pull and restart services
3. **If no updates** → Skip sync

### Smart Service Restart
- **Docker Compose changes** → Restart affected services
- **Traefik config changes** → Restart Traefik
- **Landing page changes** → Restart landing service
- **Certificate changes** → Restart Traefik

## 🛠️ Management Commands

### Start/Stop Auto-Sync:
```bash
# Start
sudo /srv/core/scripts/auto-sync/setup-autosync.sh start

# Stop
sudo /srv/core/scripts/auto-sync/setup-autosync.sh stop

# Status
sudo /srv/core/scripts/auto-sync/setup-autosync.sh status
```

### Manual Operations:
```bash
# Force sync (pull latest changes)
sudo /srv/core/scripts/auto-sync/cron-git-sync.sh force

# Check sync status
sudo /srv/core/scripts/auto-sync/cron-git-sync.sh status

# Test webhook manually
sudo /srv/core/scripts/auto-sync/github-webhook-receiver.sh test
```

## 🚨 Troubleshooting

### Webhook Not Working:
```bash
# Check if service is running
sudo systemctl status nxcore-webhook.service

# Check firewall
sudo ufw status

# Test webhook endpoint
curl -X POST http://localhost:8080/webhook
```

### Cron Sync Not Working:
```bash
# Check timer status
sudo systemctl status nxcore-cron-sync.timer

# Check logs
sudo journalctl -u nxcore-cron-sync.service

# Run manual sync
sudo /srv/core/scripts/auto-sync/cron-git-sync.sh check
```

### Services Not Restarting:
```bash
# Check Docker
docker info

# Check compose files
ls -la /srv/core/docker/compose-*.yml

# Test service restart
sudo /srv/core/scripts/auto-sync/test-autosync.sh restart
```

## 🔒 Security Features

- **Webhook Signature Verification**: HMAC-SHA256 verification
- **Firewall Protection**: Only webhook port (8080) exposed
- **Service Isolation**: Minimal privileges
- **Log Rotation**: Automatic log cleanup

## 📈 Performance

- **Webhook Response**: < 1 second
- **Sync Interval**: 5 minutes (configurable)
- **Service Restart**: 10-30 seconds
- **Log Retention**: 7 days

## 🎉 Success!

Once deployed, your NXCore server will automatically:
- ✅ Pull updates from GitHub when you push changes
- ✅ Restart only the services that need updating
- ✅ Log all activities for monitoring
- ✅ Maintain security with signature verification

## 📞 Support

If you encounter issues:
1. Check the logs: `/var/log/nxcore-autosync.log`
2. Run tests: `sudo /srv/core/scripts/auto-sync/test-autosync.sh all`
3. Check service status: `sudo systemctl status nxcore-webhook.service`

The auto-sync system is now ready to keep your NXCore infrastructure automatically updated! 🚀
