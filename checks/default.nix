{self, ...} @ inputs: pkgs:
with pkgs.lib;
  {
    lib = import ./lib.nix inputs pkgs;

    neovim = self.packages.${pkgs.hostPlatform.system}.neovim;
  }
  // optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    install-iso = self.packages.${pkgs.hostPlatform.system}.install-iso;

    cobalt = self.nixosConfigurations.cobalt.config.system.build.toplevel;
    osmium = self.nixosConfigurations.osmium.config.system.build.toplevel;
  }
  // optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    iridium = self.darwinConfigurations.iridium.config.system.build.toplevel;
  }
