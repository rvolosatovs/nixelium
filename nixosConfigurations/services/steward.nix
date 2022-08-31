{
  self,
  flake-utils,
  nixpkgs,
  ...
}:
with flake-utils.lib.system; let
  stewardModules.common = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; {
      imports = [
        self.nixosModules.service
      ];

      config = mkMerge [
        {
          services.steward.enable = true;
        }
        (mkIf (config.profian.environment == "testing") {
          services.steward.package = pkgs.steward.testing;
          services.steward.log.level = "debug";
        })
        (mkIf (config.profian.environment == "staging") {
          services.steward.package = pkgs.steward.staging;
          services.steward.log.level = "info";
        })
        (mkIf (config.profian.environment == "production") {
          services.steward.package = pkgs.steward.production;
        })
      ];
    };

  stewardModules.ec2 = {modulesPath, ...}: {
    imports = [
      "${modulesPath}/virtualisation/amazon-image.nix"
    ];

    networking.hostName = "attest";

    services.steward.nginx.enable = true;
  };

  stewardModules.prod = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.profian.steward;
    in {
      options.profian.steward = {
        index = mkOption {
          type = types.ints.u32;
          description = "Steward deployment index";
          example = 2;
        };
      };

      imports = [
        ../groups/meta.nix
      ];

      config = {
        networking.hostName = "prod${builtins.toString cfg.index}";
        networking.domain = "steward.rdu.infra.profian.com";

        profian.environment = "production";
      };
    };

  mkEC2 = modules:
    nixpkgs.lib.nixosSystem {
      system = x86_64-linux;
      modules =
        [
          stewardModules.common
          stewardModules.ec2
        ]
        ++ modules;
    };

  attest-testing = mkEC2 [
    ({...}: {
      profian.environment = "testing";

      networking.domain = "testing.profian.com";
    })
  ];

  attest-staging = mkEC2 [
    ({...}: {
      profian.environment = "staging";

      networking.domain = "staging.profian.com";
    })
  ];

  attest = mkEC2 [
    ({...}: {
      profian.environment = "production";

      networking.domain = "profian.com";
    })
  ];

  mkProd = n:
    nixpkgs.lib.nixosSystem {
      system = x86_64-linux;
      modules = [
        stewardModules.common
        stewardModules.prod
        ({...}: {
          profian.steward.index = n;
        })
      ];
    };

  attest-production1 = mkProd 1;
  attest-production2 = mkProd 2;
  attest-production3 = mkProd 3;
  attest-production4 = mkProd 4;
in {
  inherit
    attest
    attest-staging
    attest-testing
    attest-production1
    attest-production2
    attest-production3
    attest-production4
    ;
}
