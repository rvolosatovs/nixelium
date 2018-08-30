{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
  unstable = import <nixpkgs-unstable> {};
in
  {
    imports = [
      ./../../../meta/hosts/neon
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/neon
      ./../../hardware/lenovo/thinkpad/x260
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

      home-manager.users.${config.meta.username} = {...}: {
        imports = [
          ./../../../meta/hosts/neon
        ];

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
        "nixos-config=${builtins.toPath ./.}"
      ];
    };
  }
