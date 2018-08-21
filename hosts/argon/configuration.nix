{ config, pkgs, ... }:

let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    ./../../nixos/hardware/lenovo/thinkpad/w541
    ./../../nixos/profiles/laptop
    ./../../vendor/nixos-hardware/common/pc/ssd
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

    meta.base16.theme = "twilight";
    meta.hostname = "argon";

    nixpkgs.overlays = [
      (self: super: {
        inherit (unstable)
        bspwm
        cachix
        grml-zsh-config
        neovim
        neovim-unwrapped
        wine
        wineStaging
        ;
      })
    ];

    nix.nixPath = [
      "nixos-config=${builtins.toPath ./configuration.nix}"
    ];
  };
}
