{self, ...} @ inputs: pkgs:
with pkgs.lib;
  {
    lib = import ./lib.nix inputs pkgs;

    neovim = self.packages.${pkgs.hostPlatform.system}.neovim;
  }
  // optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64) {
    install-iso-x86_64-linux = self.packages.${pkgs.hostPlatform.system}.install-iso-x86_64-linux;

    cobalt = self.nixosConfigurations.cobalt.config.system.build.toplevel;
    osmium = self.nixosConfigurations.osmium.config.system.build.toplevel;
  }
  // optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAarch64) {
    install-iso-aarch64-linux = self.packages.${pkgs.hostPlatform.system}.install-iso-aarch64-linux;
  }
  // optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) {
    iridium = self.darwinConfigurations.iridium.config.system.build.toplevel;
  }
