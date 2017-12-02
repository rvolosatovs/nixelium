#!/usr/bin/env sh
mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
git clone -b master https://github.com/rycee/home-manager ~/.config/nixpkgs/home-manager
ln -s ~/.config/nixpkgs/home-manager/overlay.nix ~/.config/nixpkgs/overlays/home-manager.nix
