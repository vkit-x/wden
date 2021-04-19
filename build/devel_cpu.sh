#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

"$WDEN_BUILD_FOLDER"/devel_shared.sh
