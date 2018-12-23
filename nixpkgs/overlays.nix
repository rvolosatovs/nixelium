[
  (_: _: let
    unstable = import ./../vendor/nixpkgs-unstable { overlays = []; };
  in {
    inherit (unstable)
    alacritty
    arduino
    bspwm
    cachix
    deluge
    dep
    direnv
    echoip
    geoclue2
    go
    go-2fa
    go-sct
    gocode
    godef
    gopass
    gotools
    govendor
    grml-zsh-config
    i3
    ioquake3
    ioquake3pointrelease
    kbfs
    keybase
    kitty
    mopidy
    mopidy-iris
    mopidy-local-images
    mopidy-local-sqlite
    mopidy-soundcloud
    mopidy-spotify
    mopidy-spotify-tunigo
    mopidy-youtube
    neovim
    neovim-unwrapped
    pass
    passExtensions
    platformio
    pulseaudio-modules-bt
    qsyncthingtray
    quake3pointrelease
    quake3wrapper
    redshift
    richgo
    ripgrep
    rtorrent
    sway
    syncthing
    syncthing-cli
    syncthing-tray
    vim
    vimPlugins
    weechat
    wine
    wineStaging
    ;

    inherit (unstable.python3Packages)
    simple-websocket-server
    ;
  })
  (super: self: {
    copier = self.callPackage ./../vendor/copier {
      inherit (self) buildGoPackage stdenv;
    };

    gorandr = self.callPackage ./../vendor/gorandr {
      inherit (self) buildGoPackage stdenv;
    };

    dumpster = self.callPackage ./../vendor/dumpster {
      inherit (self) buildGoPackage stdenv;
    };

    firefox = self.wrapFirefox.override {
      config = self.lib.setAttrByPath [ self.firefox.browserName or (builtins.parseDrvName self.firefox.name).name ] {
        enableBrowserpass = true;
        enableDjvu = true;
        enableGoogleTalkPlugin = true;
      };
    } self.firefox {};

    neovim = self.neovim.override (import ./neovim self);

    pass = self.pass.withExtensions (es: [ es.pass-otp ]);

    quake3ProprietaryPaks = self.stdenv.mkDerivation {
      name = "quake3-paks";
      src = ./../vendor/quake3-paks;
      buildCommand = ''
        install -D -m644 $src/baseq3/pak0.pk3      $out/baseq3/pak0.pk3
        install -D -m644 $src/missionpack/pak1.pk3 $out/missionpack/pak1.pk3
        install -D -m644 $src/missionpack/pak2.pk3 $out/missionpack/pak2.pk3
        install -D -m644 $src/missionpack/pak3.pk3 $out/missionpack/pak3.pk3
      '';
    };

    ioquake3Full = self.quake3wrapper {
      name = "ioquake3-full";
      description = "Full ioquake3";
      paks = [ self.quake3pointrelease self.quake3ProprietaryPaks ];
    };
  })
]
