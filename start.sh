#!/bin/bash
__create_user() {
USER=${1:-user}
useradd ${USER}
SSH_USERPASS=${2:-password}
echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin ${USER})
echo user: ${USER} password: $SSH_USERPASS
echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
}

# Call all functions
__create_user $1 $2
