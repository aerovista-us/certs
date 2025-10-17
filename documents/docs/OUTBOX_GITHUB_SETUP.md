# Outbox → GitHub Worker Setup

## Overview

This system provides a commit-only whitelist for publishing artifacts from `/srv/exchange/outbox/` to the `exchange-outbox` branch on GitHub.

## Components

### 1. Push Script (`scripts/push_outbox.sh`)

- Syncs `/srv/exchange/outbox/` → `/srv/core/nxcore/state/outbox/`
- Safety scans for secrets and sensitive data
- File type and size controls
- Commits to `exchange-outbox` branch

### 2. Systemd Service & Timer

- **Service**: `systemd/exchange-outbox.service`
- **Timer**: `systemd/exchange-outbox.timer` (every 15 minutes)
- Runs as user `glyph`

### 3. N8N Functions

- `n8n/functions/csv-processor.js` - CSV file processing
- `n8n/functions/image-processor.js` - Image file processing  
- `n8n/functions/document-processor.js` - Document processing
- `n8n/functions/archive-processor.js` - Archive processing

### 4. Monitoring & Guardrails

- `scripts/monitor_disk_usage.sh` - Disk usage alerts
- `scripts/quarantine_unknown.sh` - Unknown file quarantine

## Setup Instructions

### Quick Installation (Recommended)

```bash
# One-command complete setup
sudo /srv/core/nxcore/scripts/install_complete_system.sh
```

### Manual Installation

#### 1. Make Scripts Executable

```bash
chmod +x /srv/core/nxcore/scripts/push_outbox.sh
chmod +x /srv/core/nxcore/scripts/watch_inbox.sh
chmod +x /srv/core/nxcore/scripts/monitor_disk_usage.sh
chmod +x /srv/core/nxcore/scripts/quarantine_unknown.sh
chmod +x /srv/core/nxcore/scripts/setup_shipping_receiving.sh
chmod +x /srv/core/nxcore/scripts/test_shipping_receiving.sh
```

#### 2. Install Systemd Services

```bash
sudo cp systemd/exchange-inbox.service /etc/systemd/system/
sudo cp systemd/exchange-inbox.path /etc/systemd/system/
sudo cp systemd/exchange-outbox.service /etc/systemd/system/
sudo cp systemd/exchange-outbox.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now exchange-inbox.service exchange-inbox.path exchange-outbox.timer
```

#### 3. Manual Testing

```bash
# Test the complete system
/srv/core/nxcore/scripts/test_shipping_receiving.sh

# Test individual components
systemctl start exchange-outbox.service
systemctl start exchange-inbox.service

# Check logs
journalctl -u exchange-inbox.service -f
journalctl -u exchange-outbox.service -f
```

## File Type Controls

### Allowed Extensions
- `.md`, `.txt`, `.json`, `.csv`
- `.yaml`, `.yml`
- `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`, `.svg`
- `.log.gz`, `.zip`

### Size Limits
- **Max file size**: 25MB
- **Max total outbox**: 300MB

## Security Features

- Secret detection (private keys, passwords, tokens)
- File type whitelist
- Size limits
- Quarantine for unknown files

## GitHub Branch Structure

- `main` → Normal repository content
- `ops-state` → Internal reports/log digests
- `exchange-outbox` → Published artifacts from outbox

## Monitoring

```bash
# Watch service logs
journalctl -u exchange-outbox.service -f

# Check recent logs
journalctl -u exchange-outbox.service -n 200 --no-pager

# Monitor disk usage
./scripts/monitor_disk_usage.sh
```

## Troubleshooting

### Common Issues

1. **SSH Key Problems**
   - Ensure `~/.ssh/id_ed25519_github_push` exists
   - Check key permissions: `chmod 600 ~/.ssh/id_ed25519_github_push`

2. **Permission Issues**
   - Ensure user `glyph` has access to `/srv/exchange/outbox/`
   - Check working directory permissions

3. **Git Issues**
   - Verify repository is clean: `git status`
   - Check branch exists: `git branch -a`

### Debug Commands

```bash
# Test rsync manually
rsync -a --delete /srv/exchange/outbox/ /srv/core/nxcore/state/outbox/

# Check git status
cd /srv/core/nxcore && git status

# Test SSH connection
ssh -i ~/.ssh/id_ed25519_github_push -T git@github.com
```
