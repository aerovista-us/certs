param(
  [ValidateSet('n8n','filebrowser','all')]
  [string]$Service='all'
)

$ErrorActionPreference = 'Stop'
$HostName = '192.168.7.209'
$User = 'glyph'

function Run-SSH($cmd){
  ssh "$User@$HostName" $cmd
}

function Push-File($src,$dst){
  scp $src "$User@$HostName:$dst"
}

if ($Service -eq 'n8n' -or $Service -eq 'all'){
  Push-File "docker/compose-n8n.yml" "/srv/core/compose-n8n.yml"
  Run-SSH "sudo docker compose -f /srv/core/compose-n8n.yml up -d"
}

if ($Service -eq 'filebrowser' -or $Service -eq 'all'){
  Push-File "docker/compose-filebrowser.yml" "/srv/core/compose-filebrowser.yml"
  Run-SSH "sudo docker compose -f /srv/core/compose-filebrowser.yml up -d"
}

Write-Host "✅ Deployment done."
