#!/usr/bin/env bash
set -e

cd /etc/apt/sources.list.d/
mv cuda.list cuda.list.disabled || true
mv nvidia-ml.list nvidia-ml.list.disabled || true
