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

# Load oh-my-bash.
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
source /root/.bashrc

# Load direnv.
eval "$(direnv hook bash)"

# APT mirror.
if [ -n "$APT_SET_MIRROR_TENCENT" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_tencent.sh
elif [ -n "$APT_SET_MIRROR_ALIYUN" ] ; then
    sudo "$WDEN_RUN_FOLDER"/apt_set_mirror_aliyun.sh
fi

# PIP index.
if [ -n "$PIP_SET_INDEX_TENCENT" ] ; then
    export PIP_INDEX_URL='https://mirrors.cloud.tencent.com/pypi/simple/'
elif [ -n "$PIP_SET_INDEX_ALIYUN" ] ; then
    export PIP_INDEX_URL='https://mirrors.aliyun.com/pypi/simple/'
fi

# Home folder.
if [ -n "$CD_DEFAULT_FOLDER" ] ; then
    if [ -d "$CD_DEFAULT_FOLDER" ] ; then
        alias cd="HOME='${CD_DEFAULT_FOLDER}' cd"
        cd "$CD_DEFAULT_FOLDER"
    else
        echo "WARNING: CD_DEFAULT_FOLDER=${CD_DEFAULT_FOLDER} not exists."
    fi
fi

# SSH agent.
if [ -n "$SSH_AUTH_SOCK" ] ; then
    patch_file_permission "$SSH_AUTH_SOCK" '777'
    export SSH_OPTIONS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
fi

# SSH proxy.
if [ -n "$SSH_SOCKS5_PROXY" ] ; then
    export SSH_OPTIONS="${SSH_OPTIONS} -o ProxyCommand='ncat --proxy-type socks5 --proxy ${SSH_SOCKS5_PROXY} %h %p'"
fi

export GIT_SSH_COMMAND="ssh ${SSH_OPTIONS}"
alias ssh="ssh ${SSH_OPTIONS}"

# SSH login.
if [ -n "$SSHD_AUTHORIZED_KEYS" ] ; then
    echo "$SSHD_AUTHORIZED_KEYS" > "/home/${FIXUID_USER}/.ssh/authorized_keys"
fi

if [ -n "$SSHD_PORT" ] ; then
    sudo sed -i "s|#Port 22|Port ${SSHD_PORT}|g" /etc/ssh/sshd_config
    sudo service ssh start
fi

echo "Finished container setup..."
