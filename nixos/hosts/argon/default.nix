{ config, pkgs, ... }:

let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in

{
  imports = [
    ./../../../resources/hosts/argon
    ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
    ./../../../vendor/secrets/hosts/argon/nixos
    ./../../hardware/lenovo/thinkpad/w541
    ./../../profiles/laptop
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
        ./../../../resources/hosts/argon
      ];
    };

    networking.hostName = "argon";

    nix.nixPath = [
      "nixos-config=${builtins.toPath ./.}"
    ];
  };
}
