#!/usr/bin/env bash
set -e

sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable
sudo nix-channel --update

./install-home-manager.sh
