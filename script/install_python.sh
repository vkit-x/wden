#!/usr/bin/env bash
set -e

add-apt-repository ppa:deadsnakes/ppa -y
apt-get update

echo "Install PYTHON_VERSION=${PYTHON_VERSION}"

# Required for building python.
# Ubuntu 16.04 doesn't contain python3-distutils, and it's ok to ignore.
apt-get install --ignore-missing -y python3-distutils || true

apt-get install -y \
    python"$PYTHON_VERSION" \
    python"$PYTHON_VERSION"-dev \
    python"$PYTHON_VERSION"-venv

curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python"$PYTHON_VERSION"
# Allow non-root user to install package.
chmod 777 /usr/local/lib/python"$PYTHON_VERSION"/dist-packages

# Change the system default python/python3.
update-alternatives --install /usr/bin/python python /usr/bin/python"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip"$PYTHON_VERSION" 1

echo "python = $(python --version)"
echo "python3 = $(python --version)"
echo "pip = $(pip --version)"
echo "pip3 = $(pip --version)"
