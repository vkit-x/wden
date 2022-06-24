#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Install oh-my-bash.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
mv /root/.bashrc /root/.oh-my-bash.bashrc

# Install ble.sh
apt-get install -y gawk
git clone --recursive https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
cd /tmp/ble.sh
make
make install INSDIR=/root/.blesh
rm -rf /tmp/ble.sh

# Combine.
BASHRC_CONFIG=$(
cat << "EOF"

# ble.sh
[[ $- == *i* ]] && source /root/.blesh/ble.sh --noattach

# oh-my.zsh
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /root/.oh-my-bash.bashrc

# Python.
if [ -f ~/.bash_python ]; then
    source ~/.bash_python
fi

# direnv (cannot be placed in devel_shared_dynamic.sh due to prompt setup conflict)
eval "$(direnv hook bash)"

# ble.sh
[[ ${BLE_VERSION-} ]] && ble-attach

EOF
)
echo "$BASHRC_CONFIG" | tee -a /root/.bashrc > /dev/null

# Deal with permission.
chmod -R 755 /root/

# For ssh login.
BASH_PROFILE=$(
cat << "EOF"

source /root/.bashrc
source ~/.bash-session-env
source "$WDEN_RUN_FOLDER"/devel_shared_dynamic.sh

EOF
)
echo "$BASH_PROFILE" | tee -a "/home/${FIXUID_USER}/.bash_profile" > /dev/null
