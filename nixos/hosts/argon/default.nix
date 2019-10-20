{ config, pkgs, ... }:

let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in

{
  imports = [
    ./../../../resources/hosts/argon
    ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
    ./../../../vendor/secrets/hosts/argon/nixos
    ./../../hardware/lenovo/thinkpad/intel/w541
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

    networking.hostName = "argon";
  };
}
