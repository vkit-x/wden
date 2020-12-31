#!/usr/bin/env bash
set -e

# Don't waste time to query nvidia repo.
"$DEN_SCRIPT_FOLDER"/apt_disable_nvidia_repo.sh

apt-get update

"$DEN_SCRIPT_FOLDER"/apt_install_pkgs_for_dev.sh
"$DEN_SCRIPT_FOLDER"/configure_oh_my_zsh.sh
