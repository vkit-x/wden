#!/usr/bin/env bash
set -e

ZSH_HOME=/opt/zsh
mkdir -p $ZSH_HOME

# ZDOTDIR:
# http://zsh.sourceforge.net/Intro/intro_3.html
# https://wiki.archlinux.org/index.php/zsh
#
# ZSH:
# https://github.com/robbyrussell/oh-my-zsh/#custom-directory
#
# SHELL:
# https://help.ubuntu.com/community/EnvironmentVariables
SYSTEM_ZSHENV=/etc/zsh/zshenv

SYSTEM_ZSHENV_CONTENT=$(
cat << EOF
export ZDOTDIR=$ZSH_HOME
export ZSH=$ZSH_HOME/.oh-my-zsh
export SHELL=/usr/bin/zsh
EOF
)

echo "$SYSTEM_ZSHENV_CONTENT" > $SYSTEM_ZSHENV
# shellcheck disable=1090
. $SYSTEM_ZSHENV

# Install oh-my-zsh.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Set the startup file, from
# https://github.com/robbyrussell/oh-my-zsh/blob/master/templates/zshrc.zsh-template
OH_MY_ZSH_CONFIG=$(
cat << EOF
ZSH_THEME='robbyrussell'
plugins=(
  git
)
source $ZSH/oh-my-zsh.sh
EOF
)

echo "$OH_MY_ZSH_CONFIG" > "$ZDOTDIR/.zshrc"

# Grant all user the access.
chmod -R 755 $ZSH_HOME
