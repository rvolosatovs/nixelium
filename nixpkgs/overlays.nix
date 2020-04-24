let
  unstable = import <nixpkgs-unstable> { config = import ./config.nix; overlays = []; };
in [
  (_: _: {
    inherit (unstable)
    alacritty
    amdvlk
    arduino
    bemenu
    borgbackup
    brave
    bspwm
    cachix
    chromium
    cockroachdb
    deadcode
    deluge
    dep
    direnv
    docker
    docker-compose
    docker-credential-helpers
    echoip
    fahclient
    fahcontrol
    fahviewer
    fira
    fira-code
    firefox
    firefoxWrapper
    firmwareLinuxNonFree
    fprintd
    fwupd
    gcc-arm-embedded-6
    gcc-arm-embedded-7
    gcc-arm-embedded-8
    gcc-arm-embedded-9
    geoclue2
    go
    go-2fa
    go-sct
    go-tools
    go_1_12
    go_1_13
    go_1_14
    gocode
    gocode-gomod
    godef
    godot
    gofumpt
    gopass
    gopls
    gotools
    govendor
    grim
    grml-zsh-config
    i3
    imv
    ioquake3
    ioquake3pointrelease
    iwd
    jackett
    kanshi
    kbfs
    keybase
    keybase-gui
    kitty
    libfprint
    lidarr
    linuxPackages_5_2
    linuxPackages_5_3
    linuxPackages_5_4
    linuxPackages_5_5
    linuxPackages_5_6
    linuxPackages_latest
    linuxPackagesFor
    lorri
    lutris
    mbed-cli
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
    mpv
    mullvad-vpn
    neovim
    neovim-unwrapped
    nerdfonts
    nodejs
    nodejs-10_x
    nodejs-12_x
    nodejs-slim
    nodejs-slim-10_x
    nodejs-slim-12_x
    nodejs-slim_latest
    nodejs_latest
    nodePackages
    nodePackages_10_x
    nodePackages_12_x
    nox
    pass
    passExtensions
    platformio
    polybar
    pulseaudio-modules-bt
    qsyncthingtray
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
    rls
    rofi
    sidequest
    skhd
    slurp
    sonarr
    spotify
    steam
    sway
    sxhkd
    syncthing
    syncthing-cli
    syncthing-tray
    thunderbird
    travis
    unity3d
    unityhub
    vgo2nix
    vim
    vimPlugins
    vimUtils
    vulkan-headers
    vulkan-loader
    vulkan-tools
    waybar
    weechat
    wego
    winePackages
    winePackagesFor
    winetricks
    wineWowPackages
    wl-clipboard
    wl-recorder
    wofi
    wrapNeovim
    yarn
    ydotool
    ytop
    zathura
    zoom-us
    ;

    inherit (unstable.python3Packages)
    python-miio
    ;
  })

  (self: super: {
    nur = import ./../vendor/nur {
      nurpkgs = super;
      pkgs = self;
    };
  })

  (import ./../vendor/nixpkgs-mozilla/rust-overlay.nix)

  (self: super: let
    callGoPackage = p: super.callPackage p {
      inherit (self) buildGoPackage stdenv;
    };
  in
  {
    copier = callGoPackage ./../vendor/copier;
    dumpster = callGoPackage ./../vendor/dumpster;
    gorandr = callGoPackage ./../vendor/gorandr;
  })

  (self: super: {
    quake3ProprietaryPaks = super.stdenv.mkDerivation {
      name = "quake3-paks";
      src = ./../vendor/quake3-paks; # TODO: Move to a stable location and create a package
      buildCommand = ''
        install -D -m644 $src/baseq3/pak0.pk3      $out/baseq3/pak0.pk3
        install -D -m644 $src/missionpack/pak1.pk3 $out/missionpack/pak1.pk3
        install -D -m644 $src/missionpack/pak2.pk3 $out/missionpack/pak2.pk3
        install -D -m644 $src/missionpack/pak3.pk3 $out/missionpack/pak3.pk3
      '';
      meta.description = "Proprietary Quake3 paks";
    };

    ioquake3Full = super.quake3wrapper {
      name = "ioquake3-full";
      description = "Full ioquake3";
      paks = with self; [ quake3pointrelease quake3ProprietaryPaks ];
    };
  })

  (self: super: with self; {
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
  })

  (self: super: {
    neovim = super.wrapNeovim self.neovim-unwrapped (import ./neovim self);

    nerdfonts = super.nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    };

    pass = super.pass.withExtensions (es: [ es.pass-otp ]);

    gopass = super.gopass.override {
      passAlias = true;
    };

    polybar = super.polybar.override {
      alsaSupport = false;
      githubSupport = true;
      mpdSupport = true;
      pulseSupport = true;
    };
  })
]
