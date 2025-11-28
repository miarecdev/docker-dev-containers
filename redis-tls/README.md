# Redis TLS test container

This image runs Redis with TLS enabled for local testing. The Docker build generates self-signed CA and server certificates inside the image so it works out of the box without mounting anything. You can still mount your own certificates to `/tls` if you want to enforce client authentication.

## Build the image

- Build locally with: `docker build -t ghcr.io/miarec/redis-tls:local redis-tls`.

## Run Redis with TLS

- Quick start using built-in certs (client auth disabled by default): `docker run --rm -p 6379:6379 ghcr.io/miarec/redis-tls:local`.
- To use your own certificates, mount them to `/tls`: `docker run --rm -p 6379:6379 -v "$(pwd)/redis-tls/certs:/tls" ghcr.io/miarec/redis-tls:local`.
- Control client certificate enforcement with `TLS_AUTH_CLIENTS` (defaults to `no`): `docker run --rm -e TLS_AUTH_CLIENTS=yes -p 6379:6379 ghcr.io/miarec/redis-tls:local`.

Redis is started with:

```
--tls-port 6379
--port 0
--tls-cert-file /tls/server.crt
--tls-key-file /tls/server.key
--tls-ca-cert-file /tls/ca.crt
--tls-auth-clients ${TLS_AUTH_CLIENTS}
```

## Generate CA/server certificates locally (optional)

- If you prefer to supply your own certs, run `./generate_certificates.sh` to create `ca.crt`, `server.crt`, and `server.key` in `redis-tls/certs`. Use `--force` to regenerate.
- Mount them to `/tls` when running the container (see above).

## Generate client certificates (for client-auth scenarios)

- Create a client certificate signed by the CA: `./generate_client_certs.sh --name app --output-dir ./redis-tls/certs`.
- The script searches for the CA in `./certs` by default; override with `--ca-cert` and `--ca-key` if needed. Use `--force` to overwrite existing client keys.

## Connect with redis-cli

- Using bundled certs with client auth disabled: `redis-cli --tls --insecure -p 6379` (self-signed server cert).
- Using your own mounted certs with client auth enabled: `redis-cli --tls --cacert redis-tls/certs/ca.crt --cert redis-tls/certs/app.crt --key redis-tls/certs/app.key -p 6379`.
