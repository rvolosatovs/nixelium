{ pkgs, ... }:
{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  packageOverrides = pkgs: {
    neovim = pkgs.neovim.override {
      vimAlias = true;
      extraPython3Packages = []; #TODO
    };
  };
}
