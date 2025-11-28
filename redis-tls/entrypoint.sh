#!/usr/bin/env sh
set -e

TLS_AUTH_CLIENTS_VALUE="${TLS_AUTH_CLIENTS:-no}"

for file in /tls/ca.crt /tls/server.crt /tls/server.key; do
  if [ ! -f "$file" ]; then
    echo "TLS file $file is missing. Mount certificates to /tls or rebuild the image with certs present."
    exit 1
  fi
done

exec docker-entrypoint.sh redis-server \
  --tls-port 6379 \
  --port 0 \
  --tls-cert-file /tls/server.crt \
  --tls-key-file /tls/server.key \
  --tls-ca-cert-file /tls/ca.crt \
  --tls-auth-clients "${TLS_AUTH_CLIENTS_VALUE}" \
  "$@"
