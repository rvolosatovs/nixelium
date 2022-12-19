{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.btrfs.butter;

  snapperConfig = ''
    NUMBER_CLEANUP=yes
    NUMBER_LIMIT=3
    TIMELINE_CLEANUP=yes
    TIMELINE_CREATE=yes
    TIMELINE_LIMIT_DAILY="3"
    TIMELINE_LIMIT_HOURLY="3"
    TIMELINE_LIMIT_MONTHLY="0"
    TIMELINE_LIMIT_WEEKLY="0"
    TIMELINE_LIMIT_YEARLY="0"
    TIMELINE_MIN_AGE="1800"
  '';
in {
  options = {
    services.btrfs.butter = {
      enable = mkEnableOption "butter BTRFS setup";

      uuid = mkOption {
        example = "95f03ff6-b94c-4a7b-b122-9ef73507e26b";
        type = types.str;
        description = "UUID of butter.";
      };

      isSSD = mkOption {
        example = false;
        default = true;
        type = types.bool;
        description = "Whether butter is on an SSD.";
      };
    };
  };

  config = mkIf cfg.enable {
    fileSystems =
      mapAttrs
      (_: sub: {
        device = "/dev/disk/by-uuid/${cfg.uuid}";
        fsType = "btrfs";
        options = ["subvol=${sub}"] ++ optionals cfg.isSSD ["ssd" "noatime" "autodefrag" "compress=zstd"];
      })
      {
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
  };
}
