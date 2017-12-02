#!/usr/bin/env bash
set -e

checkDep() {
    path=`command -v ${1}` && echo "${1} found at ${path}" || { echo "${1} not found" >&2 ; exit 1; }
}

echo "- Checking dependencies..."
checkDep git
checkDep nix-env

echo "- Ensuring /nix/var/nix/{profiles,gcroots}/per-user/${USER} are present..."
mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/${USER}

echo "- Cloning https://github.com/rycee/home-manager into ${HOME}/.config/nixpkgs/home-manager"
git clone -b master https://github.com/rycee/home-manager ~/.config/nixpkgs/home-manager

echo "- Adding home-manager to user's Nixpkgs using overlay at ${HOME}/.config/nixpkgs/overlays/home-manager.nix"
ln -sf ~/.config/nixpkgs/home-manager/overlay.nix ~/.config/nixpkgs/overlays/home-manager.nix

echo "- Installing home-manager using nix-env"
nix-env -f '<nixpkgs>' -iA home-manager
