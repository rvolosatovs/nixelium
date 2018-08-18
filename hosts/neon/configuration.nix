{ config, pkgs, lib, ... }:
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

    home-manager.users.${config.meta.username} = {
      nixpkgs.overlays = config.nixpkgs.overlays;
      programs.go.package = unstable.go;
    };

    nixpkgs.overlays = [
      (self: super: {
        inherit (unstable)
        bspwm
        cachix
        dep
        gotools
        grml-zsh-config
        neovim
        neovim-unwrapped
        platformio
        sway
        wine
        wineStaging
        ;
      })
    ];

    nix.nixPath = [
      "nixos-config=${builtins.toPath ./configuration.nix}"
    ];

    networking.hostName = "neon";
  }
