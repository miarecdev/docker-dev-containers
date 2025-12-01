# PostgreSQL TLS Test Container

This image runs PostgreSQL with TLS enabled for local testing. Certificates are not baked into the image—you must generate them and mount to `/tls`.

## Quick Start

```bash
cd postgres-tls

# Generate certificates, build image, run container, and test
make test

# Run interactive psql session (with SSL)
make psql

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
| `make run` | Run PostgreSQL container in background |
| `make test` | Test connection to PostgreSQL server |
| `make check` | Alias for test |
| `make psql` | Run psql with SSL and client certificate |
| `make psql-no-cert` | Run psql with SSL but no client certificate |
| `make psql-no-ssl` | Run psql without SSL (only if SSL_MODE=prefer) |
| `make logs` | Show container logs |
| `make stop` | Stop the container |
| `make clean` | Remove certificates and stop container |

## Configuration

Override defaults via command-line arguments:

```bash
# Use custom certificate directory
make ssl CERT_DIR=/tmp/my-certs

# Use custom image tag
make build IMAGE_TAG=my-postgres:latest

# Run on a different port
make run PORT=5434

# Use custom client certificate name
make client-ssl CLIENT_NAME=myapp

# Run with SSL required (no non-SSL connections)
make run SSL_MODE=require

# Run with client certificate verification
make run SSL_MODE=verify-ca
```

| Variable | Default | Description |
|----------|---------|-------------|
| `CERT_DIR` | `~/.postgres-tls` | Certificate directory |
| `IMAGE_TAG` | `miarec/postgres-tls` | Docker image tag |
| `PORT` | `5433` | Host port to expose |
| `CLIENT_NAME` | `client` | Client certificate name |
| `SSL_MODE` | `verify-ca` | SSL mode (see below) |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL superuser password |

## SSL Modes

| Mode | SSL Required | Client Cert Required | Description |
|------|--------------|---------------------|-------------|
| `prefer` | No | No | Both SSL and non-SSL connections allowed |
| `require` | Yes | No | SSL required, client certificates optional |
| `verify-ca` | Yes | Yes | SSL + client cert required, CA verified (default) |
| `verify-full` | Yes | Yes | SSL + client cert required, CA + CN verified |

## TLS Configuration

PostgreSQL is configured with:

```
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
ssl_ca_file = 'ca.crt'
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
ssl_prefer_server_ciphers = on
ssl_min_protocol_version = 'TLSv1.2'
```

## Connect with psql

### SSL connection (server verification only)

```bash
psql "host=localhost port=5433 user=postgres dbname=postgres sslmode=require"
```

### SSL connection with client certificate

```bash
psql "host=localhost port=5433 user=postgres dbname=postgres \
     sslmode=require \
     sslcert=$HOME/.postgres-tls/client.crt \
     sslkey=$HOME/.postgres-tls/client.key \
     sslrootcert=$HOME/.postgres-tls/ca.crt"
```

### Non-SSL connection (only if SSL_MODE=prefer)

```bash
psql "host=localhost port=5433 user=postgres dbname=postgres sslmode=disable"
```

## Verifying SSL Status

Once connected, check SSL status:

```sql
-- Check current connection SSL status
SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();

-- View all SSL connections
SELECT pid, ssl, version, cipher, bits, clientdn
FROM pg_stat_ssl
WHERE ssl = true;
```

## Run Docker Container Manually

First, generate CA and server certificates if you don't have them:

```bash
make ca-ssl
make server-ssl
```

This will create the certs in `~/.postgres-tls` by default.

Then, build the container:

```bash
docker build -t miarec/postgres-tls .
```

Finally, run the container:

```bash
docker run --rm -p 5432:5432 \
  -v "$HOME/.postgres-tls:/tls" \
  -e POSTGRES_PASSWORD=postgres \
  -e SSL_MODE=prefer \
  miarec/postgres-tls
```

## Client Certificate Behavior

PostgreSQL has smart certificate validation:

- If `ssl_ca_file` is set and a client provides a certificate, PostgreSQL **always validates it**
- Invalid/unsigned certificates are **rejected** even when certificates are optional
- With `SSL_MODE=prefer` or `SSL_MODE=require`:
  - Clients CAN connect without any certificate
  - Clients CAN connect with valid CA-signed certificates
  - Clients CANNOT connect with invalid/unsigned certificates

## Differences from Redis TLS

| Feature | PostgreSQL | Redis |
|---------|------------|-------|
| Port Model | Single port (5432) for both | Separate ports (6379/6380) |
| Connection Type | Determined by client & pg_hba.conf | Port determines encryption |
| Client Cert Default | Optional (but validated if provided) | All or nothing via `tls-auth-clients` |
| Invalid Cert Behavior | Always rejected if provided | Depends on `tls-auth-clients` setting |
| SSL Modes | Multiple (disable, prefer, require, verify-ca, verify-full) | On or off |

## Troubleshooting

### Connection Refused

```bash
# Check if PostgreSQL is running
docker ps | grep postgres-tls

# Check logs
make logs
```

### SSL Connection Failed

```bash
# Verify SSL is enabled
docker exec postgres-tls psql -U postgres -c "SHOW ssl;"

# Check certificate permissions in container
docker exec postgres-tls ls -la /tls/
```

### Certificate Verification Failed

```bash
# Test certificate validity
openssl x509 -in ~/.postgres-tls/server.crt -noout -dates

# Verify certificate chain
openssl verify -CAfile ~/.postgres-tls/ca.crt ~/.postgres-tls/client.crt
```
