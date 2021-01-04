#!/usr/bin/env bash
set -e

# Don't waste time to query nvidia repo.
"$WDEN_BUILD_FOLDER"/apt_disable_nvidia_repo.sh
"$WDEN_BUILD_FOLDER"/devel_shared.sh
