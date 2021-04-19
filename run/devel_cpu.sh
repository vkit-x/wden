#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

source "$WDEN_RUN_FOLDER"/devel_shared.sh
