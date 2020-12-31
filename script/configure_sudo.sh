#!/usr/bin/env bash
set -e

# Reset root password.
echo "root:asdlkj" | chpasswd
# Allow all user to sudo without password.
echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
