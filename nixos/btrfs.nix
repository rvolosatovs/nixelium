{ config, pkgs, lib, ... }:
let
  snapperConfig = ''
    TIMELINE_CLEANUP=yes
    TIMELINE_CREATE=yes
  '';
in
{
  fileSystems = lib.mapAttrs (_: sub: {
    device = "/dev/disk/by-uuid/${config.resources.btrfs.uuid}";
    fsType = "btrfs";
    options = [ "subvol=${sub}" ] ++ lib.optionals config.resources.btrfs.isSSD [ "ssd" "noatime" "autodefrag" "compress=zstd" ];
  }) {
    "/" = "@";
    "/.snapshots" = "@-snapshots";
    "/home" = "@home";
    "/home/.snapshots" = "@home-snapshots";
  };

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [
    "/"
  ];

  services.snapper.configs.home.extraConfig = snapperConfig;
  services.snapper.configs.home.subvolume = "/home";

  services.snapper.configs.root.extraConfig = snapperConfig;
  services.snapper.configs.root.subvolume = "/";
}
