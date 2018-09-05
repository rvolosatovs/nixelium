{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in
  {
    imports = [
      ./../../../resources/hosts/nitrogen
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/nitrogen
      ./../../hardware/lenovo/thinkpad/x230
      ./../../profiles/server
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
          ./../../../resources/hosts/nitrogen
        ];
      };

      networking.hostName = "nitrogen";
    };
  }
