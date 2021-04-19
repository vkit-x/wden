#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

chmod -R +rx "$WDEN_RUN_FOLDER"
