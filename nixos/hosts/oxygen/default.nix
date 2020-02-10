{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../resources/hosts/oxygen
    ./../../../vendor/nixos-hardware/common/pc/hdd
    ./../../../vendor/secrets/nixos/hosts/oxygen
    ./../../../vendor/secrets/resources/hosts/oxygen
    ./../../btrfs.nix
    ./../../deluge.nix
    ./../../dumpster.nix
    ./../../echoip.nix
    ./../../meet.nix
    ./../../miniflux.nix
    ./../../profiles/server
    ./../../syncthing.nix
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

    home-manager.users.${config.resources.username} = import ./../../../home/hosts/oxygen;

    networking.hostName = "oxygen";

    networking.nat.externalInterface = "eth0";

    users.users.syncthing.extraGroups = [
      "deluge"
    ];
  };
}
