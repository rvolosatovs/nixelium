{
  self,
  flake-utils,
  nixpkgs,
  sops-nix,
  ...
}:
with flake-utils.lib.system; let
  emails.ops = "roman@profian.com"; # TODO: How about ops@profian.com ?

  oidc.client.try.equinix.sgx = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
  oidc.client.try.equinix.snp = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";

  oidc.client.testing.benefice = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
  oidc.client.testing.store = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";

  oidc.client.staging.store = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";

  oidc.client.production.store = "2vq9XnQgcGZ9JCxsGERuGURYIld3mcIh";

  mkHost = system: modules:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          "${self}/modules"
          ({config, ...}: {
            networking.firewall.allowedTCPPorts = [
              80
              443
            ];

            nix.settings.allowed-users = with config.users; [
              "@${groups.deploy.name}"
            ];
            nix.settings.trusted-users = with config.users; [
              "@${groups.deploy.name}"
            ];
            nixpkgs.overlays = [self.overlays.service];

            security.acme.defaults.email = emails.ops;
          })
        ]
        ++ modules;
    };

  mkService = base: system: modules: mkHost system (base ++ modules);

  exposeKey = pkgs: user: key:
    pkgs.writeShellScript "expose-${key}.sh" ''
      chmod 0400 "${key}"
      chown ${user}:${user} "${key}"
    '';

  hideKey = pkgs: user: key:
    pkgs.writeShellScript "hide-${key}.sh" ''
      chmod 0000 "${key}"
      chown ${user}:${user} "${key}"
    '';

  mkBenefice = mkService [
    sops-nix.nixosModules.sops
    ({
      config,
      lib,
      pkgs,
      ...
    }: {
      networking.firewall.enable = lib.mkForce false;

      services.benefice.enable = true;
      services.benefice.oidc.secretFile = config.sops.secrets.oidc-secret.path;

      services.nginx.clientMaxBodySize = "100m";

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      sops.secrets.oidc-secret.format = "binary";
      sops.secrets.oidc-secret.mode = "0000";
      sops.secrets.oidc-secret.restartUnits = ["benefice.service"];
      sops.secrets.oidc-secret.sopsFile = "${self}/hosts/${config.networking.fqdn}/oidc-secret";

      systemd.services.benefice.serviceConfig.ExecStartPre = "+${exposeKey pkgs "benefice" config.sops.secrets.oidc-secret.path}";
      systemd.services.benefice.serviceConfig.ExecStop = "+${hideKey pkgs config.users.users.root.name config.sops.secrets.oidc-secret.path}";
      systemd.services.benefice.serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
    })
  ];

  sgx-equinix-try = mkBenefice x86_64-linux [
    ({
      config,
      pkgs,
      ...
    }: {
      imports = [
        "${self}/hosts/sgx.equinix.try.enarx.dev"
      ];

      services.benefice.log.level = "info";
      services.benefice.oidc.client = oidc.client.try.equinix.sgx;
      services.benefice.package = pkgs.benefice.staging;
    })
  ];

  snp-equinix-try = mkBenefice x86_64-linux [
    ({
      config,
      pkgs,
      ...
    }: {
      imports = [
        "${self}/hosts/snp.equinix.try.enarx.dev"
      ];

      services.benefice.log.level = "info";
      services.benefice.oidc.client = oidc.client.try.equinix.snp;
      services.benefice.package = pkgs.benefice.staging;
    })
  ];

  mkDrawbridge = mkService [
    ({
      config,
      pkgs,
      ...
    }: {
      services.drawbridge.enable = true;
      services.drawbridge.tls.caFile = pkgs.writeText "ca.crt" (builtins.readFile "${self}/ca/${config.networking.domain}/ca.crt");

      services.nginx.clientMaxBodySize = "100m";
    })
  ];

  store-testing = mkDrawbridge x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/store.testing.profian.com"
      ];

      services.drawbridge.log.level = "debug";
      services.drawbridge.oidc.client = oidc.client.testing.store;
      services.drawbridge.package = pkgs.drawbridge.testing;
    })
  ];

  store-staging = mkDrawbridge x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/store.staging.profian.com"
      ];

      services.drawbridge.log.level = "info";
      services.drawbridge.oidc.client = oidc.client.staging.store;
      services.drawbridge.package = pkgs.drawbridge.staging;
    })
  ];

  store = mkDrawbridge x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/store.profian.com"
      ];

      services.drawbridge.oidc.client = oidc.client.production.store;
      services.drawbridge.package = pkgs.drawbridge.production;
    })
  ];

  mkSteward = mkService [
    sops-nix.nixosModules.sops
    ({
      config,
      pkgs,
      ...
    }: {
      services.steward.certFile = pkgs.writeText "steward.crt" (builtins.readFile "${self}/hosts/${config.networking.fqdn}/steward.crt");
      services.steward.enable = true;
      services.steward.keyFile = config.sops.secrets.key.path;

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      sops.secrets.key.format = "binary";
      sops.secrets.key.mode = "0000";
      sops.secrets.key.restartUnits = ["steward.service"];
      sops.secrets.key.sopsFile = "${self}/hosts/${config.networking.fqdn}/steward.key";

      systemd.services.steward.serviceConfig.ExecStartPre = "+${exposeKey pkgs "steward" config.sops.secrets.key.path}";
      systemd.services.steward.serviceConfig.ExecStop = "+${hideKey pkgs config.users.users.root.name config.sops.secrets.key.path}";
      systemd.services.steward.serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
    })
  ];

  attest-testing = mkSteward x86_64-linux [
    ({
      config,
      pkgs,
      ...
    }: {
      imports = [
        "${self}/hosts/attest.testing.profian.com"
      ];

      services.steward.log.level = "debug";
      services.steward.package = pkgs.steward.testing;
    })
  ];

  attest-staging = mkSteward x86_64-linux [
    ({
      config,
      pkgs,
      ...
    }: {
      imports = [
        "${self}/hosts/attest.staging.profian.com"
      ];

      services.steward.log.level = "info";
      services.steward.package = pkgs.steward.staging;
    })
  ];

  attest = mkSteward x86_64-linux [
    ({
      config,
      pkgs,
      ...
    }: {
      imports = [
        "${self}/hosts/attest.profian.com"
      ];

      services.steward.package = pkgs.steward.production;
    })
  ];
in {
  inherit
    attest
    attest-staging
    attest-testing
    sgx-equinix-try
    snp-equinix-try
    store
    store-staging
    store-testing
    ;
}
