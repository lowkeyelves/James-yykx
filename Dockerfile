FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/caddy.tar.gz -L "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com/caddyserver/naiveproxy" \
    && tar -xzf /tmp/caddy.tar.gz -C /usr/bin/ \
    && chmod +x /usr/bin/caddy \
    && rm /tmp/caddy.tar.gz

RUN mkdir -p /etc/caddy /data/certs /data/config

COPY Caddyfile.template /etc/caddy/Caddyfile.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /etc/caddy
EXPOSE 80 443
VOLUME ["/data"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile"]
