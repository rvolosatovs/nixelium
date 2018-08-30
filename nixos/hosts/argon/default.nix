{ config, pkgs, ... }:

let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    ./../../../meta/hosts/argon
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
      "nixos-config=${builtins.toPath ./.}"
    ];
  };
}
