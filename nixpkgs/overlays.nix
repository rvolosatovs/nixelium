[
  (_: _: {
    inherit (import ./../vendor/nixpkgs-unstable { overlays = []; })
    arduino
    bspwm
    cachix
    deluge
    dep
    direnv
    go
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
  })
  (super: self: {
    copier = super.callPackage ./../vendor/copier {
      inherit (self) buildGoPackage stdenv;
    };

    gorandr = super.callPackage ./../vendor/gorandr {
      inherit (self) buildGoPackage stdenv;
    };

    neovim = self.neovim.override (import ./neovim self);
  })
]
