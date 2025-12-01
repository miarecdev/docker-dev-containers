# Redis TLS Test Container

This image runs Redis with TLS enabled for local testing. Certificates are not baked into the image—you must generate them and mount to `/tls`.

## Quick Start

```bash
cd redis-tls

# Generate certificates, build image, run container, and test
make test

# Run interactive redis-cli session
make cli

# Stop the container
make stop
```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make ssl` | Generate all certificates (CA, server, client) |
| `make ca-ssl` | Generate CA certificate only |
| `make server-ssl` | Generate server certificate (requires CA) |
| `make client-ssl` | Generate client certificate (requires CA) |
| `make build` | Build Docker image |
| `make run` | Run Redis container in background |
| `make test` | Test PING/PONG against Redis server |
| `make check` | Alias for test |
| `make cli` | Run redis-cli in interactive mode |
| `make logs` | Show container logs |
| `make stop` | Stop the container |
| `make clean` | Remove certificates and stop container |

## Configuration

Override defaults via command-line arguments:

```bash
# Use custom certificate directory
make ssl CERT_DIR=/tmp/my-certs

# Use custom image tag
make build IMAGE_TAG=my-redis:latest

# Run on a different port
make run PORT=6381

# Use custom client certificate name
make client-ssl CLIENT_NAME=myapp
```

| Variable | Default | Description |
|----------|---------|-------------|
| `CERT_DIR` | `~/.redis-tls` | Certificate directory |
| `IMAGE_TAG` | `miarec/redis-tls` | Docker image tag |
| `PORT` | `6380` | Host port to expose |
| `CLIENT_NAME` | `client` | Client certificate name |

## TLS Configuration

Redis is started with:

```
--tls-port 6379
--port 0
--tls-cert-file /tls/server.crt
--tls-key-file /tls/server.key
--tls-ca-cert-file /tls/ca.crt
--tls-auth-clients ${TLS_AUTH_CLIENTS}
```

Control client certificate enforcement with `TLS_AUTH_CLIENTS` environment variable (defaults to `no`).

## Connect with redis-cli

Without client auth:

```bash
redis-cli --tls --cacert ~/.redis-tls/ca.crt -p 6380
```

With client auth enabled:

```bash
redis-cli --tls --cacert ~/.redis-tls/ca.crt \
  --cert ~/.redis-tls/client.crt \
  --key ~/.redis-tls/client.key \
  -p 6380
```

## Run docker container manually

This `redis-tls` image bundles Redis configured for TLS so you can test secure connections locally. 
Certificates are not baked into the image; mount your own certs to `/tls`:

First, generate CA and server ertificates if you don't have them:

```bash
make ca-ssl
make server-ssl
```

This will create the certs in `~/.redis-tls` by default.

Then, build the container with the desired tag:

```bash
docker build -t miarec/redis-tls .
```

Finally, run the container, mounting your certs:

```bash
docker run --rm -p 6379:6379 -v "$(pwd)/redis-tls/certs:/tls" miarec/redis-tls
```

Control TLS client authentication with `TLS_AUTH_CLIENTS` (defaults to `no`):

```bash
docker run --rm -e TLS_AUTH_CLIENTS=yes -p 6379:6379 miarec/redis-tls
```


