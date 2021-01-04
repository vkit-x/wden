#!/usr/bin/env bash
set -e

# Install oh-my-bash.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Grant all user the access.
chmod -R 755 /root/.oh-my-bash
chmod 755 /root/.bashrc

# Add to global startup script.
printf '\n%s\n' 'source /root/.bashrc' >> /etc/bashrc

# Initialize direnv.
printf '\n%s\n' 'eval "$(direnv hook zsh)"' >> /root/.bashrc
