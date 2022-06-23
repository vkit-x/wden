#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Install oh-my-bash.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
mv /root/.bashrc /root/.oh-my-bash.bashrc

# Install ble.sh
git clone --recursive https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
cd /tmp/ble.sh
make
make install INSDIR=/root/.blesh

# Combine.
BASHRC_CONFIG=$(
cat << "EOF"

# ble.sh
[[ $- == *i* ]] && source /root/.blesh/ble.sh --noattach

# oh-my.zsh
source /root/.oh-my-bash.bashrc

# Python.
if [ -f ~/.bash_python ]; then
    source ~/.bash_python
fi

# ble.sh
[[ ${BLE_VERSION-} ]] && ble-attach

EOF
)
echo "$BASHRC_CONFIG" | tee -a /root/.bashrc > /dev/null

# Deal with permission.
chmod -R 755 /root/

# For ssh login.
echo 'source /root/.bashrc' >> "/home/${FIXUID_USER}/.bash_profile"
