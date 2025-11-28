#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${SCRIPT_DIR}/certs"

CA_KEY="${CERT_DIR}/ca.key"
CA_CERT="${CERT_DIR}/ca.crt"
CA_SERIAL="${CERT_DIR}/ca.srl"
SERVER_KEY="${CERT_DIR}/server.key"
SERVER_CSR="${CERT_DIR}/server.csr"
SERVER_CERT="${CERT_DIR}/server.crt"
SERVER_EXT="${CERT_DIR}/server.ext"

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

mkdir -p "${CERT_DIR}"

if [[ "${FORCE}" -eq 0 ]]; then
  for file in "${CA_KEY}" "${CA_CERT}" "${SERVER_KEY}" "${SERVER_CERT}"; do
    if [[ -e "${file}" ]]; then
      echo "Refusing to overwrite ${file}. Rerun with --force to regenerate certificates."
      exit 1
    fi
  done
else
  rm -f "${CA_KEY}" "${CA_CERT}" "${CA_SERIAL}" "${SERVER_KEY}" "${SERVER_CSR}" "${SERVER_CERT}" "${SERVER_EXT}"
fi

openssl genrsa -out "${CA_KEY}" 4096
openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 -days 3650 -out "${CA_CERT}" -subj "/CN=Redis Test CA"

openssl genrsa -out "${SERVER_KEY}" 2048
openssl req -new -key "${SERVER_KEY}" -out "${SERVER_CSR}" -subj "/CN=redis-server"

cat > "${SERVER_EXT}" <<EOF
subjectAltName=DNS:localhost,IP:127.0.0.1
extendedKeyUsage=serverAuth
EOF

openssl x509 -req -in "${SERVER_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -CAserial "${CA_SERIAL}" -out "${SERVER_CERT}" -days 3650 -sha256 -extfile "${SERVER_EXT}"

rm -f "${SERVER_CSR}" "${SERVER_EXT}"

chmod 600 "${CA_KEY}" "${SERVER_KEY}"

echo "Generated CA certificate: ${CA_CERT}"
echo "Generated Redis server certificate: ${SERVER_CERT}"
echo "Certificates are available in ${CERT_DIR}"
