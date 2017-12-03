{ lib, config, pkgs, ... }:

let
    nixosDir = "${config.home.homeDirectory}/.dotfiles/nixos";

    unstable = import <nixpkgs-unstable> {};
    mypkgs = import <mypkgs> {};
    vars = import "${nixosDir}/var/variables.nix" { inherit pkgs; };
    secrets = import "${nixosDir}/var/secrets.nix";
in

rec {
  _module.args = {
    inherit unstable;
    inherit mypkgs;
    inherit vars;
    inherit secrets;
  };

  imports = [
    ../lib/common.nix
    ../lib/graphical.nix
  ];

  home.packages = with pkgs; [
    arduino
    pandoc
  ];
}
