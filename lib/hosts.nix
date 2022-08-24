{
  self,
  nixpkgs,
  sops-nix,
  ...
}: rec {
  mkHost = base: system: extraModules: domain: hostName:
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
          sops-nix.nixosModules.sops
          ({...}: {
            networking.hostName = hostName;
            networking.domain = domain;

            imports = [
              "${self}/hosts/${hostName}.${domain}"
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
