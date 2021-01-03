#!/usr/bin/env bash
set -e

apt-get update

"$WDEN_BUILD_FOLDER"/apt_install_pkgs_for_dev.sh
"$WDEN_BUILD_FOLDER"/install_python.sh
"$WDEN_BUILD_FOLDER"/configure_oh_my_zsh.sh
"$WDEN_BUILD_FOLDER"/configure_sudo.sh
"$WDEN_BUILD_FOLDER"/install_fixuid.sh
