#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# AeroVista Internal CA + Server Cert Generator
# =============================================================================
# This script generates:
#   - Root CA (keep key offline!)
#   - Intermediate CA (for routine signing)
#   - One server certificate covering internal hosts via SANs
# Adjust SAN hosts at bottom or provide a custom hosts file.
# =============================================================================

ROOT_DAYS=3650
INT_DAYS=1825
SERVER_DAYS=825

ORG="AeroVista LLC"
ST="Idaho"
L="Coeur d'Alene"
C="US"
OU_ROOT="SecOps"
OU_INT="SecOps"
ROOT_CN="AeroVista ROOT CA"
INT_CN="AeroVista INT CA"
DEFAULT_CN="traefik.nxcore.tail79107c.ts.net"

OUTDIR="${1:-./out}"
HOSTS_FILE="${2:-./hosts.txt}"

mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "[i] Output dir: $(pwd)"
echo "[i] Hosts file: $HOSTS_FILE"

if [[ ! -f "$HOSTS_FILE" ]]; then
  cat > "$HOSTS_FILE" <<'EOF'
# One hostname per line. Comment lines (#) are ignored.
traefik.nxcore.tail79107c.ts.net
grafana.nxcore.tail79107c.ts.net
portainer.nxcore.tail79107c.ts.net
files.nxcore.tail79107c.ts.net
status.nxcore.tail79107c.ts.net
# Optional private zone names:
traefik.internal.av
grafana.internal.av
portainer.internal.av
EOF
  echo "[i] Created default hosts.txt. Edit and re-run if needed."
fi

# Build SAN list from hosts file
DNS_ENTRIES=()
i=1
while read -r line; do
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^# ]] && continue
  DNS_ENTRIES+=("DNS.${i} = $line")
  ((i++))
done < "$HOSTS_FILE"

SAN_BLOCK=$(printf "%s\n" "${DNS_ENTRIES[@]}")

# ------------------- Root CA -------------------
if [[ ! -f av-root-ca.key ]]; then
  openssl genrsa -out av-root-ca.key 4096
  openssl req -x509 -new -nodes -key av-root-ca.key -sha256 -days "$ROOT_DAYS" -out av-root-ca.crt     -subj "/C=$C/ST=$ST/L=$L/O=$ORG/OU=$OU_ROOT/CN=$ROOT_CN"
  echo "[✓] Root CA generated: av-root-ca.crt (KEEP av-root-ca.key OFFLINE!)"
else
  echo "[i] Root CA already exists; skipping."
fi

# ---------------- Intermediate CA ----------------
if [[ ! -f av-int-ca.key ]]; then
  openssl genrsa -out av-int-ca.key 4096
  openssl req -new -key av-int-ca.key -out av-int-ca.csr     -subj "/C=$C/ST=$ST/L=$L/O=$ORG/OU=$OU_INT/CN=$INT_CN"

  cat > int-ca-ext.cnf <<'EOF'
basicConstraints=CA:TRUE,pathlen=0
keyUsage=critical,keyCertSign,cRLSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
EOF

  openssl x509 -req -in av-int-ca.csr -CA av-root-ca.crt -CAkey av-root-ca.key -CAcreateserial     -out av-int-ca.crt -days "$INT_DAYS" -sha256 -extfile int-ca-ext.cnf
  echo "[✓] Intermediate CA generated: av-int-ca.crt"
else
  echo "[i] Intermediate CA already exists; skipping."
fi

# ---------------- Server cert (SAN) ----------------
# Default CN is the first host, or DEFAULT_CN if hosts file empty.
FIRST_HOST=$(grep -v '^#' "$HOSTS_FILE" | grep -v '^$' | head -n1 || true)
CN="${FIRST_HOST:-$DEFAULT_CN}"

cat > san.cnf <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[ dn ]
C  = $C
ST = $ST
L  = $L
O  = $ORG
OU = IT
CN = $CN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
$SAN_BLOCK
EOF

openssl genrsa -out av-internal.key 2048
openssl req -new -key av-internal.key -out av-internal.csr -config san.cnf

openssl x509 -req -in av-internal.csr -CA av-int-ca.crt -CAkey av-int-ca.key -CAcreateserial   -out av-internal.crt -days "$SERVER_DAYS" -sha256 -extfile san.cnf -extensions req_ext

# fullchain for Traefik (server + intermediate)
cat av-internal.crt av-int-ca.crt > av-internal.fullchain.crt

echo
echo "[✓] Server certs generated:"
echo "    - av-internal.key"
echo "    - av-internal.crt"
echo "    - av-internal.fullchain.crt (use this with Traefik)"
echo "    - av-int-ca.crt (already included in fullchain)"
echo "    - av-root-ca.crt (install on clients as trust root)"
echo
echo "[!] IMPORTANT: Store av-root-ca.key OFFLINE. Only av-int-ca.key should be used on servers for signing."
