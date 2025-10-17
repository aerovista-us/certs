
<# 
  setup_workstation.ps1 — Windows 11 Pro
  Auto-detect + install missing MEDIA tools and FLEET clients (Syncthing, RustDesk) via winget.

  Usage (Run PowerShell as Administrator):
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\setup_workstation.ps1                    # install media + fleet (default)
    .\setup_workstation.ps1 -MediaOnly         # only media apps
    .\setup_workstation.ps1 -FleetOnly         # only Syncthing + RustDesk
    .\setup_workstation.ps1 -IncludeSubtitles  # add Aegisub if available
#>

param(
  [switch]$MediaOnly,
  [switch]$FleetOnly,
  [switch]$IncludeSubtitles
)

$ErrorActionPreference = "Continue"

function Require-Winget {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from Microsoft Store and retry."
    exit 1
  }
}
Require-Winget

# -------------------- Package catalogs --------------------

$MediaPackages = @(
  @{ Name="Kdenlive";            Id="KDE.Kdenlive" },
  @{ Name="Blender";             Id="BlenderFoundation.Blender" },
  @{ Name="OBS Studio";          Id="OBSProject.OBSStudio" },
  @{ Name="FFmpeg";              Id="Gyan.FFmpeg" },
  @{ Name="HandBrake";           Id="HandBrake.HandBrake" },
  @{ Name="MKVToolNix";          Id="MKVToolNix.MKVToolNix" },
  @{ Name="Audacity";            Id="Audacity.Audacity" },
  @{ Name="Ardour";              Id="Ardour.Ardour" },
  @{ Name="GIMP";                Id="GIMP.GIMP" },
  @{ Name="Krita";               Id="Krita.Krita" },
  @{ Name="Inkscape";            Id="Inkscape.Inkscape" },
  @{ Name="digiKam";             Id="KDE.digiKam" },
  @{ Name="Darktable";           Id="Darktable.Darktable" },
  @{ Name="MusicBrainz Picard";  Id="MusicBrainz.Picard" }
)
if ($IncludeSubtitles) {
  # Only add if a maintained package exists
  $MediaPackages += @{ Name="Aegisub"; Id="Aegisub.Aegisub" }
}

$FleetPackages = @(
  @{ Name="Syncthing"; Id="Syncthing.Syncthing" },
  @{ Name="RustDesk";  Id="RustDesk.RustDesk" }
)

# -------------------- Helpers --------------------

function Test-PackageInstalled {
  param([string]$Id)
  # winget list -e --id returns a table when found; exit code is 0 in both cases, so check output
  $out = winget list --id $Id -e 2>$null
  return ($out -match $Id)
}

function Install-Winget {
  param([string]$Name, [string]$Id)
  if (Test-PackageInstalled -Id $Id) {
    Write-Host ("[=] Present: {0}" -f $Name) -ForegroundColor DarkGray
    return
  }
  Write-Host ("[+] Installing: {0} ({1})" -f $Name, $Id) -ForegroundColor Cyan
  try {
    winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent
  } catch {
    Write-Warning ("[!] Failed: {0} — {1}" -f $Name, $_.Exception.Message)
  }
}

# -------------------- Flow control --------------------

$DoMedia = -not $FleetOnly
$DoFleet = -not $MediaOnly

$installed = New-Object System.Collections.ArrayList
$failed    = New-Object System.Collections.ArrayList

if ($DoMedia) {
  Write-Host "`n=== MEDIA TOOLS ===" -ForegroundColor Yellow
  foreach ($pkg in $MediaPackages) {
    $before = Test-PackageInstalled -Id $pkg.Id
    Install-Winget -Name $pkg.Name -Id $pkg.Id
    $after = Test-PackageInstalled -Id $pkg.Id
    if ($after) { [void]$installed.Add($pkg.Name) } else { [void]$failed.Add($pkg.Name) }
  }

  # Try to add FFmpeg bin to PATH if installed via Gyan.FFmpeg
  $ffmpegRoot = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe"
  if (Test-Path $ffmpegRoot) {
    $dirs = Get-ChildItem -Path $ffmpegRoot -Directory | Sort-Object LastWriteTime -Descending
    if ($dirs -and (Test-Path (Join-Path $dirs[0].FullName "bin"))) {
      $bin = (Join-Path $dirs[0].FullName "bin")
      if ($Env:Path -notlike "*$bin*") {
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";" + $bin, [EnvironmentVariableTarget]::Machine)
        Write-Host "[+] Added FFmpeg to PATH: $bin" -ForegroundColor Green
      }
    }
  }
}

if ($DoFleet) {
  Write-Host "`n=== FLEET CLIENTS ===" -ForegroundColor Yellow
  foreach ($pkg in $FleetPackages) {
    $before = Test-PackageInstalled -Id $pkg.Id
    Install-Winget -Name $pkg.Name -Id $pkg.Id
    $after = Test-PackageInstalled -Id $pkg.Id
    if ($after) { [void]$installed.Add($pkg.Name) } else { [void]$failed.Add($pkg.Name) }
  }

  Write-Host "`nNext steps:" -ForegroundColor Yellow
  Write-Host " - Open Syncthing and accept shares from NXCore (RO for most, RW for editors)."
  Write-Host " - Open RustDesk and set your server's ID/Relay host (NXCore RustDesk)."
}

# -------------------- Summary --------------------
Write-Host "`n=== Summary ===" -ForegroundColor Yellow
if ($installed.Count -gt 0) {
  Write-Host (" Installed/Present: {0}" -f ($installed -join ", ")) -ForegroundColor Green
}
if ($failed.Count -gt 0) {
  Write-Host (" Failed/Skipped: {0}" -f ($failed -join ", ")) -ForegroundColor Red
  Write-Host " Tip: packages may be temporarily unavailable in winget or require interactive install."
}
Write-Host "`nDone."
