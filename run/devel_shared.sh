#!/usr/bin/env bash

echo "Setting up container..."

source /root/.bashrc
source "$WDEN_RUN_FOLDER"/devel_setup_once.sh
source "$WDEN_RUN_FOLDER"/devel_setup_dynamic.sh

echo "Finished container setup..."
