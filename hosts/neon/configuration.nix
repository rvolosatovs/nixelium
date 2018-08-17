{ config, pkgs, ... }:

let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    ./../../nixos/hardware/lenovo/thinkpad/x260
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

  nixpkgs.overlays = [
    (self: super: {
      inherit (unstable)
      git
      go
      gotools
      platformio
      wine
      wineStaging;
    })
  ];

  nix.nixPath = [
    "nixos-config=${builtins.toPath ./configuration.nix}"
  ];

  home-manager.users.${config.meta.username} = {
    nixpkgs.overlays = config.nixpkgs.overlays;
  };

  networking.hostName = "neon";
}
