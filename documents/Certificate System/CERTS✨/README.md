# AeroVista Certificate Templates (Extravagant / Gamified)

This bundle contains **three HTML templates** for visually rich, game‑styled certificates, plus a simple string‑replace renderer and example metadata.

## Files
- `legendary-hologold.html` — Legendary tier with holo‑foil sweep and progress bar
- `neon-circuit.html` — Tech‑noir neon circuit look
- `arcane-sigil.html` — Fantasy‑meets‑tech sigil card
- `assets/aerovista-logo.svg` — Shared SVG logo
- `certs/AV-GOLD-DEMO.json` — Example certificate metadata
- `scripts/render_cert.py` — Minimal renderer (replace `{{placeholders}}`)

## Quick Start
```bash
# Example render (choose any template)
python3 scripts/render_cert.py legendary-hologold.html certs/AV-GOLD-DEMO.json out-hologold.html
python3 scripts/render_cert.py neon-circuit.html certs/AV-GOLD-DEMO.json out-neon.html
python3 scripts/render_cert.py arcane-sigil.html certs/AV-GOLD-DEMO.json out-arcane.html
```

Open the resulting `out-*.html` in a browser.

> Note: These are **visual certificates** only. For real client‑TLS auth, issue X.509 certs with your CA and store them in the OS/browser keychain. The visual piece can include a QR that resolves to a verification endpoint.

## Integration Notes
- On issuance, generate both the **X.509 cert** and a **visual HTML/PDF** for the holder.
- Include: `serial`, `issued`, `expires`, `fingerprint`, and a `verify_url` pointing to your NXCore endpoint.
- You can add per‑tier palettes, badges, and “season pass” styles by forking these templates.

Enjoy!
