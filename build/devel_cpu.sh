#!/usr/bin/env bash
set -e

"$WDEN_BUILD_FOLDER"/devel_shared.sh

echo '\nsource $WDEN_RUN_FOLDER/devel_cpu.sh' >> /opt/zsh/.zshrc