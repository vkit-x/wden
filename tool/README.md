[TOC]

## Overview

Goals

- Attempt to provide an out-of-the-box experience to use docker container as the development environment, especially for Python developer, ML/DL engineer & researcher.
- Setup a project boilerplate that is easy to understand. User with bash scripting and docker experience should be able to modify or extend the current codebase within 10 mins. While this project ships with the Python toolchain, most of the setup is not bound to Python, but instead is related to development experience (see the [Usage](#Usage) session). Hence this project could be extend to support variant scope development.

Section [Images](#Images) documents the out-of-the-box prebuilt images.
Section [Usage](#Usage) documents the typical use cases with examples.

## Images

### Hosted in Docker Hub

Supported constructs are as followed:

[TABLE_DOCKER_HUB]

### Hosted in Huawei Cloud

As a known issue, pulling from docker hub is intolerably slow for users in China. To speed up, images are also hosted in Huawei Cloud:

[TABLE_HUAWEICLOUD]

## Usage

### UID and GID forwarding

```bash
#####################
# IN THE HOST SHELL #
#####################
whoami
<< OUTPUT
huntzhan
OUTPUT

echo "$(id -u):$(id -g)"
<< OUTPUT
501:20
OUTPUT

# Pass UID/GID to --user and mount a folder to container
docker run \
  --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/data \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
whoami
<< OUTPUT
wden
OUTPUT

# Same UID/GID as host, thanks to https://github.com/boxboat/fixuid/
echo "$(id -u):$(id -g)"
<< OUTPUT
501:20
OUTPUT

cd /data
touch foobar
ls -l | grep foobar
<< OUTPUT
-rw-r--r--  1 wden dialout   0 Feb  5 14:24 foobar
OUTPUT

exit

#####################
# IN THE HOST SHELL #
#####################
ls -l | grep foobar
<< OUTPUT
-rw-r--r--   1 huntzhan  staff    0 Feb  5 22:24 foobar
OUTPUT
```

### Change the default cd folder

Env:

* `CD_DEFAULT_FOLDER` : If set, initialize the shell and change the `cd` default folder to this path.

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -e CD_DEFAULT_FOLDER=/data \
  -v "$(pwd)":/data \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
pwd
<< OUTPUT
/data
OUTPUT

alias cd
<< OUTPUT
alias cd='HOME='\''/data'\'' cd'
OUTPUT
```

### HTTP proxy setup

Env:

* `PROPAGATE_HTTPS_PROXY`: If set, will propagate `HTTPS_PROXY` to `HTTP_PROXY`, `https_proxy`, and `http_proxy`

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -e PROPAGATE_HTTPS_PROXY=1 \
  --add-host host.docker.internal:host-gateway \
  -e HTTPS_PROXY='http://host.docker.internal:8889' \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
cat << EOF
${HTTPS_PROXY}
${HTTP_PROXY}
${https_proxy}
${http_proxy}
EOF

<< OUTPUT
http://host.docker.internal:8889
http://host.docker.internal:8889
http://host.docker.internal:8889
http://host.docker.internal:8889
OUTPUT
```

### SSH agent forwarding in macOS

```bash
#####################
# IN THE HOST SHELL #
#####################
# Store passphrases in your keychain.
ssh-add -K /path/to/private-key-file

# Add all identities stored in your keychain.
# Make sure key identity is added before launching container.
ssh-add -A

# 1. The option "shared" in volume change the file permission of
# /run/ssh-auth.sock to 777 to make the file accessible by non-root user.
# 2. If SSH_AUTH_SOCK is set, the setup for SSH agent forwarding will be triggered.
docker run \
  --rm -it \
  -v /run/host-services/ssh-auth.sock:/run/ssh-auth.sock:shared \
  -e SSH_AUTH_SOCK="/run/ssh-auth.sock" \
  wden/wden:devel-cpu-ubuntu20.04-python3.8


##########################
# IN THE CONTAINER SHELL #
##########################
# Test connection (suppose you have added the github private key).
ssh -T git@github.com
<< OUTPUT
Warning: Permanently added 'github.com,13.250.177.223' (RSA) to the list of known hosts.
Hi huntzhan! You've successfully authenticated, but GitHub does not provide shell access.
OUTPUT

# ssh alias is set to bypass host checking.
alias ssh
<< OUTPUT
alias ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
OUTPUT

# Same here, to faciliate git operations.
echo $GIT_SSH_COMMAND
<< OUTPUT
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
OUTPUT
```

### SSH agent forwarding in Linux

```bash
#####################
# IN THE HOST SHELL #
#####################
# Make sure ssh-agent is up.
echo $SSH_AUTH_SOCK
<< OUTPUT
/tmp/ssh-adpxy7vPDaj7/agent.15833
OUTPUT

# Mount the socket file to container.
docker run \
  --rm -it \
  -v "$SSH_AUTH_SOCK":/run/ssh-auth.sock:shared \
  -e SSH_AUTH_SOCK="/run/ssh-auth.sock" \
  wden/wden:devel-cpu-ubuntu20.04-python3.8


##########################
# IN THE CONTAINER SHELL #
##########################
# Same as 'SSH agent forwarding in macOS'
```

### SSH proxy

Env:

* `SSH_SOCKS5_PROXY`: Should be formatted as `<host>:<port>`. If set, use such socks5 proxy in ssh connection.

```bash
#####################
# IN THE HOST SHELL #
#####################
# NOTE:
# 1. SSH_AUTH_SOCK is not necessary.
# 2. `host.docker.internal` refers to the hostname of the macOS host.
docker run \
  --rm -it \
  -v /run/host-services/ssh-auth.sock:/run/ssh-auth.sock:shared \
  -e SSH_AUTH_SOCK="/run/ssh-auth.sock" \
  --add-host host.docker.internal:host-gateway \
  -e SSH_SOCKS5_PROXY="host.docker.internal:1089" \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
alias ssh
<< OUTPUT
alias ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand='\''ncat --proxy-type socks5 --proxy host.docker.internal:1089 %h %p'\'''
OUTPUT

echo $GIT_SSH_COMMAND
<< OUTPUT
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand='ncat --proxy-type socks5 --proxy host.docker.internal:1089 %h %p'
OUTPUT

ssh -T git@github.com
<< OUTPUT
Warning: Permanently added 'github.com' (RSA) to the list of known hosts.
Hi huntzhan! You've successfully authenticated, but GitHub does not provide shell access.
OUTPUT
```

### SSH login to container

Env:

* `SSHD_AUTHORIZED_KEYS`: By default, [ssh_wden_rsa_key](https://github.com/vkit-x/wden-ssh-key/blob/master/ssh_wden_rsa_key.pub) has been setup. If you are conserned about the security, set this env to overwrite the `authorized_keys` file.
* `SSHD_PORT`: If set, start the sshd service and bind to this port.
* `DISABLE_SCREEN_DAEMON`: Disable the screen session for remote login.

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -e SSHD_PORT=3333 \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

#########################
# IN ANOTHER HOST SHELL #
#########################
ssh wden@localhost \
    -p 3333 \
    -o IdentitiesOnly=yes \
    -o IdentityFile=/path/to/wden-ssh-key/ssh_wden_rsa_key
```

Vscode `Remote - SSH` is well supported!

### Git config forwarding

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -v "$HOME"/.gitconfig:/etc/gitconfig:ro \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
git config --list | cat
<< OUTPUT
user.name=Hunt Zhan
user.email=huntzhan.dev@gmail.com
credential.helper=osxkeychain
OUTPUT
```

### Bash history forwarding

```bash
#####################
# IN THE HOST SHELL #
#####################
# "$HOME"/.bash_history will be forwarded to and changed by the container.
# https://ss64.com/bash/history.html
# NOTE: backup ~/.bash_history if you want to forward it.
docker run \
  --rm -it \
  -v /path/to/your/bash_history:/run/.bash_history \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
history
<< OUTPUT
<Same bash history as host>
OUTPUT
```

### Run as daemon

```bash
#####################
# IN THE HOST SHELL #
#####################
# NOTE: `-it` must be added.
docker run \
  -d -it \
  wden/wden:devel-cpu-ubuntu20.04-python3.8
```

### Use APT mirror sites

Env:

* `APT_SET_MIRROR_TENCENT` : If set, switch to use [Tencent's mirror](https://mirrors.cloud.tencent.com/help/ubuntu.html).
* `APT_SET_MIRROR_ALIYUN` : If set, switch to use [Aliyun's mirror](https://developer.aliyun.com/mirror/ubuntu).

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -e APT_SET_MIRROR_TENCENT=1 \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
<< OUTPUT
Run apt_set_mirror_tencent.sh
Get:1 http://mirrors.cloud.tencent.com/ubuntu bionic InRelease [242 kB]
Get:2 http://mirrors.cloud.tencent.com/ubuntu bionic-security InRelease [88.7 kB]
Hit:3 http://ppa.launchpad.net/deadsnakes/ppa/ubuntu bionic InRelease
Get:4 http://mirrors.cloud.tencent.com/ubuntu bionic-updates InRelease [88.7 kB]
Get:5 http://mirrors.cloud.tencent.com/ubuntu bionic/universe Sources [11.5 MB]
...
OUTPUT
```

### Upgrade `pip` to the latest version

Env:

* `PIP_UPGRADE_TO_LATEST`: If set, `pip` will be upgraded to the latest version.

### Use PyPI mirror sites

Env:

* `PIP_SET_INDEX_TENCENT`: Use Tencent's PyPI index.
* `PIP_SET_INDEX_ALIYUN` : Use Aliyun's PyPI index.

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -e PIP_SET_INDEX_TENCENT=1 \
  wden/wden:devel-cpu-ubuntu20.04-python3.8

##########################
# IN THE CONTAINER SHELL #
##########################
echo $PIP_INDEX_URL
<< OUTPUT
https://mirrors.cloud.tencent.com/pypi/simple/
OUTPUT
```

### Run customized scirpts

Env:

* `CUSTOMIZED_INIT_SH`: If set, this var should be the path to your script that will be executed only once during container setup.
* `CUSTOMIZED_REENTRANT_SH`: If set, this var should be the path to your script that will be executed in every login session.

```bash
#####################
# IN THE HOST SHELL #
#####################
docker run \
  --rm -it \
  -v /path/to/customized_init.sh:/run/customized_init.sh \
  -v /path/to/customized_reentrant.sh:/run/customized_reentrant.sh \
  -e CUSTOMIZED_INIT_SH='/run/customized_init.sh'\
  -e CUSTOMIZED_REENTRANT_SH='/run/customized_reentrant.sh'\
  wden/wden:devel-cpu-ubuntu20.04-python3.8
```
