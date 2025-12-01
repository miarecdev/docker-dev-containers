# check=skip=SecretsUsedInArgOrEnv
FROM postgres:16
# Note, do not use Alpine build as it doesn't support LC_COLLATE en_US.UTF-8 and the order is case-sensitiveLABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL maintainer="MiaRec dev@miarec.com"

# SSL_MODE controls client certificate requirements:
#   - "prefer" = SSL optional, client certs optional
#   - "require" = SSL required, client certs optional
#   - "verify-ca" = SSL required, client certs required (CA verified) [default]
#   - "verify-full" = SSL required, client certs required (CA + CN verified)
ENV SSL_MODE=verify-ca

ENV POSTGRES_MULTIPLE_DATABASES=miarecdb,miarecdb_test
ENV POSTGRES_USER=miarec
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8"

# Copy initialization scripts (run in alphabetical order during DB init)
COPY scripts/*.sh /docker-entrypoint-initdb.d/
