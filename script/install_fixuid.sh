#!/usr/bin/env bash
set -e

#https://github.com/boxboat/fixuid
export USER=den
export GROUP=den

addgroup \
    --gid 1000 \
    $GROUP

adduser \
    --uid 1000 \
    --ingroup $GROUP \
    --home /home/"$USER" \
    --shell /usr/bin/zsh \
    --disabled-password \
    --gecos "" \
    $USER


export URL='https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz'
curl -SsL $URL | tar -C /usr/local/bin -xzf -
chown root:root /usr/local/bin/fixuid
chmod 4755 /usr/local/bin/fixuid

mkdir -p /etc/fixuid
printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml
