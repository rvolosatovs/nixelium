let
  unstable = import <nixpkgs-unstable> {
    config = import ./config.nix;
    overlays = [];
  };
in [
  (
    _: super: {
      inherit
        (unstable)
        act
        alacritty
        alejandra
        arduino
        asciinema
        bat
        bat-extras
        borgbackup
        brave
        cachix
        cargo-edit
        cargo-tarpaulin
        cargo-watch
        cockroachdb
        deadcode
        deno
        direnv
        drive
        du-dust
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
        fzf
        go-2fa
        go-sct
        go-tools
        gocode
        gocode-gomod
        godef
        godot
        gofumpt
        gopass
        gopls
        gotools
        grim
        grml-zsh-config
        hyperfine
        imv
        ioquake3
        jackett
        kanshi
        kbfs
        keybase
        keybase-gui
        kitty
        lidarr
        linux_lqx
        linux_zen
        linuxPackages_latest
        linuxPackages_lqx
        linuxPackages_zen
        lutris
        mbed-cli
        minicom
        miniflux
        mkvtoolnix
        motion
        mpv
        mullvad-vpn
        neovim
        neovim-unwrapped
        nerdfonts
        nix-du
        nixfmt
        nixpkgs-fmt
        noto-fonts-emoji
        pavucontrol
        polybar
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
        tinygo
        tokei
        tree-sitter
        ungoogled-chromium
        vim
        vimPlugins
        vimUtils
        wasm-pack
        wasmtime
        waybar
        weechat
        wf-recorder
        wl-clipboard
        wlsunset
        wofi
        wrapFirefox
        wrapNeovim
        yarn
        ydotool
        youtube-dl
        ;

      gitAndTools =
        super.gitAndTools
        // {
          inherit
            (unstable.gitAndTools)
            delta
            gh
            ghq
            hub
            tig
            ;
        };

      python3Packages =
        super.python3Packages
        // {
          inherit
            (unstable.python3Packages)
            python-miio
            ;
        };
    }
  )

  (import ./../vendor/fenix/overlay.nix)

  (self: super: {
    inherit (import ./../vendor/neovim-nightly-overlay self super) neovim-nightly;
  })

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
    self: super: let
      callGoPackage = p:
        super.callPackage p {
          inherit (self) buildGoPackage stdenv;
        };
    in {
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
        paks = with self; [quake3pointrelease quake3hires quake3Paks];
      };
    }
  )

  (
    self: super:
      with self; {
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
      neovim = super.wrapNeovim super.neovim-unwrapped (import ./neovim self);

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

      firefox = with super;
        wrapFirefox firefox-unwrapped
        {
          forceWayland = true;

          ## Documentation available at:
          ## https://github.com/mozilla/policy-templates

          extraPolicies.CaptivePortal = true;
          extraPolicies.DisableFirefoxAccounts = true;
          extraPolicies.DisableFirefoxStudies = true;
          extraPolicies.DisablePocket = true;
          extraPolicies.DisableTelemetry = true;
          extraPolicies.ExtensionSettings = {};
          extraPolicies.FirefoxHome.Pocket = false;
          extraPolicies.FirefoxHome.Snippets = false;
          extraPolicies.UserMessaging.ExtensionRecommendations = false;
          extraPolicies.UserMessaging.SkipOnboarding = true;
        };
    }
  )
]
