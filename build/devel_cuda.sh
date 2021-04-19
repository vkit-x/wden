#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Don't waste time to query nvidia repo.
"$WDEN_BUILD_FOLDER"/apt_disable_nvidia_repo.sh
"$WDEN_BUILD_FOLDER"/devel_shared.sh
