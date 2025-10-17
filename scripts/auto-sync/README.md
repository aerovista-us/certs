# NXCore Auto-Sync System

This directory contains the automatic synchronization system for NXCore, which keeps the server in sync with the GitHub repository.

## 🚀 Features

- **GitHub Webhooks**: Instant updates when code is pushed to GitHub
- **Cron Sync**: Periodic checks for updates (every 5 minutes by default)
- **Smart Service Restart**: Only restarts services that have changed
- **Logging**: Comprehensive logging for troubleshooting
- **Security**: Webhook signature verification for security

## 📁 Files

### Core Scripts
- `github-webhook-receiver.sh` - Receives GitHub webhooks and triggers updates
- `cron-git-sync.sh` - Periodic sync script run by systemd timer
- `setup-autosync.sh` - Installation and configuration script
- `test-autosync.sh` - Testing and validation script

### Configuration
- `webhook-config.env` - Generated configuration file (created during setup)

## 🛠️ Installation

### 1. Run the Setup Script
```bash
sudo /srv/core/scripts/auto-sync/setup-autosync.sh install
```

This will:
- Install required dependencies
- Create systemd services and timers
- Configure firewall rules
- Set up log rotation
- Generate webhook configuration

### 2. Start the Services
```bash
sudo systemctl start nxcore-webhook.service
sudo systemctl start nxcore-cron-sync.timer
```

### 3. Configure GitHub Webhook

1. Go to your GitHub repository: https://github.com/aerovista-us/nxcore
2. Navigate to **Settings** → **Webhooks** → **Add webhook**
3. Set the webhook URL: `https://nxcore.tail79107c.ts.net:8080/webhook`
4. Set content type to `application/json`
5. Copy the secret from `/srv/core/scripts/auto-sync/webhook-config.env`
6. Select "Just the push event"
7. Click "Add webhook"

## 🧪 Testing

### Run All Tests
```bash
sudo /srv/core/scripts/auto-sync/test-autosync.sh all
```

### Individual Tests
```bash
# Test webhook signature generation
sudo /srv/core/scripts/auto-sync/test-autosync.sh signature

# Test webhook receiver
sudo /srv/core/scripts/auto-sync/test-autosync.sh webhook

# Test cron sync
sudo /srv/core/scripts/auto-sync/test-autosync.sh cron

# Test service restart logic
sudo /srv/core/scripts/auto-sync/test-autosync.sh restart

# Check log files
sudo /srv/core/scripts/auto-sync/test-autosync.sh logs

# Display system status
sudo /srv/core/scripts/auto-sync/test-autosync.sh status
```

## 📊 Monitoring

### Check Service Status
```bash
# Webhook service
sudo systemctl status nxcore-webhook.service

# Cron sync timer
sudo systemctl status nxcore-cron-sync.timer

# View logs
sudo journalctl -u nxcore-webhook.service -f
sudo journalctl -u nxcore-cron-sync.service -f
```

### Log Files
- `/var/log/nxcore-autosync.log` - Webhook receiver logs
- `/var/log/nxcore-cron-sync.log` - Cron sync logs

## ⚙️ Configuration

### Environment Variables
- `GITHUB_WEBHOOK_SECRET` - Secret for webhook verification
- `WEBHOOK_PORT` - Port for webhook receiver (default: 8080)
- `SYNC_INTERVAL` - Cron sync interval in seconds (default: 300)

### Manual Operations
```bash
# Force sync (pull latest changes)
sudo /srv/core/scripts/auto-sync/cron-git-sync.sh force

# Check sync status
sudo /srv/core/scripts/auto-sync/cron-git-sync.sh status

# Manual webhook test
sudo /srv/core/scripts/auto-sync/github-webhook-receiver.sh test
```

## 🔧 Management

### Start/Stop Services
```bash
# Start auto-sync
sudo /srv/core/scripts/auto-sync/setup-autosync.sh start

# Stop auto-sync
sudo /srv/core/scripts/auto-sync/setup-autosync.sh stop

# Check status
sudo /srv/core/scripts/auto-sync/setup-autosync.sh status
```

### Uninstall
```bash
sudo /srv/core/scripts/auto-sync/setup-autosync.sh uninstall
```

## 🔒 Security

- **Webhook Signature Verification**: All webhooks are verified using HMAC-SHA256
- **Firewall Rules**: Only the webhook port is exposed
- **Service Isolation**: Services run with minimal privileges
- **Log Rotation**: Logs are automatically rotated to prevent disk space issues

## 🚨 Troubleshooting

### Common Issues

1. **Webhook not receiving updates**
   - Check if the service is running: `systemctl status nxcore-webhook.service`
   - Verify firewall rules: `ufw status`
   - Check GitHub webhook configuration

2. **Cron sync not working**
   - Check timer status: `systemctl status nxcore-cron-sync.timer`
   - View logs: `journalctl -u nxcore-cron-sync.service`

3. **Services not restarting**
   - Check Docker status: `docker info`
   - Verify compose files exist
   - Check service logs

### Debug Commands
```bash
# Test webhook manually
curl -X POST http://localhost:8080/webhook \
  -H "X-Hub-Signature-256: sha256=..." \
  -d '{"test": "data"}'

# Check git status
cd /srv/core && git status

# View recent commits
cd /srv/core && git log --oneline -10
```

## 📈 Performance

- **Webhook Response Time**: < 1 second
- **Cron Sync Interval**: 5 minutes (configurable)
- **Service Restart Time**: 10-30 seconds depending on service
- **Log Rotation**: Daily with 7-day retention

## 🔄 How It Works

1. **GitHub Push**: When code is pushed to GitHub, a webhook is sent
2. **Webhook Verification**: The webhook signature is verified for security
3. **Git Pull**: Latest changes are pulled from the repository
4. **Service Analysis**: Changed files are analyzed to determine which services need restarting
5. **Smart Restart**: Only affected services are restarted
6. **Logging**: All actions are logged for monitoring and troubleshooting

The system is designed to be reliable, secure, and efficient, ensuring your NXCore infrastructure stays up-to-date with minimal downtime.
