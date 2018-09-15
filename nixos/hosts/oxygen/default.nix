{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../resources/hosts/oxygen
    ./../../../vendor/nixos-hardware/common/pc/hdd
    ./../../../vendor/secrets/nixos/hosts/oxygen
    ./../../couchpotato.nix
    ./../../deluge.nix
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

    networking.hostName = "oxygen";
  };
}
