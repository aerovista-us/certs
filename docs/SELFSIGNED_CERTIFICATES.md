# Self-Signed Certificates Setup

This guide explains how to generate and deploy self-signed certificates for NXCore services.

## Overview

Self-signed certificates provide HTTPS encryption for your services without needing a certificate authority. They're perfect for internal/private networks like Tailscale.

## Quick Start

### 1. Generate Certificates

```powershell
# From D:\NeXuS\NXCore-Control
.\scripts\ps\generate-selfsigned-certs.ps1
```

This creates:
- `certs/selfsigned/privkey.pem` - Private key
- `certs/selfsigned/fullchain.pem` - Certificate
- `certs/selfsigned/combined.pem` - Combined (for some apps)
- `certs/selfsigned/cert.conf` - OpenSSL config

### 2. Deploy to Server

```powershell
.\scripts\ps\deploy-selfsigned-certs.ps1
```

This will:
- Copy certificates to `/opt/nexus/traefik/certs/` on the server
- Set proper permissions
- Restart Traefik
- Verify deployment

### 3. Import Certificate to Browser

**Windows:**
1. Double-click `certs\selfsigned\fullchain.pem`
2. Click "Install Certificate"
3. Select "Local Machine" → Next
4. Select "Place all certificates in the following store"
5. Browse → "Trusted Root Certification Authorities" → OK
6. Finish

**Chrome:**
1. Settings → Privacy and security → Security
2. Manage certificates → Trusted Root Certification Authorities
3. Import → Select `fullchain.pem`

**Firefox:**
1. Settings → Privacy & Security → Certificates
2. View Certificates → Authorities
3. Import → Select `fullchain.pem`
4. Trust for websites

**Edge:**
1. Settings → Privacy, search, and services → Security
2. Manage certificates → Trusted Root Certification Authorities
3. Import → Select `fullchain.pem`

## Certificate Details

The generated certificate includes:

**Subject Alternative Names (SANs):**
- DNS: `nxcore.tail79107c.ts.net`
- DNS: `*.nxcore.tail79107c.ts.net` (wildcard)
- IP: `100.115.9.61`
- IP: `127.0.0.1`

**Validity:** 365 days (configurable with `-ValidDays`)

## Custom Configuration

### Change Domain or IP

```powershell
.\scripts\ps\generate-selfsigned-certs.ps1 `
    -Domain "custom.domain.com" `
    -IP "192.168.1.100" `
    -ValidDays 730
```

### Different Output Directory

```powershell
.\scripts\ps\generate-selfsigned-certs.ps1 `
    -OutputDir "C:\MyCerts"
```

## Traefik Configuration

The certificates are automatically loaded via `tailscale-certs.yml`:

```yaml
tls:
  certificates:
    - certFile: /etc/traefik/certs/fullchain.pem
      keyFile: /etc/traefik/certs/privkey.pem
```

This file is dynamically loaded by Traefik from `/opt/nexus/traefik/dynamic/`.

## Troubleshooting

### Certificate Not Trusted

**Symptom:** Browser shows "Not Secure" or "Certificate Error"

**Solution:** Import the certificate to your browser/system trust store (see step 3 above)

### Certificate Path Error

**Symptom:** Traefik logs show `unable to generate TLS certificate`

**Solution:** Verify certificate paths:
```bash
ssh glyph@100.115.9.61 "sudo ls -lh /opt/nexus/traefik/certs/"
```

Should show:
- `fullchain.pem` (readable by all)
- `privkey.pem` (readable by root only)

### Traefik Not Restarting

**Symptom:** Old certificates still in use

**Solution:** Force restart:
```bash
ssh glyph@100.115.9.61 "sudo docker restart traefik && sudo docker logs -f traefik"
```

### OpenSSL Not Found

**Symptom:** Script fails with "OpenSSL not found"

**Solutions:**
1. Install via Chocolatey (script does this automatically)
2. Or download from: https://slproweb.com/products/Win32OpenSSL.html
3. Or use Git Bash (includes OpenSSL)

## Renewing Certificates

Self-signed certificates don't auto-renew. To renew:

1. Generate new certificates:
   ```powershell
   .\scripts\ps\generate-selfsigned-certs.ps1 -ValidDays 365
   ```

2. Deploy to server:
   ```powershell
   .\scripts\ps\deploy-selfsigned-certs.ps1
   ```

3. Re-import to browsers (if needed)

## Security Considerations

### Pros
- ✅ Full encryption (same as CA-signed certs)
- ✅ No external dependencies
- ✅ Perfect for private networks
- ✅ Free and unlimited

### Cons
- ❌ Browser warnings for non-imported users
- ❌ Not suitable for public websites
- ❌ Manual trust required on each device
- ❌ No automatic renewal

### Best For
- Tailscale/VPN networks
- Internal dashboards
- Development environments
- Home labs

### Not Recommended For
- Public-facing websites
- Production systems accessible from internet
- Services requiring universal trust

## Alternative: Let's Encrypt

For public domains, consider Let's Encrypt instead:
- See `docs/LETSENCRYPT_SETUP.md` (if available)
- Automatic renewal
- Universal trust
- Requires public DNS

## Files Modified

When setting up self-signed certificates, these files are involved:

1. **Generated locally:**
   - `certs/selfsigned/privkey.pem`
   - `certs/selfsigned/fullchain.pem`

2. **Deployed to server:**
   - `/opt/nexus/traefik/certs/privkey.pem`
   - `/opt/nexus/traefik/certs/fullchain.pem`

3. **Traefik config (already configured):**
   - `docker/tailscale-certs.yml` → `/opt/nexus/traefik/dynamic/tailscale-certs.yml`

## Quick Commands

```powershell
# Generate and deploy in one go
.\scripts\ps\generate-selfsigned-certs.ps1
.\scripts\ps\deploy-selfsigned-certs.ps1

# Check certificate on server
ssh glyph@100.115.9.61 "sudo openssl x509 -in /opt/nexus/traefik/certs/fullchain.pem -text -noout | grep -E 'Subject:|Not'"

# View Traefik logs
ssh glyph@100.115.9.61 "sudo docker logs --tail 50 traefik"

# Test HTTPS
curl -k https://nxcore.tail79107c.ts.net/traefik/
```

## Resources

- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [Traefik TLS Configuration](https://doc.traefik.io/traefik/https/tls/)
- [Understanding X.509 Certificates](https://en.wikipedia.org/wiki/X.509)

