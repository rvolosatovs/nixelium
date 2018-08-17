{ config, pkgs, ... }:

{
  imports = [
    ./../..
    ./../../graphical.nix
  ];

  config = {
    home.packages = with pkgs; [
      alsaUtils
      arduino
      asciinema
      clang
      comic-relief
      drive
      go
      gocode
      gotools
      httpie
      julia
      keybase
      llvm
      llvmPackages.libclang
      macchanger
      platformio
      playerctl
      poppler_utils
      wineStaging
      winetricks
    ] ++ (with gitAndTools; [
      ghq
      git-extras
      git-open
      tig
    ]);

    meta.graphics.enable = true;

    programs.firefox.enableAdobeFlash = true;
    programs.git.signing.key = config.meta.gpg.publicKey.fingerprint;
    programs.git.signing.signByDefault = true;

    systemd.user.services.godoc.Unit.Description="Godoc server";
    systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
    systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
    systemd.user.services.godoc.Service.Restart="always";
  };
}
