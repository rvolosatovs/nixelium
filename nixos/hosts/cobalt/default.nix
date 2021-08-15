{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../resources/hosts/cobalt
    ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
    ./../../../vendor/secrets/nixos/hosts/cobalt
    ./../../../vendor/secrets/resources/hosts/cobalt
    ./../../hardware/lenovo/thinkpad/amd/x395
    ./../../lan.nix
    ./../../minidlna.nix
    ./../../profiles/laptop
    ./hardware-configuration.nix
  ];

  config = {
    boot.initrd.luks.devices.luksroot.device="/dev/nvme0n1p2";
    boot.initrd.luks.devices.luksroot.preLVM=true;
    boot.initrd.luks.devices.luksroot.allowDiscards=true;

    boot.kernelPackages = pkgs.linuxPackages_zen;

    home-manager.users.${config.resources.username} = {...}: import ./../../../home/hosts/cobalt;

    networking.firewall.allowedTCPPorts = [
      1885
      8885
    ];
    networking.firewall.allowedUDPPorts = [
      1700
      1701
      35421 # Xiaomi Smart Home
    ];

    networking.mullvad.client.privateKey = builtins.readFile ./../../../vendor/secrets/nixos/hosts/cobalt/wg.mullvad.private;
    networking.hostName = "cobalt";

    nix.nixPath = lib.mkBefore [
      "home-manager=${toString ./../../../vendor/home-manager}"
      "nixos-config=${toString ./.}"
      "nixpkgs-overlays=${toString ../../../nixpkgs/overlays.nix}"
      "nixpkgs-unstable=${toString ../../../vendor/nixpkgs/nixos-unstable}"
      "nixpkgs=${toString ../../../vendor/nixpkgs/nixos}"
    ];

    nix.registry.nixpkgs = {
      from = {
        type = "indirect";
        id = "nixpkgs";
      };
      to = {
        type = "path";
        path = toString ../../../vendor/nixpkgs/nixos;
      };
    };
    nix.registry.nixpkgs-unstable = {
      from = {
        type = "indirect";
        id = "nixpkgs-unstable";
      };
      to = {
        type = "path";
        path = toString ../../../vendor/nixpkgs/nixos-unstable;
      };
    };

    services.btrfs.butter.uuid = "23996086-ccb9-4e94-8ece-e45fe6f47718";
  };
}
