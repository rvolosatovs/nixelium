{ config, pkgs, lib, ... }:
{
  imports = [
    ./btrfs-backup.nix
    ./wireguard.nix
  ];
}
