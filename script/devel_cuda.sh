#!/usr/bin/env bash
set -e

# Don't waste time to query nvidia repo.
"$WDEN_SCRIPT_FOLDER"/apt_disable_nvidia_repo.sh

apt-get update

"$WDEN_SCRIPT_FOLDER"/apt_install_pkgs_for_dev.sh
"$WDEN_SCRIPT_FOLDER"/install_python.sh
"$WDEN_SCRIPT_FOLDER"/configure_oh_my_zsh.sh
"$WDEN_SCRIPT_FOLDER"/configure_sudo.sh
"$WDEN_SCRIPT_FOLDER"/install_fixuid.sh
