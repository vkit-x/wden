

## Docker run environments

### `APT_SET_MIRROR_TENCENT`

Switch to use [Tencent's mirror](https://mirrors.cloud.tencent.com/help/ubuntu.html).

### `APT_SET_MIRROR_ALIYUN`

Switch to use [Aliyun's mirror](https://developer.aliyun.com/mirror/ubuntu).

### `PIP_SET_INDEX_TENCENT`

Use Tencent's PyPI index.

### `PIP_SET_INDEX_ALIYUN`

Use Aliyun's PyPI index.

### `CD_DEFAULT_FOLDER`

Change the `cd` default folder.

### `SSH_AUTH_SOCK`

If set, trigger the setup for SSH agent forwarding.

## Usage

### SSH agent forwarding in macOS

```bash
# IN THE HOST SHELL:

# Store passphrases in your keychain.
ssh-add -K /path/to/private-key-file

# Add all identities stored in your keychain.
# Make sure key identity is added before launching container.
ssh-add -A

# The option "shared" in volume change the file permission of
# /run/ssh-auth.sock to 777 to make the file accessible by non-root user.
docker run \
  --rm -it \
  -v /run/host-services/ssh-auth.sock:/run/ssh-auth.sock:shared \
  -e SSH_AUTH_SOCK="/run/ssh-auth.sock" \
  --user "$(id -u):$(id -g)" \
  wden/wden:devel-cpu-ubuntu18.04-python3.8


# IN THE CONTAINER SHELL:

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

# Same to faciliate git operations.
echo $GIT_SSH_COMMAND
<< OUTPUT
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
OUTPUT
```

### SSH agent forwarding in Linux

```bash
# IN THE HOST SHELL:

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
  --user "$(id -u):$(id -g)" \
  wden/wden:devel-cpu-ubuntu18.04-python3.8


# IN THE CONTAINER SHELL:
# Same as 'SSH agent forwarding in macOS'
```
