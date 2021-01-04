#!/usr/bin/env bash

# Load oh-my-bash.
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /.bashrc

# Load direnv.
eval "$(direnv hook bash)"
