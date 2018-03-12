{ lib, config, pkgs, ... }:

let
    unstable = import <nixpkgs-unstable> {};

    nixosDir = "${config.home.homeDirectory}/.dotfiles/nixos";

    secrets = import "${nixosDir}/var/secrets.nix";
    vars = import "${nixosDir}/var/variables.nix" { inherit pkgs; } // {
      browser = "${pkgs.chromium}/bin/chromium";
      mailer = "${pkgs.thunderbird}/bin/thunderbird";
    };
in

rec {
  _module.args = {
    inherit unstable;
    inherit vars;
    inherit secrets;
  };

  imports = [
    ../lib/common.nix
    ../lib/graphical.nix
  ];

  home.packages = with pkgs; [
    arduino
    keybase
    macchanger
    playerctl
    poppler_utils
    wireshark
  ] ++ (with unstable; [
    android-studio
    clang
    go
    gotools
    julia
    nodejs
    protobuf
    stack
  ]);


  programs.git.signing.key = "3D80C89E";
  programs.git.signing.signByDefault = true;
  programs.home-manager.path = config.xdg.configHome + "/nixpkgs/home-manager";
}
