#!/usr/bin/env bash
set -e

add-apt-repository ppa:deadsnakes/ppa -y
apt-get update

echo "Install PYTHON_VERSION=${PYTHON_VERSION}"

apt-get install -y \
    python"$PYTHON_VERSION" \
    python"$PYTHON_VERSION"-dev \
    python"$PYTHON_VERSION"-venv

curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python"$PYTHON_VERSION"

# Change the system default python/python3.
update-alternatives --install /usr/bin/python python /usr/bin/python"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip"$PYTHON_VERSION" 1

echo "python = $(which python)"
echo "python3 = $(which python3)"
echo "$(python --version)"
echo "pip = $(which pip)"
echo "pip3 = $(which pip3)"
echo "$(pip --version)"
