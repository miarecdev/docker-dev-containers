#!/bin/sh
set -e

# Configure SSL in postgresql.conf

PGDATA="${PGDATA:-/var/lib/postgresql/data}"

echo "Configuring postgresql.conf for TLS..."

# Copy certificates from /tls/ to /var/lib/postgresql/ with correct permissions
# (PostgreSQL requires key to be 600 and owned by postgres)
cp /tls/server.crt /var/lib/postgresql/server.crt
cp /tls/server.key /var/lib/postgresql/server.key
cp /tls/ca.crt /var/lib/postgresql/ca.crt

chown postgres:postgres /var/lib/postgresql/server.crt /var/lib/postgresql/server.key /var/lib/postgresql/ca.crt
chmod 600 /var/lib/postgresql/server.key
chmod 644 /var/lib/postgresql/server.crt /var/lib/postgresql/ca.crt

cat >> "$PGDATA/postgresql.conf" << EOF

# TLS/SSL Configuration (added by postgres-tls container)
ssl = on
ssl_cert_file = '/var/lib/postgresql/server.crt'
ssl_key_file = '/var/lib/postgresql/server.key'
ssl_ca_file = '/var/lib/postgresql/ca.crt'
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
ssl_prefer_server_ciphers = on
ssl_min_protocol_version = 'TLSv1.2'
EOF

echo "postgresql.conf TLS configuration complete"
