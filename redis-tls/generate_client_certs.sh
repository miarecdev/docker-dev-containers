#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_CERT_DIR="${SCRIPT_DIR}/certs"

CLIENT_NAME="client"
CA_CERT="${DEFAULT_CERT_DIR}/ca.crt"
CA_KEY="${DEFAULT_CERT_DIR}/ca.key"
OUTPUT_DIR="${DEFAULT_CERT_DIR}"
FORCE=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [client-name]

Options:
  -n, --name NAME          Client certificate name (default: client)
      --ca-cert PATH       Path to the CA certificate (default: ${CA_CERT})
      --ca-key PATH        Path to the CA private key (default: ${CA_KEY})
  -o, --output-dir DIR     Directory for generated client certificates (default: ${OUTPUT_DIR})
      --force              Overwrite existing client certificates
  -h, --help               Show this help message

You can pass the client name as the last positional argument instead of using --name.
EOF
}

NAME_SET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name)
      CLIENT_NAME="$2"
      NAME_SET=1
      shift 2
      ;;
    --ca-cert)
      CA_CERT="$2"
      shift 2
      ;;
    --ca-key)
      CA_KEY="$2"
      shift 2
      ;;
    -o|--output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ "${NAME_SET}" -eq 0 ]]; then
        CLIENT_NAME="$1"
        NAME_SET=1
        shift
      else
        usage
        exit 1
      fi
      ;;
  esac
done

CA_CERT_PATH="${CA_CERT}"
CA_KEY_PATH="${CA_KEY}"

if [[ ! -f "${CA_CERT_PATH}" ]]; then
  echo "CA certificate not found at ${CA_CERT_PATH}"
  exit 1
fi

if [[ ! -f "${CA_KEY_PATH}" ]]; then
  echo "CA key not found at ${CA_KEY_PATH}"
  exit 1
fi

CA_SERIAL="$(cd "$(dirname "${CA_CERT_PATH}")" && pwd)/ca.srl"

mkdir -p "${OUTPUT_DIR}"

CLIENT_KEY="${OUTPUT_DIR}/${CLIENT_NAME}.key"
CLIENT_CSR="${OUTPUT_DIR}/${CLIENT_NAME}.csr"
CLIENT_CERT="${OUTPUT_DIR}/${CLIENT_NAME}.crt"
CLIENT_EXT="${OUTPUT_DIR}/${CLIENT_NAME}.ext"

if [[ "${FORCE}" -eq 0 ]]; then
  for file in "${CLIENT_KEY}" "${CLIENT_CERT}"; do
    if [[ -e "${file}" ]]; then
      echo "Refusing to overwrite ${file}. Use --force to regenerate."
      exit 1
    fi
  done
else
  rm -f "${CLIENT_KEY}" "${CLIENT_CSR}" "${CLIENT_CERT}" "${CLIENT_EXT}"
fi

openssl genrsa -out "${CLIENT_KEY}" 2048
openssl req -new -key "${CLIENT_KEY}" -out "${CLIENT_CSR}" -subj "/CN=${CLIENT_NAME}"

cat > "${CLIENT_EXT}" <<EOF
subjectAltName=DNS:${CLIENT_NAME},DNS:localhost,IP:127.0.0.1
extendedKeyUsage=clientAuth
EOF

openssl x509 -req -in "${CLIENT_CSR}" -CA "${CA_CERT_PATH}" -CAkey "${CA_KEY_PATH}" -CAserial "${CA_SERIAL}" -CAcreateserial -out "${CLIENT_CERT}" -days 3650 -sha256 -extfile "${CLIENT_EXT}"

rm -f "${CLIENT_CSR}" "${CLIENT_EXT}"

chmod 600 "${CLIENT_KEY}"

echo "Generated client certificate: ${CLIENT_CERT}"
echo "CA certificate: ${CA_CERT_PATH}"
