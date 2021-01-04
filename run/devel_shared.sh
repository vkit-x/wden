#!/usr/bin/env bash

export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /.bashrc

eval "$(direnv hook bash)"
