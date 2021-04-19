#!/usr/bin/env bash
set -e

# Load oh-my-bash.
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /.bashrc

# Load direnv.
eval "$(direnv hook bash)"

# Setup actions.
if [ -n "$APT_SET_MIRROR_TENCENT" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_tencent.sh
elif [ -n "$APT_SET_MIRROR_ALIYUN" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_aliyun.sh
fi

if [ -n "$PIP_SET_INDEX_TENCENT" ] ; then
    export PIP_INDEX_URL='https://mirrors.cloud.tencent.com/pypi/simple/'
elif [ -n "$PIP_SET_INDEX_ALIYUN" ] ; then
    export PIP_INDEX_URL='https://mirrors.aliyun.com/pypi/simple/'
fi

if [ -n "$CD_DEFAULT_FOLDER" ] ; then
    if [ -d "$CD_DEFAULT_FOLDER" ] ; then
        alias cd="HOME='${CD_DEFAULT_FOLDER}' cd"
        cd "$CD_DEFAULT_FOLDER"
    else
        echo "WARNING: CD_DEFAULT_FOLDER=${CD_DEFAULT_FOLDER} not exists."
    fi
fi

if [ -n "$SSH_AUTH_SOCK" ] ; then
    if [ "$(stat -c '%a' "$SSH_AUTH_SOCK")" != '777' ] ; then
        echo "WARNING: SSH_AUTH_SOCK=$SSH_AUTH_SOCK doesn't have permission 777. Auto fixing."
        sudo chmod 777 "$SSH_AUTH_SOCK"
    fi
    export SSH_OPTIONS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
fi

if [ -n "$SSH_SOCKS5_PROXY" ] ; then
    export SSH_OPTIONS="${SSH_OPTIONS} -o ProxyCommand='ncat --proxy-type socks5 --proxy ${SSH_SOCKS5_PROXY} %h %p'"
fi

export GIT_SSH_COMMAND="ssh ${SSH_OPTIONS}"
alias ssh="ssh ${SSH_OPTIONS}"
