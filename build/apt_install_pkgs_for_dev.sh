#!/usr/bin/env bash
set -e

declare -a pkgs=(
    sudo

    # Network.
    net-tools
    iputils-ping
    curl
    wget

    # Editor
    vim
    neovim

    # APT.
    software-properties-common
    ca-certificates
    apt-transport-https

    # GCC, libraries and utilities for build.
    build-essential
    cmake

    # Required by opencv.
    libgl1-mesa-glx

    # Utility.
    zip
    unzip
    p7zip-full
    git
    direnv
)

apt-get install -y ${pkgs[@]}
