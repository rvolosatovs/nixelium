{ config, pkgs, lib, ... }:

{
  imports = [
    ./../..
    ./../../graphical.nix
    ./../../keybase.nix
    ./../../pass.nix
  ];

  config = {
    home.packages = with pkgs; [
      alsaUtils
      arduino
      asciinema
      clang
      drive
      gocode
      godef
      gotools
      httpie
      julia
      keybase
      llvm
      llvmPackages.libclang
      macchanger
      nixops
      platformio
      playerctl
      poppler_utils
      taskwarrior
      wineStaging
      winetricks
    ] ++ (with gitAndTools; [
      ghq
      git-extras
      git-open
      tig
    ]);

    programs.firefox.enableAdobeFlash = true;

    programs.git.signing.key = config.resources.gpg.publicKey.fingerprint;
    programs.git.signing.signByDefault = true;

    programs.go.enable = true;
    programs.go.goPath = "";
    programs.go.goBin = ".local/bin.go";
    programs.go.packages = with lib;
    let
      fromGitMap = host: namespace: map (name: nameValuePair "${namespace}/${name}" (builtins.fetchGit "${host}/${name}").outPath);
    in
    listToAttrs ( fromGitMap "https://github.com" "github.com" [
      "BurntSushi/toml"
      "BurntSushi/xgb"
      "mohae/deepcopy"
      "pkg/errors"

    ] ++ fromGitMap "https://go.googlesource.com" "golang.org/x" [
      "crypto"
      "exp"
      "text"
      "time"
    ]);

    programs.ssh.extraConfig = builtins.readFile ./../../../vendor/secrets/dotfiles/ssh/config;
    programs.ssh.matchBlocks."*.labs.overthewire.org".extraOptions.SendEnv = "OTWUSERDIR";
    programs.zsh.shellAliases.go="${pkgs.richgo}/bin/richgo";

    systemd.user.services.godoc.Unit.Description="Godoc server";
    systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
    systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
    systemd.user.services.godoc.Service.Restart="always";
  };
}
