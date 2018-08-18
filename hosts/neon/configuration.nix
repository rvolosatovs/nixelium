{ config, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
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

  home-manager.users.${config.meta.username}.nixpkgs.overlays = config.nixpkgs.overlays;

  nixpkgs.overlays = [
    (self: super: {
      inherit (import <nixpkgs-unstable> {})
      cachix
      neovim
      neovim-unwrapped
      #nerdfonts
      sway
      #wine
      #wineStaging
      ;
    })
    #(self: super: {
      #inherit (import <nixpkgs-unstable> {})
      #bspwm
      #dep
      #git
      ##go
      ##gotools
      #grml-zsh-config
      #mopidy-iris
      ##platformio
      #;
    #})
  ];

  nix.nixPath = [
    "nixos-config=${builtins.toPath ./configuration.nix}"
  ];

  networking.hostName = "neon";
}
