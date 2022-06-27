#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

su - $FIXUID_USER \
    -c "curl -sfL https://direnv.net/install.sh | bash"
