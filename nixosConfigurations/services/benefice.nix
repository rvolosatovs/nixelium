{
  self,
  enarx,
  flake-utils,
  nixpkgs,
  ...
}:
with flake-utils.lib.system; let
  beneficeModules.common = {
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
          services.benefice.enable = true;
          services.benefice.oidc.issuer = "https://auth.profian.com";
        }
        (mkIf (config.profian.environment == "testing") {
          services.benefice.log.level = "debug";
          services.benefice.package = pkgs.benefice.testing;
        })
        (mkIf (config.profian.environment == "staging") {
          services.benefice.log.level = "info";
          services.benefice.package = pkgs.benefice.staging;
        })
        (mkIf (config.profian.environment == "production") {
          services.benefice.log.level = "info";
          services.benefice.package = pkgs.benefice.production;
        })
      ];
    };

  beneficeModules.ec2 = {modulesPath, ...}: {
    imports = [
      "${modulesPath}/virtualisation/amazon-image.nix"
    ];

    networking.hostName = "benefice";

    # NOTE: /dev/kvm is not present on systems
    services.enarx.backend = "nil";

    services.steward.nginx.enable = true;
  };

  beneficeModules.equinix = {...}: {
    profian.provider = "equinix";
  };

  mkEC2 = modules:
    nixpkgs.lib.nixosSystem {
      system = x86_64-linux;
      modules =
        [
          beneficeModules.common
          beneficeModules.ec2
        ]
        ++ modules;
    };

  benefice-testing = mkEC2 [
    ({...}: {
      networking.domain = "testing.profian.com";

      profian.environment = "testing";

      services.benefice.oidc.client = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
      services.benefice.demoFqdn = "benefice.testing.profian.cloud";
    })
  ];

  mkEquinix = modules:
    nixpkgs.lib.nixosSystem {
      system = x86_64-linux;
      modules =
        [
          beneficeModules.common
          beneficeModules.equinix
        ]
        ++ modules;
    };

  sgx-equinix-try = mkEquinix [
    ({
      config,
      lib,
      ...
    }: let
      pccsServiceName = "${config.virtualisation.oci-containers.backend}-pccs";
      intelApiKeyFile = config.sops.secrets.intel-api-key.path;
    in {
      imports = [
        "${self}/hosts/sgx.equinix.try.enarx.dev"
      ];

      boot.kernelModules = [
        "kvm-intel"
      ];

      # TODO: Move SGX-specific logic into a `sgx` module
      hardware.cpu.intel.sgx.provision.enable = true;
      hardware.cpu.intel.updateMicrocode = true;

      networking.hostName = "sgx";
      networking.domain = "equinix.try.enarx.dev";

      profian.environment = "production";

      sops.secrets.intel-api-key.format = "binary";
      sops.secrets.intel-api-key.mode = "0000";
      sops.secrets.intel-api-key.restartUnits = [pccsServiceName];

      services.aesmd.enable = true;
      services.aesmd.qcnl.settings.pccsUrl = "https://127.0.0.1:8081/sgx/certification/v3/";
      services.aesmd.qcnl.settings.useSecureCert = false;

      services.benefice.oidc.client = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
      services.benefice.demoFqdn = "sgx.try.enarx.profian.cloud";

      services.enarx.backend = "sgx";

      services.pccs.apiKeyFile = intelApiKeyFile;
      services.pccs.enable = true;

      systemd.services."${pccsServiceName}" = {
        preStart = lib.mkBefore ''
          chmod 0400 "${intelApiKeyFile}"
        '';
        postStop = lib.mkBefore ''
          chmod 0000 "${intelApiKeyFile}"
        '';
        serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
      };
    })
  ];

  snp-equinix-try = mkEquinix [
    ({...}: {
      imports = [
        "${self}/hosts/snp.equinix.try.enarx.dev"
      ];

      boot.kernelModules = [
        "kvm-amd"
      ];

      hardware.cpu.amd.sev.enable = true;
      hardware.cpu.amd.sev.mode = "0660";

      hardware.cpu.amd.updateMicrocode = true;

      networking.hostName = "snp";
      networking.domain = "equinix.try.enarx.dev";

      profian.environment = "production";

      services.benefice.oidc.client = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";
      services.benefice.demoFqdn = "snp.try.enarx.profian.cloud";

      services.enarx.backend = "sev";
    })
  ];
in {
  inherit
    benefice-testing
    sgx-equinix-try
    snp-equinix-try
    ;
}
