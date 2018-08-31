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
    boot.initrd.network.ssh.hostRSAKey = ./../../../vendor/secrets/nixos/hosts/oxygen/id_rsa.dropbear;

    home-manager.users.${config.meta.username} = {...}: {
      imports = [
        ./../../../meta/hosts/oxygen
      ];
    };

    networking.hostName = "oxygen";
  };
}
