#!/usr/bin/env bash
set -e

# Don't waste time to query nvidia repo.
"$DEN_SCRIPT_FOLDER"/apt_disable_nvidia_repo.sh

apt-get update

