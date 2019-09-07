{ config, pkgs, lib, ... }:

{
  imports = [
    ./../..
    ./../../graphical.nix
    ./../../keybase.nix
    ./../../pass.nix
  ];

  config = with lib; mkMerge [
    ({
      home.packages = with pkgs; [
        asciinema
        clang
        copy-sha-git
        deluge
        drive
        git-rebase-all
        gofumpt
        gotools
        llvm
        llvmPackages.libclang
        minicom
        nixops
        nmap
        pandoc
        poppler_utils
        richgo
        taskwarrior
        wego
        zoom-us
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

      programs.ssh.extraConfig = ''
        Include config.d/ssh_gateway
      '';
      programs.ssh.matchBlocks."*.labs.overthewire.org".extraOptions.SendEnv = "OTWUSERDIR";

      programs.zsh.shellAliases.go="${pkgs.richgo}/bin/richgo";
    })

    (mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        alsaUtils
        arduino
        julia
        libreoffice-fresh
        lutris
        macchanger
        platformio
        playerctl
        sshfs
      ];

      systemd.user.services.godoc.Unit.Description="Godoc server";
      systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
      systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
      systemd.user.services.godoc.Service.Restart="always";
    })
  ];
}
