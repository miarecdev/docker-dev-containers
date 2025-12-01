# check=skip=SecretsUsedInArgOrEnv
FROM redis:7-alpine
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"
LABEL maintainer="MiaRec dev@miarec.com"

# TLS_AUTH_CLIENTS is not sensitive - it's a boolean config flag
ENV TLS_AUTH_CLIENTS=no

RUN mkdir -p /tls

COPY entrypoint.sh /usr/local/bin/run-redis-tls.sh
RUN chmod +x /usr/local/bin/run-redis-tls.sh

EXPOSE 6379

CMD ["/usr/local/bin/run-redis-tls.sh"]
