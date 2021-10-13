let
  unstable = import <nixpkgs-unstable> { config = import ./config.nix; overlays = [ ]; };
in
[
  (
    _: super: {
      inherit unstable;

      inherit (unstable)
        act
        alacritty
        arduino
        asciinema
        bat
        bat-extras
        borgbackup
        bottom
        brave
        cachix
        cockroachdb
        deadcode
        deno
        direnv
        docker
        docker-compose
        docker-credential-helpers
        drive
        echoip
        elmPackages
        exa
        fd
        fira
        fira-code
        firefox
        firefox-unwrapped
        firefox-wayland
        firefoxWrapper
        firmwareLinuxNonfree
        fprintd
        fzf
        gcc-arm-embedded-6
        gcc-arm-embedded-7
        gcc-arm-embedded-8
        gcc-arm-embedded-9
        go
        go-2fa
        go-sct
        go-tools
        go_1_15
        go_1_16
        go_1_17
        go_2-dev
        gocode
        gocode-gomod
        godef
        godot
        golangci-lint
        gofumpt
        gopass
        gopls
        gotools
        grim
        grml-zsh-config
        hyperfine
        imv
        ioquake3
        iwd
        jackett
        julia
        julia-lts
        julia-mono
        julia-stable
        julia_07
        julia_1
        julia_10
        julia_11
        julia_13
        julia_15
        kanshi
        kbfs
        keybase
        keybase-gui
        kitty
        libfprint
        libreoffice
        libreoffice-fresh
        libreoffice-fresh-unwrapped
        libreoffice-still
        libreoffice-still-unwrapped
        libreoffice-unwrapped
        lidarr
        linux_lqx
        linux_zen
        linuxkit
        linuxPackages_latest
        linuxPackages_lqx
        linuxPackages_zen
        lorri
        lutris
        mbed-cli
        minicom
        miniflux
        mkvtoolnix
        mopidy
        mopidy-iris
        mopidy-local-images
        mopidy-local-sqlite
        mopidy-soundcloud
        mopidy-spotify
        mopidy-spotify-tunigo
        mopidy-youtube
        motion
        mpv
        mullvad-vpn
        neovim
        neovim-unwrapped
        nerdfonts
        nix-du
        nixfmt
        nixpkgs-fmt
        nmap
        noto-fonts-emoji
        nox
        pavucontrol
        pipewire
        platformio
        polybar
        procs
        qmk
        qsyncthingtray
        quake3e
        quake3hires
        quake3pointrelease
        quake3wrapper
        radarr
        rclone
        redis
        redshift
        redshift-wlr
        restic
        richgo
        ripgrep
        rnix-lsp
        rofi
        rtl-sdr
        rust-analyzer
        rustup
        sd
        sidequest
        skim
        slurp
        sonarr
        spotify
        steam
        stt
        sumneko-lua-language-server
        syncthing
        syncthing-cli
        syncthing-tray
        thunderbird
        tokei
        travis
        tree-sitter
        ungoogled-chromium
        unity3d
        unityhub
        vgo2nix
        vim
        vimPlugins
        vimUtils
        vndr
        wasm-pack
        waybar
        webkit
        webkitgtk
        webkitgtk24x-gtk2
        webkitgtk24x-gtk3
        weechat
        wego
        wf-recorder
        winePackages
        winePackagesFor
        winetricks
        wineWowPackages
        wl-clipboard
        wlsunset
        wofi
        wrapFirefox
        wrapNeovim
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        yarn
        ydotool
        youtube-dl
        zathura
        zoom-us
        ;

      gitAndTools = super.gitAndTools // {
        inherit (unstable.gitAndTools)
          delta
          ghq
          hub
          tig
          ;
      };

      python3Packages = super.python3Packages // {
        inherit (unstable.python3Packages)
          python-miio
          ;
      };
    }
  )

  ( import ./../vendor/oxalica/rust-overlay )

  (
    self: super: {
      nur = import ./../vendor/nur {
        nurpkgs = super;
        pkgs = self;
      };
    }
  )

  (
    _: super: {
      lib = super.lib // import ./lib super.lib;
    }
  )

  (
    self: super:
      let
        callGoPackage = p: super.callPackage p {
          inherit (self) buildGoPackage stdenv;
        };
      in
      {
        copier = callGoPackage ./../vendor/copier;
        dumpster = callGoPackage ./../vendor/dumpster;
      }
  )

  (
    self: super: {
      quake3Paks = super.stdenv.mkDerivation {
        name = "quake3-paks";
        src = super.fetchFromGitHub {
          owner = "rvolosatovs";
          repo = "ioquake3-mac-install";
          rev = "91e37f075ebf65510e130981bdfdbfdc47265938";
          sha256 = "1rdjfcqp4df1cazgbkv6bcj5ddfg8ggg96kjickynnxw7xjxjanf";
        };
        buildCommand = with super; ''
          cat $src/dependencies/baseq3/pak0/pak0.z01 \
              $src/dependencies/baseq3/pak0/pak0.z02 \
              $src/dependencies/baseq3/pak0/pak0.z03 \
              $src/dependencies/baseq3/pak0/pak0.z04 \
              $src/dependencies/baseq3/pak0/pak0.zip > pak0-master.zip
          ${unzip}/bin/unzip -a pak0-master.zip || true
          install -Dm444 pak0.pk3 $out/baseq3/pak0.pk3
          install -Dm444 $src/dependencies/baseq3/q3key $out/baseq3/q3key
          install -Dm444 $src/extras/extra-pack-resolution.pk3 $out/baseq3/pak9hqq37test20181106.pk3
          install -Dm444 $src/extras/quake3-live-sounds.pk3 $out/baseq3/quake3-live-soundpack.pk3
          install -Dm444 $src/extras/hd-weapons.pk3 $out/baseq3/pakxy01Tv5.pk3
        '';
        meta.description = "Quake3 paks";
      };

      quake3 = super.quake3wrapper {
        name = "quake3";
        description = "quake3e with HD textures and sounds";
        paks = with self; [ quake3pointrelease quake3hires quake3Paks ];
      };
    }
  )

  (
    self: super: with self; {
      navi = "$HOME/.cargo";

      git-rebase-all = super.writeShellScriptBin "git-rebase-all" ''
        set -e

        base=''${1:-master}
        for b in $(${git}/bin/git for-each-ref --no-contains "''${base}" refs/heads --format '%(refname:lstrip=2)'); do 
            ${git}/bin/git checkout -q "''${b}"
            if ! ${git}/bin/git rebase -q "''${base}" &> /dev/null; then 
                echo "''${b} can not be rebased automatically"
                ${git}/bin/git rebase --abort
            fi
        done

        ${git}/bin/git checkout -q "''${base}" && ${git}/bin/git branch --merged | grep -v '\*' | ${findutils}/bin/xargs -r ${git}/bin/git branch -d
      '';

      copy-sha-git = super.writeShellScriptBin "copy-sha-git" ''
        ${nix-prefetch-git}/bin/nix-prefetch-git ''${@} | ${jq}/bin/jq -c -r '.sha256' | ${xclip}/bin/xclip -sel clip
      '';

      engify = super.writeShellScriptBin "engify" ''
        set -euo pipefail
        IFS=$'\n\t'

        function englishTracks {
          ${mkvtoolnix}/bin/mkvmerge -J "''${2}" | ${jq}/bin/jq -r "[ .tracks | .[] | select(.type==\"''${1}\") | select(.properties.language==\"eng\") | .id ] | join(\",\")"
        }

        function engify {
          local subs="$(englishTracks "subtitles" "''${1}")"
          local audio="$(englishTracks "audio" "''${1}")"

          if [ -z "''${subs}" ] && [ -z "''${audio}" ]; then
            return 0
          fi
          local args=()
          if [ -n "''${subs}" ]; then
            args+=( -s "''${subs}" )
          fi
          if [ -n "''${audio}" ]; then
            args+=( -a "''${audio}" )
          fi
          ${mkvtoolnix}/bin/mkvmerge ''${args[*]} -o "''${1}.eng" "''${1}" && ${busybox}/bin/mv -f "''${1}.eng" "''${1}"
        }

        function usage {
          echo "Usage: $(${busybox}/bin/basename "$0") <file>"
          exit 1
        }
        [[ $# -eq 0 ]] && usage

        for f in ''${@}; do
          engify "''${f}"
        done
      '';

      ip-link-toggle = super.writeShellScriptBin "ip-link-toggle" ''
        set -euo pipefail
        IFS=$'\n\t'

        function usage {
          echo "Usage: $(${busybox}/bin/basename "$0") <interface>"
          exit 1
        }
        [[ $# -ne 1 ]] && usage

        if [ "$(${iproute}/bin/ip link show dev "''${1}" | ${busybox}/bin/head -1 | ${busybox}/bin/sed 's/.*state \([[:alnum:]]\+\) .*/\1/g')" == "UP" ]; then
          ${iproute}/bin/ip link set "''${1}" down
        else
          ${iproute}/bin/ip link set "''${1}" up
        fi
      '';
    }
  )

  (
    self: super: {
      neovim = super.wrapNeovim self.neovim-unwrapped (import ./neovim self);

      nerdfonts = super.nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      };

      gopass = super.gopass.override {
        passAlias = true;
      };

      polybar = super.polybar.override {
        alsaSupport = false;
        githubSupport = true;
        mpdSupport = true;
        pulseSupport = true;
      };
    }
  )
]
