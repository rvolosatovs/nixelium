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
        poppler_utils
        sshfs
        taskwarrior
        wego
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
        playerctl
        wineStaging
        winetricks
      ];

      systemd.user.services.godoc.Unit.Description="Godoc server";
      systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
      systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
      systemd.user.services.godoc.Service.Restart="always";
    })
  ];
}
