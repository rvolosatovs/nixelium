{self, ...} @ inputs: pkgs: {
  lib = import ./lib.nix inputs pkgs;

  neovim = self.packages.${pkgs.hostPlatform.system}.neovim;
}
