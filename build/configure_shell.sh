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
if [ -n "$ENABLE_BLE_SH" ] ; then
    [[ $- == *i* ]] && source /root/.blesh/ble.sh --noattach
fi

# oh-my.zsh
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /root/.oh-my-bash.bashrc

# Python.
if [ -f ~/.bash_python ]; then
    source ~/.bash_python
fi

# direnv (cannot be placed in devel_shared_reentrant.sh due to prompt setup conflict)
eval "$(direnv hook bash)"

# ble.sh
if [ -n "$ENABLE_BLE_SH" ] ; then
    [[ ${BLE_VERSION-} ]] && ble-attach
fi

EOF
)
echo "$BASHRC_CONFIG" | tee -a /root/.bashrc > /dev/null

# Deal with permission.
chmod -R 755 /root/

# Shell entry.
apt-get install -y screen

BASH_PROFILE=$(
cat << "EOF"

source /root/.bashrc

if [ ! -f ~/.bash-session-env ]; then
    source "${WDEN_RUN_FOLDER}/run_${WDEN_RUN_TAG}_init_pre.sh"
    # NOTE: if place before init_pre.sh, the screen daemon session will inherits this var.
    export IN_DOCKER_RUN_SESSION=1
else
    source ~/.bash-session-env
fi

source "$WDEN_RUN_FOLDER"/run_${WDEN_RUN_TAG}_reentrant.sh

if [ -n "$IN_DOCKER_RUN_SESSION" ] ; then
    source "${WDEN_RUN_FOLDER}/run_${WDEN_RUN_TAG}_init_post.sh"
fi

EOF
)
echo "$BASH_PROFILE" | tee "/home/${FIXUID_USER}/.bash_profile" > /dev/null
