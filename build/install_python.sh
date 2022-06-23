#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

add-apt-repository ppa:deadsnakes/ppa -y
apt-get update

# Install Python.
apt-get install -y \
    python"$PYTHON_VERSION" \
    python"$PYTHON_VERSION"-dev \
    python"$PYTHON_VERSION"-venv

# Configs for FIXUID_USER.
FIXUID_USER_BASH_PYTHON_CONFIG=$(
cat << EOF

if [ -z "\$BASH_PYTHON_FLAG" ] ; then
    shopt -s expand_aliases
    alias python=python3

    export PATH=/home/${FIXUID_USER}/.local/bin:\$PATH

    export BASH_PYTHON_FLAG=1
fi

EOF
)
echo "$FIXUID_USER_BASH_PYTHON_CONFIG" > "/home/${FIXUID_USER}/.bash_python"

su - $FIXUID_USER \
    -c 'touch ~/.bash_profile'
echo '. ~/.bash_python' >> "/home/${FIXUID_USER}/.bash_profile"
echo '. ~/.bash_python' >> "/home/${FIXUID_USER}/.bashrc"

# Install the latest version of pip to FIXUID_USER.
su - $FIXUID_USER \
    -c "curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION}"
# Make pip --user as default mode.
su - $FIXUID_USER \
    -c "mkdir ~/.pip && touch ~/.pip/pip.conf"

PIP_CONFIG=$(
cat << EOF

[global]
user = yes

EOF
)
echo "$PIP_CONFIG" | tee -a "/home/${FIXUID_USER}/.pip/pip.conf" > /dev/null

# Show.
su - $FIXUID_USER \
    -c "python --version"
su - $FIXUID_USER \
    -c "python3 --version"
su - $FIXUID_USER \
    -c "pip --version"
su - $FIXUID_USER \
    -c "pip3 --version"
