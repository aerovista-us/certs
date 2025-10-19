# AeroVista Smart Certificate Installer

A cross‑platform, **smart** script that detects OS and active/default browser, then installs:
- Your **Root/Intermediate CA** into the appropriate trust store
- A **client identity certificate** (PFX/P12) into the right user store / browser DB

## Contents
- `av_cert_installer.py` — main script (Python 3.8+)
- `config.json` — paths and options (edit this)
- *(You provide your own)* `AeroVista-RootCA.cer` / `.crt` and `User-Gold.p12`

## Quick Start
1. Put your files in the same folder as the script:
   - `AeroVista-RootCA.cer` (or `.crt`)
   - `User-Gold.p12` (your client identity) + update `client_pfx_password` in `config.json`
2. Edit `config.json` if needed (scope, Firefox hint, policy URLs).
3. Run:
```bash
python3 av_cert_installer.py
```
   - On Windows, run from an **elevated** PowerShell/Terminal for machine-trust.
   - On macOS, you'll be prompted for sudo when trusting the Root CA to System.
   - On Linux, this uses Debian/Ubuntu trust path; adjust for your distro if needed.

## What it does (per OS)
### Windows (Chrome/Edge use OS store; Firefox can read OS or its own profile)
- Imports Root CA to `LocalMachine\Root` (or CurrentUser scope if you adapt)
- Imports PFX into `CurrentUser\My` (non-exportable by default)
- Optionally sets Chromium/Edge **AutoSelectCertificateForUrls** policy for your domains

### macOS
- Trusts Root CA in System keychain
- Imports P12 into login keychain and allows apps (Keychain ACL)

### Linux
- Adds Root CA to system trust (`/usr/local/share/ca-certificates` + `update-ca-certificates`)
- Imports Root + P12 into **Chrome/Chromium** NSS DB (`~/.pki/nssdb`) if tools present
- Attempts Firefox profile import if a profile is found

## Detecting the Active/Default Browser
The script checks running processes and default browser settings:
- Windows: running processes + registry `UserChoice`
- macOS: running processes (best‑effort; Safari if nothing else)
- Linux: running processes + `xdg-settings` if available

It uses this info to inform logging and to decide Firefox profile imports.

## Safety Notes
- **Only use on devices you own or manage, with user consent.**
- Keep your CA private keys secure (offline ideally). This installer never handles CA private keys.
- Client PFX should be **password-protected** and **non-exportable** where supported.
- Consider short certificate lifetimes and automated renewal + revocation lists.

## Troubleshooting
- Chrome/Edge still not presenting cert? Restart browser. On Windows, verify policy keys:
  - `HKLM\Software\Policies\Google\Chrome\AutoSelectCertificateForUrls`
  - `HKLM\Software\Policies\Microsoft\Edge\AutoSelectCertificateForUrls`
- On Linux, install `libnss3-tools` for `certutil`/`pk12util`:
  ```bash
  sudo apt-get install -y libnss3-tools
  ```
- Firefox not found? Provide a `firefox_profile_hint` in `config.json`.

— Byte
