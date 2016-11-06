#!/usr/bin/env bash

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime || exit 1
hwclock --systohc || exit 1

bootctl install || exit 1

mkinitcpio -p linux || exit 1

echo "Creating $1 user..."
useradd -G wheel,audio,video,disk,adm,docker,disk,ftp,mail,locate,rfkill,optical,storage,users,git -s /bin/zsh -m $1 || exit 1

locale-gen || exit 1

echo "root password:"
passwd || exit 1

echo "$1 password:"
passwd $1 || exit 1
