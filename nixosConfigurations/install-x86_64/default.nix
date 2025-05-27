{
  self,
  flake-utils,
  ...
}:
with flake-utils.lib.system;
  self.lib.mkNixosInstallIsoSystem {
    system = x86_64-linux;
    modules = [
      ({pkgs, ...}: {
        environment.systemPackages = [
          pkgs.partition-osmium
        ];

        services.openssh.settings.PermitRootLogin = "yes";
      })
    ];
  }
