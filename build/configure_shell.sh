#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Install oh-my-bash.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
mv /root/.bashrc /root/.oh-my-bash.bashrc

BASHRC_CONFIG=$(
cat << "EOF"

# oh-my.zsh
if [ -z "$DISABLE_OH_MY_BASH" ] ; then
    export DISABLE_UPDATE_PROMPT=true
    export DISABLE_AUTO_UPDATE=true
    source /root/.oh-my-bash.bashrc
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

# Shell.
source /root/.bashrc

# Python
source ~/.bash_python

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
