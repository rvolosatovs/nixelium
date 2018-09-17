[
  (_: _: {
    inherit (import ./../vendor/nixpkgs-unstable { overlays = []; })
    arduino
    bspwm
    cachix
    dep
    direnv
    go
    gocode
    godef
    gotools
    grml-zsh-config
    i3
    kitty
    neovim
    neovim-unwrapped
    platformio
    richgo
    rtorrent
    sway
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
