{
  self,
  flake-utils,
  nixos-generators,
  ...
}:
with flake-utils.lib.system;
  final: _: {
    install-iso = nixos-generators.nixosGenerate {
      format = "install-iso";
      system = x86_64-linux;
      modules = [
        ({modulesPath, ...}: {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
          ];
        })
        self.nixosModules.default
        (_: {
          environment.systemPackages = [
            final.partition-osmium
          ];
        })
      ];
    };
  }
