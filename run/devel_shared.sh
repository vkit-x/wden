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
