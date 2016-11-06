#!/usr/bin/env bash

#!/usr/bin/env sh
target=$1

ssh-copy-id root@${target}
scp ~/.dotfiles/arch/install.sh root@${target}:
ssh root@${target}
