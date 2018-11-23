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
    gotools
    govendor
    grml-zsh-config
    i3
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
    qsyncthingtray
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
    copier = super.callPackage ./../vendor/copier {
      inherit (self) buildGoPackage stdenv;
    };

    gorandr = super.callPackage ./../vendor/gorandr {
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
  })
]
