$ErrorActionPreference = 'Stop'
$HostName = '192.168.7.209'
$User = 'glyph'
$Date = Get-Date -Format 'yyyyMMdd-HHmmss'
$LocalDir = "backups\nxcore-$Date"
New-Item -ItemType Directory -Force -Path $LocalDir | Out-Null

# Pull key config files
scp "$User@$HostName:/etc/nxcore-agent.rules" "$LocalDir\"
scp "$User@$HostName:/etc/systemd/system/cursor-agent.service" "$LocalDir\"
scp "$User@$HostName:/srv/core/compose-*.yml" "$LocalDir\"

Write-Host "✅ Backup saved to $LocalDir"
