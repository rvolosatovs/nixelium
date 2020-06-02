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
        cargo
        clang
        clippy
        copy-sha-git
        deluge
        drive
        engify
        ffmpeg
        git-rebase-all
        godot
        gofumpt
        gopls
        gotools
        imagemagick
        llvm
        llvmPackages.libclang
        minicom
        mkvtoolnix
        nixops
        nmap
        pandoc
        poppler_utils
        quake3
        richgo
        rls
        rsibreak
        rtl-sdr
        rust-analyzer
        rustc
        rustfmt
        spotify
        taskwarrior
        wego
        youtube-dl
        zoom-us
      ] ++ (with gitAndTools; [
        ghq
        git-open
        tig
      ]);

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
        libreoffice-fresh
        macchanger
        playerctl
        sidequest
        sshfs
        steam
        steam-run-native
      ];

      systemd.user.services.godoc.Unit.Description="Godoc server";
      systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
      systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
      systemd.user.services.godoc.Service.Restart="always";
    })
  ];
}
