{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in
  {
    imports = [
      ./../../../resources/hosts/neon
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/neon
      ./../../../vendor/secrets/resources/hosts/neon
      ./../../hardware/lenovo/thinkpad/intel/x260
      ./../../minidlna.nix
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

      boot.kernelPackages = pkgs.linuxPackages_5_3;

      fileSystems."/".options = mountOpts;
      fileSystems."/home".options = mountOpts;

      home-manager.users.${config.resources.username} = {...}: {
        imports = [
          ./../../../home/hosts/neon
        ];
      };

      networking.hostName = "neon";
      networking.firewall.allowedTCPPorts = [
        1885
        8885
      ];
      networking.firewall.allowedUDPPorts = [
        1700
      ];

      nix.nixPath = lib.mkBefore [
        "home-manager=${toString ./../../../vendor/home-manager}"
        "nixos-config=${toString ./.}"
        "nixpkgs-overlays=${toString ../../../nixpkgs/overlays.nix}"
        "nixpkgs-unstable=${toString ../../../vendor/nixpkgs/nixos-unstable}"
        "nixpkgs=${toString ../../../vendor/nixpkgs/nixos}"
      ];
    };
  }
