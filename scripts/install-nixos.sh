#!/usr/bin/env sh
set -xe

nix-env -iA nixos.git

username=rvolosatovs
newhome=/mnt/home/${username}
dots=${newhome}/.dotfiles

./create-partitions.sh

nixos-generate-config --root /mnt
cd $HOME
mkdir -pv ${dots}
mv $HOME/dotfiles ${dots}
mv /mnt/etc/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix
rm -rf /mnt/etc/nixos
ln -s ../../home/${username}/.dotfiles/nixos /mnt/etc/nixos
mv /tmp/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix 
chown -R 1000:1000 ${dots}

git clone --depth 1 -b nixos-17.09 https://github.com/rvolosatovs/nixpkgs.git /mnt/nix/nixpkgs
chown -R 1000:1000 /mnt/nix/nixpkgs
