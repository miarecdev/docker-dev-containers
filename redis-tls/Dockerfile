FROM redis:7-alpine
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"
LABEL maintainer="MiaRec dev@miarec.com"

ENV TLS_AUTH_CLIENTS=no

RUN set -e \
  && apk add --no-cache openssl \
  && mkdir -p /tls \
  && openssl genrsa -out /tls/ca.key 4096 \
  && openssl req -x509 -new -nodes -key /tls/ca.key -sha256 -days 3650 -out /tls/ca.crt -subj "/CN=Redis Test CA" \
  && openssl genrsa -out /tls/server.key 2048 \
  && openssl req -new -key /tls/server.key -out /tmp/server.csr -subj "/CN=redis-server" \
  && printf "subjectAltName=DNS:localhost,IP:127.0.0.1\nextendedKeyUsage=serverAuth\n" > /tmp/server.ext \
  && openssl x509 -req -in /tmp/server.csr -CA /tls/ca.crt -CAkey /tls/ca.key -CAcreateserial -out /tls/server.crt -days 3650 -sha256 -extfile /tmp/server.ext \
  && rm -f /tmp/server.csr /tmp/server.ext \
  && chmod 600 /tls/server.key /tls/ca.key

COPY entrypoint.sh /usr/local/bin/run-redis-tls.sh
RUN chmod +x /usr/local/bin/run-redis-tls.sh

EXPOSE 6379

CMD ["/usr/local/bin/run-redis-tls.sh"]
