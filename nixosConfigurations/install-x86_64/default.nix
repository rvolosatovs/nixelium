{
  self,
  flake-utils,
  nixpkgs-nixos,
  ...
}:
with flake-utils.lib.system;
  nixpkgs-nixos.lib.nixosSystem {
    system = x86_64-linux;
    modules = [
      self.nixosModules.default

      self.nixosModules.install-iso
      ({pkgs, ...}: {
        environment.systemPackages = [
          pkgs.partition-osmium
          pkgs.partition-phosphorus
        ];
      })
    ];
  }
