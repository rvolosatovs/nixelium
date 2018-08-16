{ config, pkgs, lib, ... }:

let
    unstable = import <nixpkgs-unstable> {};
in

rec {
  imports = [
    (import ../lib/common.nix {
      inherit pkgs config lib;
      graphical = true;
    })
  ];

  home.packages = with pkgs; [
    alsaUtils
    arduino
    asciinema
    clang
    comic-relief
    drive
    julia
    keybase
    llvm
    llvmPackages.libclang
    macchanger
    playerctl
    poppler_utils
    winetricks
  ] ++ (with unstable; [
    go
    gotools
    platformio
    wineStaging
  ]);


  programs.firefox.enableAdobeFlash = true;
  programs.firefox.package = unstable.firefox-unwrapped;
  programs.git.package = unstable.git;
  programs.git.signing.key = "3D80C89E";
  programs.git.signing.signByDefault = true;
  programs.home-manager.path = config.xdg.configHome + "/nixpkgs/home-manager";

  systemd.user.services.godoc.Unit.Description="Godoc server";
  systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
  systemd.user.services.godoc.Service.ExecStart="${unstable.gotools}/bin/godoc -http=:42002";
  systemd.user.services.godoc.Service.Restart="always";
}
