#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

echo "Run apt_set_mirror_tencent.sh"

source /etc/os-release

SOURCES_LIST=$(
cat << EOF

deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
#deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-proposed main restricted universe multiverse
#deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
#deb-src http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-proposed main restricted universe multiverse
#deb-src http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse

EOF
)
echo "$SOURCES_LIST" | tee /etc/apt/sources.list > /dev/null

apt-get update
