{self, ...} @ inputs: pkgs: {
  lib = import ./lib.nix inputs pkgs;

  cobalt = self.nixosConfigurations.cobalt.config.system.build.toplevel;
  osmium = self.nixosConfigurations.osmium.config.system.build.toplevel;
  rvolosatovs-dev = self.nixosConfigurations.rvolosatovs-dev.config.system.build.toplevel;
}
