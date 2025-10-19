
#!/usr/bin/env python3
# AeroVista Smart Cert Installer (cross-platform)
import os, sys, json, subprocess, platform, shutil, glob
from pathlib import Path

def log(msg): print(f"[AV-CERT] {msg}")

def read_config(cfg_path):
    with open(cfg_path, "r", encoding="utf-8") as f:
        return json.load(f)

def which(cmd):
    return shutil.which(cmd) is not None

def detect_active_browser():
    sysname = platform.system()
    procs = ""
    default_hint = ""
    try:
        if sysname == "Windows":
            result = subprocess.run(["powershell","-NoProfile","-Command","Get-Process | Select-Object -ExpandProperty Name"], capture_output=True, text=True)
            procs = result.stdout.lower()
            reg = subprocess.run(["powershell","-NoProfile","-Command", '(Get-ItemProperty \"HKCU:\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice\").ProgId'], capture_output=True, text=True).stdout.lower()
            default_hint = reg.strip()
        elif sysname == "Darwin":
            result = subprocess.run(["ps","-A","-o","comm"], capture_output=True, text=True)
            procs = result.stdout.lower()
            # Best-effort: default browser is usually Safari unless changed; we don't need exact value here
            default_hint = ""
        else:  # Linux
            result = subprocess.run(["ps","-A","-o","comm"], capture_output=True, text=True)
            procs = result.stdout.lower()
            default_hint = subprocess.run(["xdg-settings","get","default-web-browser"], capture_output=True, text=True).stdout.lower().strip() if which("xdg-settings") else ""
    except Exception:
        pass
    if "firefox" in procs or "firefox" in default_hint: return "firefox"
    if "chrome" in procs or "google-chrome" in default_hint or "chromium" in procs or "chromium" in default_hint: return "chrome"
    if "msedge" in procs or "microsoft-edge" in default_hint or "edge" in procs: return "edge"
    if "safari" in procs: return "safari"
    return "unknown"

def windows_install(cfg):
    log("Detected Windows")
    cert_store_scope = "Cert:\\CurrentUser\\My" if cfg.get("install_scope","user")=="user" else "Cert:\\LocalMachine\\My"
    # Import Root/Intermediate and client PFX
    ps_commands = f'''
$ErrorActionPreference="Stop"
Write-Host "[AV] Importing Root CA..."
Import-Certificate -FilePath "{cfg['ca_cert_path']}" -CertStoreLocation Cert:\\LocalMachine\\Root | Out-Null
if ("{cfg.get('intermediate_cert_path','')}".Length -gt 0) {{
  Write-Host "[AV] Importing Intermediate CA..."
  Import-Certificate -FilePath "{cfg.get('intermediate_cert_path','')}" -CertStoreLocation Cert:\\LocalMachine\\CA | Out-Null
}}
Write-Host "[AV] Importing client PFX..."
$pwd = ConvertTo-SecureString "{cfg['client_pfx_password']}" -AsPlainText -Force
Import-PfxCertificate -FilePath "{cfg['client_pfx_path']}" -CertStoreLocation "{cert_store_scope}" -Password $pwd -Exportable:${'false' if cfg.get('non_exportable_private_key', True) else 'true'} | Out-Null
'''
    subprocess.run(["powershell","-NoProfile","-ExecutionPolicy","Bypass","-Command", ps_commands], check=True)

    if cfg.get("allow_browser_auto_select_policy", True) and cfg.get("auto_select_urls"):
        import json as _json
        policy_json = [{"pattern": u, "filter": {"ISSUER": {"CN": "AeroVista"}}} for u in cfg["auto_select_urls"]]
        pj = _json.dumps(policy_json).replace('"','\\"')
        ps_policy = f'''
New-Item -Path "HKLM:\\Software\\Policies\\Google\\Chrome" -Force | Out-Null
New-ItemProperty -Path "HKLM:\\Software\\Policies\\Google\\Chrome" -Name "AutoSelectCertificateForUrls" -Value "{pj}" -PropertyType String -Force | Out-Null
New-Item -Path "HKLM:\\Software\\Policies\\Microsoft\\Edge" -Force | Out-Null
New-ItemProperty -Path "HKLM:\\Software\\Policies\\Microsoft\\Edge" -Name "AutoSelectCertificateForUrls" -Value "{pj}" -PropertyType String -Force | Out-Null
'''
        subprocess.run(["powershell","-NoProfile","-ExecutionPolicy","Bypass","-Command", ps_policy], check=True)

    log("Windows install completed.")

def macos_install(cfg):
    log("Detected macOS")
    subprocess.run(["sudo","security","add-trusted-cert","-d","-r","trustRoot","-k","/Library/Keychains/System.keychain", cfg["ca_cert_path"]], check=True)
    if cfg.get("intermediate_cert_path"):
        subprocess.run(["sudo","security","add-trusted-cert","-d","-k","/Library/Keychains/System.keychain", cfg["intermediate_cert_path"]], check=True)
    subprocess.run(["security","import", cfg["client_pfx_path"], "-k", os.path.expanduser("~/Library/Keychains/login.keychain-db"), "-P", cfg["client_pfx_password"], "-A"], check=True)
    log("macOS install completed.")

def find_firefox_profile_linux(hint=""):
    base = Path.home()/".mozilla"/"firefox"
    if not base.exists(): return ""
    if hint:
        cand = base / hint
        if cand.exists(): return str(cand)
    profiles = sorted([p for p in base.iterdir() if p.is_dir() and (p.name.endswith(".default") or ".default-" in p.name)])
    if profiles: return str(profiles[0])
    anyp = [p for p in base.iterdir() if p.is_dir()]
    return str(anyp[0]) if anyp else ""

def linux_install(cfg):
    log("Detected Linux")
    target = "/usr/local/share/ca-certificates/aerovista.crt"
    subprocess.run(["sudo","cp", cfg["ca_cert_path"], target], check=True)
    subprocess.run(["sudo","update-ca-certificates"], check=True)
    nssdb = Path.home()/".pki"/"nssdb"
    nssdb.mkdir(parents=True, exist_ok=True)
    if which("certutil"):
        subprocess.run(["certutil","-d", f"sql:{nssdb}", "-N","--empty-password"], check=False)
        subprocess.run(["certutil","-A","-d", f"sql:{nssdb}", "-n","AeroVista Root CA","-t","C,,","-i", cfg["ca_cert_path"]], check=True)
    else:
        log("WARN: certutil not found; install 'libnss3-tools'.")
    if which("pk12util"):
        subprocess.run(["pk12util","-i", cfg["client_pfx_path"], "-d", f"sql:{nssdb}", "-W", cfg["client_pfx_password"]], check=True)
    else:
        log("WARN: pk12util not found; install 'libnss3-tools'.")
    ff_profile = find_firefox_profile_linux(cfg.get("firefox_profile_hint",""))
    if ff_profile and which("certutil"):
        subprocess.run(["certutil","-A","-d", f"sql:{ff_profile}", "-n","AeroVista Root CA","-t","C,,","-i", cfg["ca_cert_path"]], check=False)
    if ff_profile and which("pk12util"):
        subprocess.run(["pk12util","-i", cfg["client_pfx_path"], "-d", f"sql:{ff_profile}", "-W", cfg["client_pfx_password"]], check=False)
    log("Linux install completed.")

def main():
    cfg_path = sys.argv[1] if len(sys.argv)>1 else "config.json"
    cfg = read_config(cfg_path)
    sysname = platform.system()
    browser = detect_active_browser()
    log(f"Active/default browser: {browser}")
    log(f"Using config: {cfg_path}")
    for k in ["ca_cert_path","client_pfx_path"]:
        if not Path(cfg[k]).exists():
            log(f"ERROR: File not found: {cfg[k]}")
            sys.exit(2)
    try:
        if sysname == "Windows":
            windows_install(cfg)
        elif sysname == "Darwin":
            macos_install(cfg)
        elif sysname == "Linux":
            linux_install(cfg)
        else:
            log(f"Unsupported OS: {sysname}")
            sys.exit(3)
    except subprocess.CalledProcessError as e:
        log(f"Command failed: {e}")
        sys.exit(4)
    log("Done. You may need to restart your browser.")

if __name__ == "__main__":
    main()
