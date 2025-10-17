#!/bin/bash
# AeroVista State Backup Script
# Creates a complete backup of the current working state

BACKUP_DIR="/srv/core/backups/$(date +%Y%m%d_%H%M%S)_aerovista_state"
echo "Creating backup in: $BACKUP_DIR"

# Create backup directory
sudo mkdir -p "$BACKUP_DIR"

# 1. Backup all compose files
echo "Backing up compose files..."
sudo cp -r /srv/core/compose-*.yml "$BACKUP_DIR/" 2>/dev/null || echo "No compose files found"

# 2. Backup all configuration files
echo "Backing up configuration files..."
sudo cp -r /srv/core/config "$BACKUP_DIR/" 2>/dev/null || echo "No config directory found"
sudo cp -r /opt/nexus "$BACKUP_DIR/" 2>/dev/null || echo "No nexus directory found"

# 3. Backup all data volumes
echo "Backing up data volumes..."
sudo cp -r /srv/core/data "$BACKUP_DIR/" 2>/dev/null || echo "No data directory found"

# 4. Backup container state
echo "Backing up container state..."
sudo docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' > "$BACKUP_DIR/containers.txt"
sudo docker network ls > "$BACKUP_DIR/networks.txt"
sudo docker volume ls > "$BACKUP_DIR/volumes.txt"

# 5. Backup system info
echo "Backing up system info..."
uname -a > "$BACKUP_DIR/system_info.txt"
df -h > "$BACKUP_DIR/disk_usage.txt"
free -h > "$BACKUP_DIR/memory_usage.txt"

# 6. Backup Tailscale info
echo "Backing up Tailscale info..."
tailscale status > "$BACKUP_DIR/tailscale_status.txt" 2>/dev/null || echo "Tailscale not available"
ls -la /var/lib/tailscale/certs/ > "$BACKUP_DIR/tailscale_certs.txt" 2>/dev/null || echo "No Tailscale certs found"

# 7. Create restore script
echo "Creating restore script..."
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
# AeroVista State Restore Script
# WARNING: This will overwrite current state!

echo "WARNING: This will restore AeroVista to the backed up state!"
echo "Current containers will be stopped and removed!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 1
fi

# Stop all containers
echo "Stopping all containers..."
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true

# Remove networks
echo "Removing networks..."
sudo docker network rm gateway backend observability 2>/dev/null || true

# Restore files
echo "Restoring files..."
sudo cp -r compose-*.yml /srv/core/ 2>/dev/null || echo "No compose files to restore"
sudo cp -r config /srv/core/ 2>/dev/null || echo "No config to restore"
sudo cp -r nexus /opt/ 2>/dev/null || echo "No nexus to restore"
sudo cp -r data /srv/core/ 2>/dev/null || echo "No data to restore"

# Set permissions
sudo chown -R glyph:glyph /srv/core /opt/nexus

echo "Restore complete. You can now redeploy services."
EOF

chmod +x "$BACKUP_DIR/restore.sh"

# 8. Create deployment summary
echo "Creating deployment summary..."
cat > "$BACKUP_DIR/DEPLOYMENT_SUMMARY.md" << EOF
# AeroVista Deployment Backup - $(date)

## Current State
- **Backup Date:** $(date)
- **Total Containers:** $(sudo docker ps -q | wc -l)
- **Networks:** gateway, backend, observability
- **Services Running:** $(sudo docker ps --format '{{.Names}}' | tr '\n' ', ')

## Services Status
$(sudo docker ps --format '- {{.Names}}: {{.Status}}')

## Networks
$(sudo docker network ls --format '- {{.Name}}: {{.Driver}}')

## Disk Usage
$(df -h /)

## Memory Usage
$(free -h)

## How to Restore
1. Copy this backup directory to NXCore
2. Run: \`bash restore.sh\`
3. Redeploy services using the PowerShell script

## Next Steps
- Phase B: Browser Workspaces
- Phase D: Data & Storage  
- Phase F: Media Services
EOF

# Set ownership
sudo chown -R glyph:glyph "$BACKUP_DIR"

echo "✅ Backup complete: $BACKUP_DIR"
echo "📁 Backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"
echo "🔄 To restore: bash $BACKUP_DIR/restore.sh"
