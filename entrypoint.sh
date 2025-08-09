#!/bin/bash

if [ ! -d "/data" ]; then
    echo "Error: /data mount point not found!"
    exit 1
fi

if [ ! -f "/data/certs/cert.pem" ] || [ ! -f "/data/certs/key.pem" ]; then
    echo "Error: Certificate files (cert.pem or key.pem) not found in /data/certs!"
    exit 1
fi

CADDYFILE="/etc/caddy/Caddyfile"

if [ -f "/data/config/Caddyfile" ]; then
    echo "Using existing Caddyfile from /data/config/Caddyfile"
    cp /data/config/Caddyfile $CADDYFILE
else
    echo "Generating Caddyfile from template and environment variables"
    envsubst < /etc/caddy/Caddyfile.template > $CADDYFILE
fi

exec "$@"
