let
  unstable = import <nixpkgs-unstable> { config = import ./config.nix; overlays = []; };
in [
  (_: _: {
    inherit (unstable)
    alacritty
    arduino
    bluez
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
    docker_compose
    echoip
    firefox
    fwupd
    geoclue2
    go
    go-2fa
    go-sct
    go-tools
    gocode
    gocode-gomod
    godef
    gofumpt
    gopass
    gotools
    govendor
    grml-zsh-config
    i3
    ioquake3
    ioquake3pointrelease
    kbfs
    keybase
    keybase-gui
    kitty
    lutris
    mbed-cli
    miniflux
    mopidy
    mopidy-iris
    mopidy-local-images
    mopidy-local-sqlite
    mopidy-soundcloud
    mopidy-spotify
    mopidy-spotify-tunigo
    mopidy-youtube
    nerdfonts
    neovim
    neovim-unwrapped
    nodePackages
    pass
    passExtensions
    platformio
    polybar
    pulseaudio-modules-bt
    qsyncthingtray
    quake3pointrelease
    quake3wrapper
    rclone
    redis
    redshift
    richgo
    ripgrep
    rofi
    skhd
    sway
    sxhkd
    syncthing
    syncthing-cli
    syncthing-tray
    vgo2nix
    vim
    vimPlugins
    vimUtils
    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    weechat
    wego
    zathura
    ;

    inherit (unstable.python3Packages)
    simple-websocket-server
    ;
  })

  (_: _: if !unstable.stdenv.isDarwin then {
    inherit (unstable)
    zathura
    ;

  } else {})

  (_: self: {
    nur = import ./../vendor/nur { pkgs = self; };
  })

  (_: self: {
    copier = self.callPackage ./../vendor/copier {
      inherit (self) buildGoPackage stdenv;
    };

    dumpster = self.callPackage ./../vendor/dumpster {
      inherit (self) buildGoPackage stdenv;
    };

    gorandr = self.callPackage ./../vendor/gorandr {
      inherit (self) buildGoPackage stdenv;
    };

    quake3ProprietaryPaks = with self; stdenv.mkDerivation {
      name = "quake3-paks";
      src = ./../vendor/quake3-paks; # TODO: Move to a stable location and create a package
      buildCommand = ''
        install -D -m644 $src/baseq3/pak0.pk3      $out/baseq3/pak0.pk3
        install -D -m644 $src/missionpack/pak1.pk3 $out/missionpack/pak1.pk3
        install -D -m644 $src/missionpack/pak2.pk3 $out/missionpack/pak2.pk3
        install -D -m644 $src/missionpack/pak3.pk3 $out/missionpack/pak3.pk3
      '';

      meta = with stdenv.lib; {
        description = "Proprietary Quake3 paks";
      };
    };
  })

  (_: self: let
    nerdfontRelease = fontName: sha256: with self; stdenv.mkDerivation rec {
      # Inspired by https://github.com/Mic92/nur-packages/blob/20eeaca1de1a385df5b41043a525b9e0942ad927/pkgs/fira-code-nerdfonts/default.nix

      name = "nerdfont-${fontName}-${version}";
      version = "2.0.0";

      src = fetchzip {
        inherit sha256;
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${fontName}.zip";
        stripRoot = false;
      };
      buildCommand = ''
        install -m444 -Dt $out/share/fonts/opentype $src/*.otf
        rm $out/share/fonts/opentype/*Windows\ Compatible.otf

        install -m444 -Dt $out/share/fonts/truetype $src/*.ttf
        rm $out/share/fonts/truetype/*Windows\ Compatible.ttf
      '';

      meta = with stdenv.lib; {
        description = "Nerdfont version of ${fontName}";
        homepage = https://github.com/ryanoasis/nerd-fonts;
        license = licenses.mit;
      };
    };
  in
  {
    furaCode = nerdfontRelease "FiraCode" "1bnai3k3hg6sxbb1646ahd82dm2ngraclqhdygxhh7fqqnvc3hdy";
  })

  (_: self: {
    git-rebase-all = self.writeShellScriptBin "git-rebase-all" ''
      set -e
      
      base=''${1:-master}
      for b in $(${self.git}/bin/git for-each-ref --no-contains "''${base}" refs/heads --format '%(refname:lstrip=2)'); do 
          ${self.git}/bin/git checkout -q "''${b}"
          if ! ${self.git}/bin/git rebase -q "''${base}" &> /dev/null; then 
              echo "''${b} can not be rebased automatically"
              ${self.git}/bin/git rebase --abort
          fi
      done
      
      ${self.git}/bin/git checkout -q "''${base}" && ${self.git}/bin/git branch --merged | grep -v '\*' | ${self.findutils}/bin/xargs -r ${self.git}/bin/git branch -d
    '';

    copy-sha-git = self.writeShellScriptBin "copy-sha-git" ''
      ${self.nix-prefetch-git}/bin/nix-prefetch-git ''${@} | jq -c -r '.sha256' | xclip -sel clip
    '';
  })

  (super: self: rec {
    firefox = self.wrapFirefox.override {
      config = self.lib.setAttrByPath [ self.firefox.browserName or (builtins.parseDrvName self.firefox.name).name ] {
        enableBrowserpass = true;
        enableDjvu = true;
        enableGoogleTalkPlugin = true;
      };
    } self.firefox {};

    ioquake3Full = self.quake3wrapper {
      name = "ioquake3-full";
      description = "Full ioquake3";
      paks = [ self.quake3pointrelease self.quake3ProprietaryPaks ];
    };

    neovim = self.wrapNeovim self.neovim-unwrapped (import ./neovim self);

    pass = self.pass.withExtensions (es: [ es.pass-otp ]);

    polybar = self.polybar.override {
      alsaSupport = false;
      githubSupport = true;
      mpdSupport = true;
      pulseSupport = true;
    };
  })
]
