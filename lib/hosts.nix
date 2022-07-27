{
  self,
  nixpkgs,
  ...
}: rec {
  mkHost = base: system: extraModules:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          self.nixosModules.common
          self.nixosModules.users
        ]
        ++ base
        ++ extraModules;
    };

  mkService = base:
    mkHost ([
        ({...}: {
          networking.firewall.allowedTCPPorts = [
            80
            443
          ];

          nixpkgs.overlays = [self.overlays.service];
        })
      ]
      ++ base);
}
