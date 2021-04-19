#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

exec bash --init-file "$WDEN_RUN_FOLDER"/devel_cuda.sh
