{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../resources/hosts/oxygen
    ./../../../vendor/nixos-hardware/common/pc/hdd
    ./../../../vendor/secrets/nixos/hosts/oxygen
    ./../../../vendor/secrets/resources/hosts/oxygen
    ./../../couchpotato.nix
    ./../../deluge.nix
    ./../../echoip.nix
    ./../../meet.nix
    ./../../profiles/server
    #./../../quake3.server.nix
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
