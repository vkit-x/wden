#!/usr/bin/env bash

# PIP index.
if [ -n "$PIP_SET_INDEX_TENCENT" ] ; then
    export PIP_INDEX_URL='https://mirrors.cloud.tencent.com/pypi/simple/'
elif [ -n "$PIP_SET_INDEX_ALIYUN" ] ; then
    export PIP_INDEX_URL='https://mirrors.aliyun.com/pypi/simple/'
fi

# Home folder.
if [ -n "$CD_DEFAULT_FOLDER" ] ; then
    if [ -d "$CD_DEFAULT_FOLDER" ] ; then
        alias cd="HOME='${CD_DEFAULT_FOLDER}' cd"
        cd "$CD_DEFAULT_FOLDER"
    else
        echo "WARNING: CD_DEFAULT_FOLDER=${CD_DEFAULT_FOLDER} not exists."
    fi
fi

# SSH agent & proxy.
export SSH_OPTIONS=''

if [ -n "$SSH_AUTH_SOCK" ] ; then
    export SSH_OPTIONS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
fi

if [ -n "$SSH_SOCKS5_PROXY" ] ; then
    export SSH_OPTIONS="${SSH_OPTIONS} -o ProxyCommand='ncat --proxy-type socks5 --proxy ${SSH_SOCKS5_PROXY} %h %p'"
    export GIT_SSH_COMMAND="ssh ${SSH_OPTIONS}"
    alias ssh="ssh ${SSH_OPTIONS}"
fi

# HTTP proxy.
if [ -n "$PROPAGATE_HTTPS_PROXY" ] && [ -n "$HTTPS_PROXY" ] ; then
    export HTTP_PROXY="$HTTPS_PROXY"
    export https_proxy="$HTTPS_PROXY"
    export http_proxy="$HTTPS_PROXY"
fi

# Customized script.
if [ -n "$CUSTOMIZED_REENTRANT_SH" ] ; then
    source "$CUSTOMIZED_REENTRANT_SH"
fi

# Direnv.
eval "$(direnv hook bash)"

# Attach screen session.
if [ -z "$DISABLE_SCREEN_DAEMON" ] \
        && [ -z "$IN_DOCKER_RUN_SESSION" ] \
        && [ -z "$BASHRC_EXECUTED" ] \
        && [ -z "$STY" ] ; then
    SCREEN_LIST=$(screen -list)
    if [[ "$SCREEN_LIST" =~ "Attached" ]] ; then
        echo "screen session was attached, stop attaching..."
    else
        screen -a -A -U -r
        exit
    fi
fi
