{ config, pkgs, lib, ... }:

{
  imports = [
    ./../..
    ./../../../vendor/secrets/home
    ./../../../vendor/secrets/resources
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
        mkvtoolnix
        nixops
        nmap
        pandoc
        poppler_utils
        richgo
        rtl-sdr
        steam
        steam-run-native
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

      programs.firefox.enable = true;
      programs.firefox.extensions =  with pkgs.nur.repos.rycee.firefox-addons; [
        auto-tab-discard
        cookie-autodelete
        dark-night-mode
        gopass-bridge
        https-everywhere
        link-cleaner
        multi-account-containers
        octotree
        peertubeify
        privacy-badger
        reddit-enhancement-suite
        refined-github
        save-page-we
        stylus
        text-contrast-for-dark-themes
        transparent-standalone-image
        ublock-origin
        vim-vixen
      ];

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
        macchanger
        playerctl
        sidequest
        sshfs
      ];

      systemd.user.services.godoc.Unit.Description="Godoc server";
      systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
      systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
      systemd.user.services.godoc.Service.Restart="always";
    })
  ];
}
