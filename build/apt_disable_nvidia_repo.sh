#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

cd /etc/apt/sources.list.d/
mv cuda.list cuda.list.disabled || true
mv nvidia-ml.list nvidia-ml.list.disabled || true
