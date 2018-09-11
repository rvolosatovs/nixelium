super: self:

{
  copier = super.callPackage ./../vendor/copier {
    inherit (super) buildGoPackage stdenv;
  };

  gorandr = super.callPackage ./../vendor/gorandr {
    inherit (super) buildGoPackage stdenv;
  };

  # NOTE: super.neovim.override fails with infinite recursion.
  neovim = import ./neovim self;
}
