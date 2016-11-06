#!/usr/bin/env bash

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
locale-gen
useradd -G wheel,audio,disk,dev,adm,docker,mopidy -s /bin/zsh -m $1
passwd
passwd $1
