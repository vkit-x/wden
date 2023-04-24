#!/usr/bin/env bash

echo "Setting up container..."

function patch_file_permission {
    FILE=$1
    OCTAL_PERMISSIONS=$2
    CUR_OCTAL_PERMISSIONS=$(stat -c '%a' "$FILE")
    if [ "$CUR_OCTAL_PERMISSIONS" != "$OCTAL_PERMISSIONS" ] ; then
        echo "WARNING: Patching the permissions of FILE=${FILE}" \
             "${CUR_OCTAL_PERMISSIONS} => ${OCTAL_PERMISSIONS}"
        sudo chmod "$OCTAL_PERMISSIONS" "$FILE"
        echo "Done."
    fi
}

# Patch device permissions in privileged mode.
patch_file_permission /dev/console '620'
patch_file_permission /dev/full '666'
patch_file_permission /dev/null '666'
patch_file_permission /dev/random '666'
patch_file_permission /dev/tty '666'
patch_file_permission /dev/urandom '666'
patch_file_permission /dev/zero '666'

# APT mirror.
if [ -n "$APT_SET_MIRROR_TENCENT" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_tencent.sh
elif [ -n "$APT_SET_MIRROR_ALIYUN" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_aliyun.sh
fi

# SSH agent.
if [ -n "$SSH_AUTH_SOCK" ] ; then
    patch_file_permission "$SSH_AUTH_SOCK" '777'
fi

# SSH login.
if [ -n "$SSHD_AUTHORIZED_KEYS" ] ; then
    echo "$SSHD_AUTHORIZED_KEYS" > "/home/${FIXUID_USER}/.ssh/authorized_keys"
fi

if [ -n "$SSHD_PORT" ] ; then
    sudo sed -i "s|#Port 22|Port ${SSHD_PORT}|g" /etc/ssh/sshd_config
    sudo service ssh start
fi

# Pip index.
if [ -n "$PIP_SET_INDEX_TENCENT" ] ; then
    export PIP_INDEX_URL='https://mirrors.cloud.tencent.com/pypi/simple/'
elif [ -n "$PIP_SET_INDEX_ALIYUN" ] ; then
    export PIP_INDEX_URL='https://mirrors.aliyun.com/pypi/simple/'
fi

# Pip.
if [ -n "$PIP_UPGRADE_TO_LATEST" ] ; then
    python -m pip install -U pip
fi

# Screen session.
if [ -z "$DISABLE_SCREEN_DAEMON" ] ; then
    # screen config.
    # https://www.gnu.org/software/screen/manual/html_node/Bind.html#Bind
    # https://www.gnu.org/software/screen/manual/html_node/Default-Key-Bindings.html#Default-Key-Bindings
    # https://www.gnu.org/software/screen/manual/html_node/Bind-Examples.html#Bind-Examples
    SCREENRC=$(
cat << 'EOF'

# As login shell
defshell -bash

# https://vim.fandom.com/wiki/GNU_Screen_integration
term screen-256color
maptimeout 5

# Reset some envs since screen session inherits envs.
unsetenv BASH_PYTHON_FLAG
unsetenv PATH

# alternate screen.
altscreen on

# Unbind all the bindings.
unbindall

# Then enable the following bindings.
bind -c demo d detach

# C-n
bindkey "^N" command -c demo

EOF
)
    echo "$SCREENRC" | tee -a ~/.screenrc > /dev/null
    # Start up screen as daemon.
    args=()
    if [ -n "$SCREEN_DAEMON_LOG" ] ; then
        args=(-L -Logfile "$SCREEN_DAEMON_LOG")
    fi
    # Setting `-e` to avoid conflicts with C-a binding.
    screen -dmS daemon -e '^Nn' "${args[@]}"
fi

BASH_SESSION_ENV=$(
cat << EOF

# Customized.
export DISABLE_OH_MY_BASH='$DISABLE_OH_MY_BASH'
export PIP_SET_INDEX_TENCENT='$PIP_SET_INDEX_TENCENT'
export PIP_SET_INDEX_ALIYUN='$PIP_SET_INDEX_ALIYUN'
export CD_DEFAULT_FOLDER='$CD_DEFAULT_FOLDER'
export SSH_AUTH_SOCK='$SSH_AUTH_SOCK'
export SSH_SOCKS5_PROXY='$SSH_SOCKS5_PROXY'
export PROPAGATE_HTTPS_PROXY='$PROPAGATE_HTTPS_PROXY'
export CUSTOMIZED_REENTRANT_SH='$CUSTOMIZED_REENTRANT_SH'
export DISABLE_SCREEN_DAEMON='$DISABLE_SCREEN_DAEMON'

# Dockerfile.
export PYTHONIOENCODING='$PYTHONIOENCODING'
export PYTHONUTF8='$PYTHONUTF8'
export LANG='$LANG'
export LC_CTYPE='$LC_CTYPE'
export LC_ALL='$LC_ALL'
export FIXUID_USER='$FIXUID_USER'
export FIXUID_GROUP='$FIXUID_GROUP'
export WDEN_BUILD_FOLDER='$WDEN_BUILD_FOLDER'
export WDEN_RUN_FOLDER='$WDEN_RUN_FOLDER'
export WDEN_RUN_TAG='$WDEN_RUN_TAG'

# Pip.
export PIP_INDEX_URL='$PIP_INDEX_URL'

# HTTP proxy.
export HTTPS_PROXY='$HTTPS_PROXY'
export HTTP_PROXY='$HTTP_PROXY'
export https_proxy='$https_proxy'
export http_proxy='$http_proxy'

EOF
)
echo "$BASH_SESSION_ENV" | tee -a ~/.bash-session-env > /dev/null

BASH_SESSION_ENV=$(
cat << 'EOF'

# Disable logout & exit command if is in screen session.
function _nop {
    echo 'Use (Ctrl+n d) to to leave the shell.'
}

if [ -n "$STY" ] ; then
    set -o ignoreeof
    alias logout=_nop
    alias exit=_nop
fi

EOF
)
echo "$BASH_SESSION_ENV" | tee -a ~/.bash-session-env > /dev/null

echo "Finished container setup..."
