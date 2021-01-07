#!/usr/bin/env bash

# Load oh-my-bash.
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /.bashrc

# Load direnv.
eval "$(direnv hook bash)"

# Setup actions.
if [ -n "$APT_SET_MIRROR_TENCENT" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_tencent.sh
fi

if [ -n "$APT_SET_MIRROR_ALIYUN" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_aliyun.sh
fi

if [ -n "$CD_DEFAULT_FOLDER" ] ; then
    if [ -d "$CD_DEFAULT_FOLDER" ] ; then
        alias cd="HOME='${CD_DEFAULT_FOLDER}' cd"
    else
        echo "WARNING: CD_DEFAULT_FOLDER=${CD_DEFAULT_FOLDER} not exists."
    fi
fi
