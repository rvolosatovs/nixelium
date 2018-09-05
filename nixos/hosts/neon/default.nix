{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in
  {
    imports = [
      ./../../../resources/hosts/neon
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/neon
      ./../../hardware/lenovo/thinkpad/x260
      ./../../profiles/laptop
      ./hardware-configuration.nix
    ];

    config = {
      boot.initrd.luks.devices = [
        {
          name="luksroot";
          device="/dev/sda2";
          preLVM=true;
          allowDiscards=true;
        }
      ];

      fileSystems."/".options = mountOpts;
      fileSystems."/home".options = mountOpts;

      home-manager.users.${config.resources.username} = {...}: {
        imports = [
          ./../../../resources/hosts/neon
        ];
      };

      networking.hostName = "neon";

      nix.nixPath = [
        "nixos-config=${builtins.toPath ./.}"
      ];
    };
  }
