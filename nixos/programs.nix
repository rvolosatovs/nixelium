{ config, lib, ...}:

with lib;

{
  config = mkMerge [
    {
      programs = {
        vim.defaultEditor = true;
        zsh = {
          enable = true;
          enableAutosuggestions = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          interactiveShellInit = ''
                      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
                      bindkey -v
                      HISTFILE="''${ZDOTDIR:-$HOME}/.zhistory"
                      source "`${pkgs.fzf-bin}/bin/fzf-share`/completion.zsh"
                      source "`${pkgs.fzf-bin}/bin/fzf-share`/key-bindings.zsh"
          '';
          promptInit="";
        };
        bash.enableCompletion = true;
        mosh.enable = true;
        command-not-found.enable = true;

        nixpkgs.config.allowUnfree = true;
        nix.nixPath = [
          "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
          "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
          "mypkgs=/nix/nixpkgs"
          "nixos-config=/etc/nixos/configuration.nix"
          "/nix/var/nix/profiles/per-user/root/channels"
        ];
        nixpkgs.overlays = [
          (self: super: with builtins;
          let
            # isNewer reports whether version of a is higher, than b
            isNewer = { a, b }: compareVersions a.version b.version == 1;

            # newest returns derivation with same name as pkg from super
            # if it's version is higher than version on pkg. pkg otherwise.
            newest = pkg:
            let
              name = (parseDrvName pkg.name).name;
              inSuper = if hasAttr name super then getAttr name super else null;
            in
            if (inSuper != null) && (isNewer { a = inSuper; b = pkg;} )
            then inSuper
            else pkg;
          in
          {
            #browserpass = newest mypkgs.browserpass;
            #go = unstable.go;
            mopidy-iris = newest mypkgs.mopidy-iris;
            #mopidy-local-sqlite = newest mypkgs.mopidy-local-sqlite;
            #mopidy-local-images = newest mypkgs.mopidy-local-images;
            #mopidy-mpris = newest mypkgs.mopidy-mpris;
            #neovim = newest mypkgs.neovim;
            #keybase = newest mypkgs.keybase;
            #ripgrep = unstable.ripgrep;
            rclone = mypkgs.rclone;
          })
        ];
      }
      environment.systemPackages = with pkgs; [
        lm_sensors
        pciutils
        lsof
        whois
        htop
        tree
        bc
        pv
        psmisc
        curl
        zip
        unzip
        gnumake
        wireguard
        dnscrypt-proxy
        git
        git-lfs
        fzf
        ripgrep
        neofetch
        rclone
        graphviz
        pandoc
        weechat
        rtorrent
        neovim
        gnupg
        gnupg1compat
        #grml-zsh-config
        xdg-user-dirs
        docker_compose
        docker-gc
        nox
      }
      (mkIf config.services.xserver.enable {
        programs = {
          ssh = {
            askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
            #startAgent = true;
          };

          adb.enable = true;
          light.enable = true;
          java.enable = true;
          wireshark.enable = true;
          gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
          };

          browserpass.enable = true;

          chromium = {
            enable = true;
            homepageLocation = "https://duckduckgo.com/?key=${secrets.duckduckgo.key}";
            extensions = [
              "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
              "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
              "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
              "jegbgfamcgeocbfeebacnkociplhmfbk" # browserpass
            ];
          };
        };
        environment.systemPackages = with pkgs; [
          linuxPackages.acpi_call
          acpi
          powertop
          microcodeIntel
          libnotify

          # X11
          xdo
          wmname
          xdotool
          xsel
          #xorg.xset
          #xorg.xsetroot
          xtitle
          xclip
          sxhkd
          slock
          #lemonbar-xft
          #stalonetray
          polybar
          autorandr


          # Dev
          go
          gotools
          nodejs
          protobuf
          nodejs
          julia
          gcc
          gradle
          universal-ctags
          gist
          influxdb
          redis
          travis

          # Multimedia
          mpv
          spotify
          youtube-dl
          imagemagick
          sxiv
          ffmpeg

          #smlnj # FIXME TUE

          # Random
          ansible
          gnome3.dconf
          gnome3.glib_networking
          pass
          playerctl
          firefox
          chromium
          #libreoffice
          gtk-engine-murrine
          #texlive.combined.scheme-small
          keybase
          slock
          wget
          termite
          zathura
          dunst
          maim
          slop
          redshift
          thunderbird
          rofi
          keychain
          networkmanagerapplet
          lxappearance
          xautolock
          xss-lock
        ];
      })
    ];
  }
