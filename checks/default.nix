{self, ...} @ inputs: pkgs: {
  lib = import ./lib.nix inputs pkgs;

  cobalt = self.nixosConfigurations.cobalt.config.system.build.toplevel;
  osmium = self.nixosConfigurations.osmium.config.system.build.toplevel;

  install-iso = self.packages.${pkgs.hostPlatform.system}.install-iso;
}
