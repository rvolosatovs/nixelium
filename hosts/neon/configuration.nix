{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
  unstable = import <nixpkgs-unstable> {};
in
  {
    imports = [
      ./../../meta
      ./../../nixos/hardware/lenovo/thinkpad/x260
      ./../../nixos/profiles/laptop
      ./../../vendor/nixos-hardware/common/pc/laptop
      ./../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../vendor/secrets/hosts/neon/nixos
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

      home-manager.users.${config.meta.username} = {
        meta = {
          inherit (config.meta)
          base16
          graphical
          hostname
          ;
        };

        nixpkgs.overlays = config.nixpkgs.overlays;
        programs.go.package = unstable.go;
      };

      meta.base16.theme = "tomorrow-night";
      meta.graphical = true;
      meta.hostname = "neon";

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
    };
  }
