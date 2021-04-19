#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

declare -a pkgs=(
    sudo

    # Network.
    net-tools
    iputils-ping
    curl
    wget

    # ncat for ssh proxy.
    nmap

    # Editor
    vim
    neovim

    # APT.
    apt-transport-https
    ca-certificates
    gnupg
    software-properties-common

    # GCC, libraries and utilities for build.
    build-essential

    # Utility.
    zip
    unzip
    p7zip-full
    git
    direnv
)

apt-get update
apt-get install -y "${pkgs[@]}"

# Install the latest version of cmake.
# https://apt.kitware.com/
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - \
    | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
source /etc/os-release
apt-add-repository -y "deb https://apt.kitware.com/ubuntu/ ${UBUNTU_CODENAME} main"
apt-get update
apt-get install -y cmake
