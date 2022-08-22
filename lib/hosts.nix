{
  self,
  nixpkgs,
  ...
}: rec {
  mkHost = base: system: extraModules: hostname:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          self.nixosModules.common
          self.nixosModules.users
        ]
        ++ base
        ++ extraModules
        ++ [
          ({...}: {
            imports = [
              "${self}/hosts/${hostname}"
            ];
          })
        ];
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
