{ config, pkgs, ... }:

let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in

{
  imports = [
    ./../../nixos/hardware/lenovo/thinkpad/w541
    ./../../nixos/profiles/laptop
    ./../../vendor/nixos-hardware/common/pc/ssd
    ./hardware-configuration.nix
  ];

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

  nix.nixPath = [
    "nixos-config=${builtins.toPath ./configuration.nix}"
  ];
}
