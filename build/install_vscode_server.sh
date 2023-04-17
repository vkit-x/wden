#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Install vscode remote server.
wget https://update.code.visualstudio.com/latest/server-linux-x64/stable \
    -O /tmp/vscode-server-linux-x64.tar.gz
tar xvzf /tmp/vscode-server-linux-x64.tar.gz -C /tmp/
rm -f /tmp/vscode-server-linux-x64.tar.gz

apt-get install -y jq

VSCODE_SERVER_COMMIT=$(cat /tmp/vscode-server-linux-x64/product.json | jq -r '.commit')
mkdir -p "/home/${FIXUID_USER}/.vscode-server/bin"
mv /tmp/vscode-server-linux-x64 "/home/${FIXUID_USER}/.vscode-server/bin/${VSCODE_SERVER_COMMIT}"
chown -R "${FIXUID_USER}:${FIXUID_GROUP}" "/home/${FIXUID_USER}/.vscode-server"

# Install vscode plugin. (must run as target user)
CODE_SERVER="/home/${FIXUID_USER}/.vscode-server/bin/${VSCODE_SERVER_COMMIT}/bin/code-server"
su - $FIXUID_USER \
    -c "${CODE_SERVER} --install-extension ms-python.python"
su - $FIXUID_USER \
    -c "${CODE_SERVER} --install-extension editorconfig.editorconfig"
su - $FIXUID_USER \
    -c "${CODE_SERVER} --install-extension canna.box-comment"
# Remove jupyter plugin.
su - $FIXUID_USER \
    -c "${CODE_SERVER} --uninstall-extension ms-toolsai.jupyter" || true
