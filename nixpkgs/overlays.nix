[
  (_: _: let
    unstable = import ./../vendor/nixpkgs-unstable { overlays = []; };
  in {
    inherit (unstable)
    arduino
    bspwm
    cachix
    deluge
    dep
    direnv
    go
    go-2fa
    gocode
    godef
    gotools
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
    platformio
    qsyncthingtray
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

    firefox = let
      pkg = self.firefox;
      mkConfig = self.lib.setAttrByPath [ pkg.browserName or (builtins.parseDrvName pkg.name).name ];
    in self.wrapFirefox.override {
      config = mkConfig {
        enableBrowserpass = true;
        enableDjvu = true;
        enableGoogleTalkPlugin = true;
      };
    } pkg {};

    neovim = self.neovim.override (import ./neovim self);
  })
]
