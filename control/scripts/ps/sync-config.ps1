$ErrorActionPreference = 'Stop'
$HostName = '192.168.7.209'
$User = 'glyph'

# Push agent configs
scp "agent/nxcore-agent.rules" "$User@$HostName:/etc/nxcore-agent.rules"
scp "agent/systemd/cursor-agent.service" "$User@$HostName:/etc/systemd/system/cursor-agent.service"
ssh "$User@$HostName" "sudo systemctl daemon-reload && sudo systemctl enable --now cursor-agent"

# Push docker files
scp "docker/compose-n8n.yml" "$User@$HostName:/srv/core/compose-n8n.yml"
scp "docker/compose-filebrowser.yml" "$User@$HostName:/srv/core/compose-filebrowser.yml"

Write-Host '✅ Sync complete.'
