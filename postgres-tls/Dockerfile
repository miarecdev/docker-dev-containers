# check=skip=SecretsUsedInArgOrEnv
FROM postgres:16-alpine
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"
LABEL maintainer="MiaRec dev@miarec.com"

# SSL_MODE controls client certificate requirements:
#   - "prefer" = SSL optional, client certs optional
#   - "require" = SSL required, client certs optional
#   - "verify-ca" = SSL required, client certs required (CA verified) [default]
#   - "verify-full" = SSL required, client certs required (CA + CN verified)
ENV SSL_MODE=verify-ca

# Copy initialization scripts (run in alphabetical order during DB init)
COPY scripts/*.sh /docker-entrypoint-initdb.d/
