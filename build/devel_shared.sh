#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

apt-get update

"$WDEN_BUILD_FOLDER"/apt_install_pkgs_for_dev.sh
"$WDEN_BUILD_FOLDER"/install_fixuid.sh
"$WDEN_BUILD_FOLDER"/install_python.sh
"$WDEN_BUILD_FOLDER"/configure_sudo.sh
"$WDEN_BUILD_FOLDER"/install_openssh_server.sh
"$WDEN_BUILD_FOLDER"/install_vscode_server.sh
"$WDEN_BUILD_FOLDER"/install_direnv.sh
"$WDEN_BUILD_FOLDER"/fix_run_permission.sh
"$WDEN_BUILD_FOLDER"/configure_shell.sh
