#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

apt-get install -y openssh-server

git clone https://github.com/vkit-x/wden-ssh-key.git /tmp/wden-ssh-key

# Host key.
cp /tmp/wden-ssh-key/ssh_host_* /etc/ssh

# Login key.
mkdir "/home/${FIXUID_USER}/.ssh"
SSHD_AUTHORIZED_KEYS="/home/${FIXUID_USER}/.ssh/authorized_keys"
cat /tmp/wden-ssh-key/ssh_wden_rsa_key.pub > "$SSHD_AUTHORIZED_KEYS"
chown -R "${FIXUID_USER}:${FIXUID_GROUP}" "/home/${FIXUID_USER}/.ssh"
chmod 600 "$SSHD_AUTHORIZED_KEYS"

rm -rf /tmp/wden-ssh-key
