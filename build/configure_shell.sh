#!/usr/bin/env bash
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

echo "Install oh-my-bash."
# After installation, /root/.bashrc is configured with oh-my-bash setup.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Disable auto update and notification.
mv /root/.bashrc /root/.oh-my-bash.bashrc

BASHRC_CONFIG=$(
cat << 'EOF'

# oh-my.zsh
if [ -z "$DISABLE_OH_MY_BASH" ] ; then
    export DISABLE_UPDATE_PROMPT=true
    export DISABLE_AUTO_UPDATE=true
    source /root/.oh-my-bash.bashrc
fi

EOF
)
echo "$BASHRC_CONFIG" | tee -a /root/.bashrc > /dev/null

# Grant the wden user read & execute permissions.
chmod -R 755 /root/

echo "Install screen."
# Required by daemon session.
apt-get install -y screen


echo "Setup the .bash_profile for wden user."
# This script is invoked as an interactive login shell, or with --login.
# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# Hence, we set CMD instruction to execute the run.sh script, in which bash is explicitly executed
# with --login option. In other words, the following script will be executed when user
# - runs `docker run -it ...`, entering the shell that is in docker run session.
# - remote login through ssh.
BASH_PROFILE=$(
cat << 'EOF'

# Load oh-my-zsh.
source /root/.bashrc

# Load Python.
source ~/.bash_python

# Phrase init_pre.
if [ ! -f ~/.bash-session-env ]; then
    # Shell is in docker run session. In other words, shell IS NOT in screen daemon session.
    # Hence the following script will be execute only once. During the setup,
    # - `~/.bash-session-env` is created.
    # - screen daemon session is initialized.
    # - ...
    source "${WDEN_RUN_FOLDER}/run_${WDEN_RUN_TAG}_init_pre.sh"

    # NOTE: If the following statement is place before init_pre.sh,
    # the screen daemon session will inherits this var.
    export IN_DOCKER_RUN_SESSION=1

else
    # Shell IS in screen daemon session.
    # The init_pre script has be executed. At this moment, simply load the env.
    source ~/.bash-session-env

fi

# Phrase reentrant.
# This scirpt contains statements could be executed multiple times.
# NOTE: Remote ssh login will be attached to screen session at the end of this script.
#
# TODO: The scirpt sets some environment variables, which are also dumped to ~/.bash-session-env.
# Those environment variables can be removed from ~/.bash-session-env.
source "$WDEN_RUN_FOLDER"/run_${WDEN_RUN_TAG}_reentrant.sh

# Phrase init_post.
if [ -n "$IN_DOCKER_RUN_SESSION" ] ; then
    # Again, script will be execute only once.
    source "${WDEN_RUN_FOLDER}/run_${WDEN_RUN_TAG}_init_post.sh"
fi

EOF
)
echo "$BASH_PROFILE" | tee "/home/${FIXUID_USER}/.bash_profile" > /dev/null

echo "Setup .bashrc for wden user."
#
# This script is invoked as an interactive non-login shell.
# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# Hence, the following script will be executed for shell attached to screen session.
su - $FIXUID_USER \
    -c "cp ~/.bashrc ~/.bashrc.bak"
BASHRC=$(
cat << 'EOF'

export BASHRC_EXECUTED=1

# Load oh-my-zsh.
source /root/.bashrc

# Load Python.
source ~/.bash_python

# Phrase reentrant.
source ~/.bash-session-env
source "$WDEN_RUN_FOLDER"/run_${WDEN_RUN_TAG}_reentrant.sh

EOF
)
echo "$BASHRC" | tee "/home/${FIXUID_USER}/.bashrc" > /dev/null
