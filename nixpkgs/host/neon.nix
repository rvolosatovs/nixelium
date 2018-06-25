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
    alsaUtils
    arduino
    asciinema
    clang
    drive
    go
    julia
    keybase
    llvm
    llvmPackages.libclang
    macchanger
    playerctl
    poppler_utils
  ] ++ (with unstable; [
    gotools
  ]);


  programs.git.signing.key = "3D80C89E";
  programs.git.signing.signByDefault = true;
  programs.home-manager.path = config.xdg.configHome + "/nixpkgs/home-manager";

  systemd.user.services.godoc.Unit.Description="Godoc server";
  systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
  systemd.user.services.godoc.Service.ExecStart="${unstable.gotools}/bin/godoc -http=:42002";
  systemd.user.services.godoc.Service.Restart="always";
}
