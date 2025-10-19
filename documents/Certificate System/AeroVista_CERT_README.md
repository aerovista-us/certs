
# 🪪 AeroVista Certificate System
### *Smart Installer + Mystic Certificates Bundle*

Welcome to the **AeroVista Certificate System** — a fusion of security and style.  
This bundle includes two complementary parts:  
1. **Smart Installer** — an adaptive cross-platform script that installs AeroVista trust and identity certificates automatically.  
2. **Mystic Certificates** — gamified, visually stunning certificates that double as access passes, collectibles, or fan rewards.

---

## ⚙️ Part I — Smart Installer

### 💡 Overview
The **Smart Installer** detects your operating system and active browser, then installs:  
- The **Root / Intermediate CA** (trust anchor)  
- The **Client Certificate (PFX/P12)** for the current user  
- Optional browser policies so Chrome/Edge auto-select the right cert for AeroVista domains

### 🧭 Supported Platforms
| Platform | Trust Target | Browser Support |
|-----------|---------------|----------------|
| Windows | OS Certificate Store | Chrome, Edge, Firefox (optionally) |
| macOS | Keychain (System + Login) | Safari, Chrome, Firefox |
| Linux | System CA + NSS DB | Chrome, Chromium, Firefox |

---

### 🚀 Quick Start
1. **Files you need:**
   - `AeroVista-RootCA.cer` (or `.crt`)
   - `User-Gold.p12` (client identity, password-protected)

2. **Edit the configuration:**
   ```bash
   nano config.json
   ```
   Update the following:
   - `"client_pfx_password"` → your P12 password  
   - `"auto_select_urls"` → your AeroVista/NXCore domains  

3. **Run the installer:**
   ```bash
   python3 av_cert_installer.py
   ```
   - Windows → Run as **Administrator**  
   - macOS → You’ll be prompted for sudo  
   - Linux → Uses `/usr/local/share/ca-certificates` path + `update-ca-certificates`

4. **Restart your browser** when done.

---

### 🧩 Config Options
| Field | Description |
|-------|--------------|
| `ca_cert_path` | Path to your Root CA cert |
| `client_pfx_path` | Path to your client cert (.p12 / .pfx) |
| `client_pfx_password` | Decryption password |
| `install_scope` | `"user"` or `"machine"` (Windows only) |
| `auto_select_urls` | Domains that should automatically present the cert |
| `non_exportable_private_key` | Prevents exporting private key (recommended) |

---

### 🛠️ Troubleshooting
- **Chrome/Edge not prompting for cert:** restart browser, check registry keys under  
  `HKLM\Software\Policies\Google\Chrome\AutoSelectCertificateForUrls`
- **Firefox not trusted:** run again with `"firefox_profile_hint"` set.
- **Linux:** install `libnss3-tools` for Chrome/Firefox imports.

---

## 💎 Part II — Mystic Certificates (Gamified Access System)

### 🎨 Overview
The **Mystic Certificates** reimagine identity as art.  
Each certificate is a dual-layer artifact:
1. **X.509 Certificate** → actual cryptographic proof (used for optional auth)  
2. **Visual Certificate (HTML/PDF)** → stylized collectible with metadata, tier, and verification link  

Think of them as **digital badges, fan passes, or collectible access cards** within the AeroVista ecosystem.

---

### 🪩 Visual Templates
Included in the Mystic set:
| Template | Theme | Best For |
|-----------|--------|----------|
| **Legendary HoloGold** | Luxury holo sweep | Premium / Event drops |
| **Neon Circuit** | Tech-noir glow | Dev or early access passes |
| **Arcane Sigil** | Fantasy-meets-tech | Lore, fan collectibles |

Each template renders dynamically from JSON metadata, e.g.:
```json
{
  "holder": "Timbr",
  "division": "Nexus TechWorks",
  "tier_label": "Gold Tier",
  "serial": "AV-2025-GLD-00042",
  "perks": "Priority Access • Backstage • Beta Invites",
  "verify_url": "https://verify.aerovista.us/cert?id=AV-2025-GLD-00042"
}
```

Use the included `render_cert.py` to merge template + JSON → output HTML:
```bash
python3 render_cert.py legendary-hologold.html AV-GOLD-DEMO.json out.html
```

---

### 🧠 Use Cases
- **Exclusive content drops** (music, lore, dev builds)
- **Fan rewards / collector cards**
- **Division access badges** (internal teams)
- **Event “proof of attendance” certs**
- **In-world artifacts** for AeroVista games or EchoVerse events

---

### ⚖️ Security & Scope
These certs are intended for **fun and engagement**, not for critical infrastructure access.  
Keep “real” authentication (admin panels, NXCore control) on proper mTLS or OAuth.  
Use Mystic certs for:
- Visual prestige
- Collectible identity
- Lightweight proof-of-membership

---

### 💫 Integration Ideas
- Embed certificate viewer widgets into your AeroVista sites.
- Let users verify their certs at `verify.aerovista.us`.
- Add XP/progress bars based on contributions or achievements.
- Rotate seasonal cert styles (e.g., “EchoVerse Gold Record”, “SkyForge Artisan”).

---

### 🖋️ Closing Note
Together, the **Smart Installer** and **Mystic Certificates** create a seamless continuum between *security* and *experience*.  
It’s not just about trust — it’s about belonging.  

> *“Forged in the Neural Core, authenticated by light.”* — Byte ⚡
