{
  self,
  flake-utils,
  ...
}:
with flake-utils.lib.system;
  self.lib.mkNixosInstallIsoSystem {
    system = aarch64-linux;
    modules = [
      ({pkgs, ...}: {
        environment.systemPackages = [
          pkgs.partition-osmium
        ];
      })
    ];
  }
