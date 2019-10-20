{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in
  {
    imports = [
      ./../../../resources/hosts/cobalt
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/cobalt
      ./../../../vendor/secrets/resources/hosts/cobalt
      ./../../hardware/lenovo/thinkpad/amd/x395
      #./../../minidlna.nix
      ./../../profiles/laptop
      ./hardware-configuration.nix
    ];

    config = {
      boot.initrd.luks.devices = [
        {
          name="luksroot";
          device="/dev/nvme0n1p2";
          preLVM=true;
          allowDiscards=true;
        }
      ];

      fileSystems."/".options = mountOpts;
      fileSystems."/home".options = mountOpts;

      home-manager.users.${config.resources.username} = {...}: {
        imports = [
          ./../../../home/hosts/cobalt
        ];
      };

      networking.hostName = "cobalt";
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
