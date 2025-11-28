#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${ROOT}/certs"
IMAGE="ghcr.io/miarec/redis-tls:local"
CONTAINER_NAME="redis-tls-test"

log() {
  echo "[$(date +%H:%M:%S)] $*"
}

stop_container() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  fi
}

trap stop_container EXIT

log "Ensuring CA and server certificates exist..."
if [[ ! -f "${CERT_DIR}/ca.crt" || ! -f "${CERT_DIR}/server.crt" || ! -f "${CERT_DIR}/server.key" ]]; then
  log "Generating CA/server certificates..."
  "${ROOT}/generate_certificates.sh"
else
  log "Found existing CA/server certificates."
fi

log "Ensuring client certificate exists..."
if [[ ! -f "${CERT_DIR}/app.crt" || ! -f "${CERT_DIR}/app.key" ]]; then
  log "Generating client certificate (app)..."
  "${ROOT}/generate_client_certs.sh" --name app --output-dir "${CERT_DIR}"
else
  log "Found existing client certificate (app)."
fi

log "Building image ${IMAGE}..."
docker build -t "${IMAGE}" "${ROOT}"

stop_container

log "Starting container ${CONTAINER_NAME}..."
docker run --rm -d --name "${CONTAINER_NAME}" -p 6379:6379 -v "${CERT_DIR}:/tls" "${IMAGE}" >/dev/null

log "Waiting for Redis to accept TLS connections..."
PING_OUTPUT=""
PING_STATUS=1
for _ in $(seq 1 10); do
  if PING_OUTPUT=$(docker exec "${CONTAINER_NAME}" redis-cli \
    --tls \
    --cacert /tls/ca.crt \
    --cert /tls/app.crt \
    --key /tls/app.key \
    PING 2>&1); then
    PING_STATUS=0
    break
  fi
  sleep 1
done

log "Ping status: ${PING_STATUS} (output: ${PING_OUTPUT})"

log "Docker logs:"
docker logs "${CONTAINER_NAME}"

if [[ "${PING_STATUS}" -eq 0 && "${PING_OUTPUT}" == "PONG" ]]; then
  log "Redis TLS test succeeded."
  exit 0
else
  log "Redis TLS test failed."
  exit 1
fi
