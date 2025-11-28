# Redis TLS test container

This image runs Redis with TLS enabled for local testing. Certificates are not baked into the image—you must mount a directory with `ca.crt`, `server.crt`, and `server.key` to `/tls`. You can generate these with the helper scripts in this folder.

## Build the image

- Build locally with: `docker build -t ghcr.io/miarec/redis-tls:local redis-tls`.

## Run Redis with TLS

- Generate certificates locally (see below), then run: `docker run --rm -p 6379:6379 -v "$(pwd)/redis-tls/certs:/tls" ghcr.io/miarec/redis-tls:local`.
- Control client certificate enforcement with `TLS_AUTH_CLIENTS` (defaults to `no`): `docker run --rm -e TLS_AUTH_CLIENTS=yes -p 6379:6379 -v "$(pwd)/redis-tls/certs:/tls" ghcr.io/miarec/redis-tls:local`.

Redis is started with:

```
--tls-port 6379
--port 0
--tls-cert-file /tls/server.crt
--tls-key-file /tls/server.key
--tls-ca-cert-file /tls/ca.crt
--tls-auth-clients ${TLS_AUTH_CLIENTS}
```

## Generate CA/server certificates

- Run `./generate_certificates.sh` to create `ca.crt`, `server.crt`, and `server.key` in `redis-tls/certs`. Use `--force` to regenerate.
- Mount them to `/tls` when running the container (see above).

## Generate client certificates (for client-auth scenarios)

- Create a client certificate signed by the CA: `./generate_client_certs.sh --name app --output-dir ./redis-tls/certs`.
- The script searches for the CA in `./certs` by default; override with `--ca-cert` and `--ca-key` if needed. Use `--force` to overwrite existing client keys.

## Connect with redis-cli

- Without client auth (server uses your mounted certs): `redis-cli --tls --cacert redis-tls/certs/ca.crt --insecure -p 6379` (use `--insecure` if you skip hostname verification).
- With client auth enabled: `redis-cli --tls --cacert redis-tls/certs/ca.crt --cert redis-tls/certs/app.crt --key redis-tls/certs/app.key -p 6379`.
