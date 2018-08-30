{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../meta/hosts/oxygen
    ./../../../vendor/nixos-hardware/common/pc/hdd
    ./../../../vendor/secrets/nixos/hosts/oxygen
    ./../../profiles/server
    ./hardware-configuration.nix
  ];

  config = {
    boot.initrd.luks.devices = [
      {
        name="luksroot";
        device="/dev/sda3";
        preLVM=true;
      }
    ];

    home-manager.users.${config.meta.username} = {...}: {
      imports = [
        ./../../../meta/hosts/oxygen
      ];
    };
  };
}
