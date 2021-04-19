#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

add-apt-repository ppa:deadsnakes/ppa -y
apt-get update

# Patch Ubuntu 18.04 executables related to python3.
SYSTEM_DEFAULT_PYTHON_VERSION=$(python3 -c 'import sys; print(sys.version[:3])')
echo "SYSTEM_DEFAULT_PYTHON_VERSION=${SYSTEM_DEFAULT_PYTHON_VERSION}"
grep -rl '#!/usr/bin/python3' /usr/bin \
    | xargs sed -i "s|#!/usr/bin/python3|#!/usr/bin/python${SYSTEM_DEFAULT_PYTHON_VERSION}|g"

echo "Install PYTHON_VERSION=${PYTHON_VERSION}"

# Required for building python.
# Ubuntu 16.04 doesn't contain python3-distutils, and it's ok to ignore.
apt-get install --ignore-missing -y python3-distutils || true

# Suppress tzdata interactive prompt shipped with Python 3.9.
export DEBIAN_FRONTEND="noninteractive"

# Install Python.
apt-get install -y \
    python"$PYTHON_VERSION" \
    python"$PYTHON_VERSION"-dev \
    python"$PYTHON_VERSION"-venv

# Install the latest version of pip.
curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python"$PYTHON_VERSION"
/usr/local/bin/pip"$PYTHON_VERSION" install -U pip

# Allow non-root user to install package.
chmod -R 777 /usr/lib/python"$PYTHON_VERSION"
chmod -R 777 /usr/local
# git clone from repository.
chmod -R 777 /usr/src

# Change the system default python/python3.
update-alternatives --install /usr/bin/python python /usr/bin/python"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip"$PYTHON_VERSION" 1
update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip"$PYTHON_VERSION" 1

echo "python = $(python --version)"
echo "python3 = $(python --version)"
echo "pip = $(pip --version)"
echo "pip3 = $(pip --version)"
