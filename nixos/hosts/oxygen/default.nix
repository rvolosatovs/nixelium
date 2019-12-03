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
    ./../../miniflux.nix
    ./../../profiles/server
    #./../../ttn-docker.nix
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

    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;

    networking.hostName = "oxygen";

    networking.nat.externalInterface = "eth0";
  };
}
