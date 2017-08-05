#!/usr/bin/env sh
set -xe

target=$1
shift

ssh-copy-id root@${target}
scp -r ~/.dotfiles root@${target}:dotfiles
ssh root@${target} $@
