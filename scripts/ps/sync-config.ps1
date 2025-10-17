# scripts\ps\sync-config.ps1  (PowerShell 5.1 compatible, no alias collisions)
$ErrorActionPreference = 'Stop'

# --- Config ---
$HostName = '192.168.7.209'
$User     = 'glyph'

# --- Helper: resolve tool paths in PS 5.1 ---
function Resolve-Tool {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][string]$Fallback
  )
  $cmd = $null
  try { $cmd = Get-Command $Name -ErrorAction SilentlyContinue } catch {}
  if ($cmd -and $cmd.Source) { return $cmd.Source }
  if (Test-Path $Fallback)   { return $Fallback }
  throw "$Name not found. Install OpenSSH Client: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
}

$SCP = Resolve-Tool -Name 'scp' -Fallback 'C:\Windows\System32\OpenSSH\scp.exe'
$SSH = Resolve-Tool -Name 'ssh' -Fallback 'C:\Windows\System32\OpenSSH\ssh.exe'

# --- Paths (relative to this script) ---
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path

function ResolvePathStrict([string]$Relative) {
  $full = Join-Path $Base $Relative
  if (-not (Test-Path $full)) { throw "Missing file: $full" }
  return (Resolve-Path $full).Path
}

$AgentRules   = ResolvePathStrict '..\..\agent\nxcore-agent.rules'
$AgentService = ResolvePathStrict '..\..\agent\systemd\cursor-agent.service'
$ComposeN8N   = ResolvePathStrict '..\..\docker\compose-n8n.yml'
$ComposeFB    = ResolvePathStrict '..\..\docker\compose-filebrowser.yml'

# Optional stacks (push if present)
$OptPortainer = Join-Path $Base '..\..\docker\compose-portainer.yml'
$OptWatch     = Join-Path $Base '..\..\docker\compose-watchtower.yml'
$OptRedis     = Join-Path $Base '..\..\docker\compose-redis.yml'
$OptPg        = Join-Path $Base '..\..\docker\compose-postgres.yml'

# --- Wrappers ---
function Run-SSH([string]$cmd) {
  & $SSH "$User@$HostName" $cmd
}
function Push-File([string]$src,[string]$dst) {
  $remote = "$User@$HostName`:$dst"
  & $SCP $src $remote
}

Write-Host 'Ensuring remote directories exist...'
Run-SSH 'sudo install -d -m 755 /etc /etc/systemd/system /srv/core /opt/nexus /var/log/nxcore'

Write-Host 'Pushing agent files...'
Push-File $AgentRules   '/etc/nxcore-agent.rules'
Push-File $AgentService '/etc/systemd/system/cursor-agent.service'

Write-Host 'Pushing docker compose stacks...'
Push-File $ComposeN8N '/srv/core/compose-n8n.yml'
Push-File $ComposeFB '/srv/core/compose-filebrowser.yml'

if (Test-Path $OptPortainer) { Push-File (Resolve-Path $OptPortainer).Path '/srv/core/compose-portainer.yml' }
if (Test-Path $OptWatch)     { Push-File (Resolve-Path $OptWatch).Path     '/srv/core/compose-watchtower.yml' }
if (Test-Path $OptRedis)     { Push-File (Resolve-Path $OptRedis).Path     '/srv/core/compose-redis.yml' }
if (Test-Path $OptPg)        { Push-File (Resolve-Path $OptPg).Path        '/srv/core/compose-postgres.yml' }

Write-Host 'Enabling agent service...'
Run-SSH 'sudo systemctl daemon-reload'
Run-SSH 'sudo systemctl enable cursor-agent'
Run-SSH 'sudo systemctl start cursor-agent'

Write-Host 'Sync complete.'
