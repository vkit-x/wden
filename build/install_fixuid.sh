#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

#https://github.com/boxboat/fixuid
addgroup \
    --gid 1000 \
    "$FIXUID_GROUP"

adduser \
    --uid 1000 \
    --ingroup "$FIXUID_GROUP" \
    --home /home/"$FIXUID_USER" \
    --shell /bin/bash \
    --disabled-password \
    --gecos "" \
    "$FIXUID_USER"

export URL='https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz'
curl -SsL $URL | tar -C /usr/local/bin -xzf -
chown root:root /usr/local/bin/fixuid
chmod 4755 /usr/local/bin/fixuid

mkdir -p /etc/fixuid
printf 'user: %s\ngroup: %s\n' "$FIXUID_USER" "$FIXUID_GROUP" > /etc/fixuid/config.yml
