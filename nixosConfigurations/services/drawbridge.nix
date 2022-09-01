{
  self,
  flake-utils,
  nixpkgs,
  ...
}:
with flake-utils.lib.system; let
  drawbridgeModules.ec2 = {
    config,
    lib,
    modulesPath,
    pkgs,
    ...
  }:
    with lib; {
      imports = [
        self.nixosModules.service
        "${modulesPath}/virtualisation/amazon-image.nix"
      ];

      config = mkMerge [
        {
          networking.hostName = "store";

          services.drawbridge.enable = true;
          services.drawbridge.oidc.issuer = "https://auth.profian.com";
          services.drawbridge.oidc.label = "auth.profian.com";
        }
        (mkIf (config.profian.environment == "testing") {
          services.drawbridge.log.level = "debug";
          services.drawbridge.package = pkgs.drawbridge.testing;
        })
        (mkIf (config.profian.environment == "staging") {
          services.drawbridge.log.level = "info";
          services.drawbridge.package = pkgs.drawbridge.staging;
        })
        (mkIf (config.profian.environment == "production") {
          services.drawbridge.package = pkgs.drawbridge.production;
        })
      ];
    };

  mkEC2 = modules:
    nixpkgs.lib.nixosSystem {
      system = x86_64-linux;
      modules =
        [
          drawbridgeModules.ec2
        ]
        ++ modules;
    };

  store-testing = mkEC2 [
    ({...}: {
      networking.domain = "testing.profian.com";

      profian.environment = "testing";

      services.drawbridge.oidc.client = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";
    })
  ];

  store-staging = mkEC2 [
    ({...}: {
      networking.domain = "staging.profian.com";

      profian.environment = "staging";

      services.drawbridge.oidc.client = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";
    })
  ];

  store = mkEC2 [
    ({...}: {
      networking.domain = "profian.com";

      profian.environment = "production";

      services.drawbridge.oidc.client = "2vq9XnQgcGZ9JCxsGERuGURYIld3mcIh";
    })
  ];
in {
  inherit
    store
    store-staging
    store-testing
    ;
}
