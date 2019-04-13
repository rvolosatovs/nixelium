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
      deluge
      drive
      go-2fa
      godef
      gotools
      httpie
      julia
      keybase
      libreoffice-fresh
      llvm
      llvmPackages.libclang
      macchanger
      minicom
      nixops
      platformio
      playerctl
      poppler_utils
      sshfs
      taskwarrior
      wego
      wineStaging
      winetricks
    ] ++ (with gitAndTools; [
      ghq
      git-extras
      git-open
      tig
    ]);

    programs.git.signing.key = config.resources.gpg.publicKey.fingerprint;
    programs.git.signing.signByDefault = true;

    programs.go.enable = true;
    programs.go.goPath = "";
    programs.go.goBin = ".local/bin.go";
    programs.go.packages = {
      "github.com/BurntSushi/toml"  = builtins.fetchGit "https://github.com/BurntSushi/toml";
      "github.com/BurntSushi/xgb"   = builtins.fetchGit "https://github.com/BurntSushi/xgb";
      "github.com/golang/dep"       = builtins.fetchGit "https://github.com/golang/dep";
      "github.com/google/go-github" = builtins.fetchGit "https://github.com/google/go-github";
      "github.com/mohae/deepcopy"   = builtins.fetchGit "https://github.com/mohae/deepcopy";
      "github.com/oklog/ulid"       = builtins.fetchGit "https://github.com/oklog/ulid";
      "github.com/pkg/errors"       = builtins.fetchGit "https://github.com/pkg/errors";
      "github.com/y0ssar1an/q"      = builtins.fetchGit "https://github.com/y0ssar1an/q";
      "golang.org/x/crypto"         = builtins.fetchGit "https://go.googlesource.com/crypto";
      "golang.org/x/exp"            = builtins.fetchGit "https://go.googlesource.com/exp";
      "golang.org/x/oauth2"         = builtins.fetchGit "https://go.googlesource.com/oauth2";
      "golang.org/x/sys"            = builtins.fetchGit "https://go.googlesource.com/sys";
      "golang.org/x/text"           = builtins.fetchGit "https://go.googlesource.com/text";
      "golang.org/x/time"           = builtins.fetchGit "https://go.googlesource.com/time";
      "google.golang.org/grpc"      = builtins.fetchGit "https://github.com/grpc/grpc-go";
    };

    programs.ssh.extraConfig = builtins.readFile ./../../../vendor/secrets/dotfiles/ssh/config;
    programs.ssh.matchBlocks."*.labs.overthewire.org".extraOptions.SendEnv = "OTWUSERDIR";
    programs.zsh.shellAliases.go="${pkgs.richgo}/bin/richgo";

    systemd.user.services.godoc.Unit.Description="Godoc server";
    systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
    systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
    systemd.user.services.godoc.Service.Restart="always";
  };
}
