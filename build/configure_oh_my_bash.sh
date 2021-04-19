#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Install oh-my-bash.
export OSH='/.oh-my-bash'
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
mv /root/.bashrc /.bashrc

# Other bash configuration.
BASH_CONFIG=$(
cat << "EOF"

# Tab completion.
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

EOF
)
echo "$BASH_CONFIG" | tee -a /.bashrc > /dev/null

# Grant all user the access.
chmod -R 755 /.oh-my-bash
chmod 755 /.bashrc
