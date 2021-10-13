{ config, pkgs, lib, ... }:

{
  imports = [
    ./../..
    ./../../graphical.nix
    ./../../keybase.nix
    ./../../pass.nix
  ];

  config = with lib; mkMerge [
    (
      {
        home.packages = with pkgs; [
          asciinema
          clang
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
          nixpkgs-fmt
          nmap
          pandoc
          poppler_utils
          quake3
          richgo
          rnix-lsp
          rtl-sdr
          rust-analyzer
          rust-bin.nightly.latest.default
          spotify
          taskwarrior
          ungoogled-chromium
          wego
          youtube-dl
        ] ++ (
          with gitAndTools; [
            ghq
            git-open
            tig
          ]
        );

        programs.go.enable = true;
        programs.go.goPath = "";
        programs.go.goBin = ".local/bin.go";

        programs.ssh.extraConfig = ''
          Include config.d/ssh_gateway
        '';
        programs.ssh.matchBlocks."*.labs.overthewire.org".extraOptions.SendEnv = "OTWUSERDIR";

        programs.zsh.shellAliases.go = "${pkgs.richgo}/bin/richgo";
      }
    )

    (
      mkIf pkgs.stdenv.isLinux {
        home.packages = with pkgs; [
          alsaUtils
          arduino
          macchanger
          playerctl
          sidequest
          sshfs
          steam
        ];
      }
    )
  ];
}
