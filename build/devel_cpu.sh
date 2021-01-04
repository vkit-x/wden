#!/usr/bin/env bash
set -e

"$WDEN_BUILD_FOLDER"/devel_shared.sh

# printf '\n%s\n' 'source $WDEN_RUN_FOLDER/devel_cpu.sh' >> /opt/zsh/.zshrc
printf '\n%s\n' 'source $WDEN_RUN_FOLDER/devel_cpu.sh' >> /.bashrc
