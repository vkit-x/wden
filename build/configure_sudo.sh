#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Reset root password.
echo "root:asdlkj" | chpasswd
# Allow all user to sudo without password.
echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
