{
  description = "Profian Inc Network Infrastructure";

  inputs.benefice-staging.flake = false;
  inputs.benefice-staging.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc4/benefice-x86_64-unknown-linux-musl";
  inputs.benefice-testing.inputs.cargo2nix.follows = "cargo2nix";
  inputs.benefice-testing.inputs.flake-compat.follows = "flake-compat";
  inputs.benefice-testing.inputs.flake-utils.follows = "flake-utils";
  inputs.benefice-testing.inputs.nixpkgs.follows = "nixpkgs";
  inputs.benefice-testing.inputs.rust-overlay.follows = "rust-overlay";
  inputs.benefice-testing.url = github:profianinc/benefice;
  inputs.cargo2nix.inputs.flake-compat.follows = "flake-compat";
  inputs.cargo2nix.inputs.flake-utils.follows = "flake-utils";
  inputs.cargo2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.cargo2nix.inputs.rust-overlay.follows = "rust-overlay";
  inputs.cargo2nix.url = github:cargo2nix/cargo2nix;
  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge-production.flake = false;
  inputs.drawbridge-production.url = "https://github.com/profianinc/drawbridge/releases/download/v0.1.0/drawbridge-x86_64-unknown-linux-musl";
  inputs.drawbridge-staging.flake = false;
  inputs.drawbridge-staging.url = "https://github.com/profianinc/drawbridge/releases/download/v0.1.0/drawbridge-x86_64-unknown-linux-musl";
  inputs.drawbridge-testing.inputs.cargo2nix.follows = "cargo2nix";
  inputs.drawbridge-testing.inputs.flake-compat.follows = "flake-compat";
  inputs.drawbridge-testing.inputs.flake-utils.follows = "flake-utils";
  inputs.drawbridge-testing.inputs.nixpkgs.follows = "nixpkgs";
  inputs.drawbridge-testing.inputs.rust-overlay.follows = "rust-overlay";
  inputs.drawbridge-testing.url = github:profianinc/drawbridge;
  inputs.enarx.flake = false;
  # TODO: Use upstream release
  inputs.enarx.url = "https://github.com/rvolosatovs/enarx/releases/download/v0.6.1-rc1/enarx-x86_64-unknown-linux-musl";
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixpkgs.url = github:profianinc/nixpkgs;
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rust-overlay.url = github:oxalica/rust-overlay;
  inputs.steward-production.flake = false;
  inputs.steward-production.url = "https://github.com/profianinc/steward/releases/download/v0.1.0/steward-x86_64-unknown-linux-musl";
  inputs.steward-staging.flake = false;
  inputs.steward-staging.url = "https://github.com/profianinc/steward/releases/download/v0.1.0/steward-x86_64-unknown-linux-musl";
  inputs.steward-testing.inputs.flake-compat.follows = "flake-compat";
  inputs.steward-testing.inputs.flake-utils.follows = "flake-utils";
  inputs.steward-testing.inputs.nixpkgs.follows = "nixpkgs";
  inputs.steward-testing.url = github:profianinc/steward;

  outputs = {
    self,
    benefice-staging,
    benefice-testing,
    cargo2nix,
    deploy-rs,
    drawbridge-production,
    drawbridge-staging,
    drawbridge-testing,
    enarx,
    flake-compat,
    flake-utils,
    nixpkgs,
    rust-overlay,
    steward-production,
    steward-staging,
    steward-testing,
  }: let
    sshUser = "deploy";

    emails.ops = "roman@profian.com"; # TODO: How about ops@profian.com ?

    hosts.demo.equinix.sgx = "sgx.equinix.demo.enarx.dev";
    hosts.demo.equinix.snp = "snp.equinix.demo.enarx.dev";

    hosts.staging.attest = "attest.staging.profian.com";
    hosts.staging.store = "store.staging.profian.com";

    hosts.testing.attest = "attest.testing.profian.com";
    hosts.testing.store = "store.testing.profian.com";

    hosts.attest = "attest.profian.com";
    hosts.store = "store.profian.com";

    cert.staging.attest = ./hosts/attest.staging.profian.com/ca.crt;
    cert.testing.attest = ./hosts/attest.testing.profian.com/ca.crt;
    cert.production.attest = ./hosts/attest.profian.com/ca.crt;

    oidc.issuer = "auth.profian.com";

    oidc.client.demo.equinix.sgx = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
    oidc.client.demo.equinix.snp = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";

    oidc.client.testing.benefice = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
    oidc.client.testing.store = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";

    oidc.client.staging.store = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";

    oidc.client.store = "2vq9XnQgcGZ9JCxsGERuGURYIld3mcIh";
  in
    {
      nixosConfigurations = let
        system = "x86_64-linux";

        overlay = self: super: let
          fromInput = name: src:
            self.stdenv.mkDerivation {
              inherit name;
              phases = ["installPhase"];
              installPhase = ''
                mkdir -p $out/bin
                install ${src} $out/bin/${name}
              '';
            };
        in {
          benefice.testing = benefice-testing.packages.x86_64-linux.benefice-debug-x86_64-unknown-linux-musl;
          benefice.staging = fromInput "benefice" benefice-staging;

          enarx.staging = fromInput "enarx" enarx;

          drawbridge.testing = drawbridge-testing.packages.x86_64-linux.drawbridge-debug-x86_64-unknown-linux-musl;
          drawbridge.staging = fromInput "drawbridge" drawbridge-staging;
          drawbridge.production = fromInput "drawbridge" drawbridge-production;

          steward.testing = steward-testing.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
          steward.staging = fromInput "steward" steward-staging;
          steward.production = fromInput "steward" steward-production;
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [overlay];
        };

        hardenedServiceConfig = {
          DeviceAllow = [""];
          KeyringMode = "private";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = "yes";
          PrivateMounts = "yes";
          PrivateTmp = "yes";
          ProtectClock = true;
          ProtectControlGroups = "yes";
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          UMask = "0077";
        };

        mkDataServiceModule = script: {...}: {
          systemd.services.data.description = "Initialize data directory";
          systemd.services.data.enable = true;
          systemd.services.data.script = script;
          systemd.services.data.serviceConfig.Type = "oneshot";
          systemd.services.data.serviceConfig.UMask = "0077";
          systemd.services.data.wantedBy = ["multi-user.target"];
        };

        mkHost = {
          name,
          modules ? [],
        }:
          nixpkgs.lib.nixosSystem {
            inherit system;

            modules =
              [
                ./modules
                ({
                  config,
                  pkgs,
                  ...
                }: {
                  networking.firewall.allowedTCPPorts = [
                    80
                    443
                  ];

                  nix.settings.allowed-users = [
                    "@deploy"
                  ];
                  nix.settings.trusted-users = [
                    "@deploy"
                  ];
                  nixpkgs.overlays = [overlay];

                  security.acme.defaults.email = emails.ops;

                  users.groups.${name} = {};

                  users.users.${name} = {
                    group = name;
                    isSystemUser = true;
                  };
                })
              ]
              ++ modules;
          };

        mkBenefice = fqdn: oidc-client: env: modules: let
          oidc-secret = "/var/lib/benefice/oidc-secret";
        in
          mkHost {
            name = "benefice";
            modules =
              [
                (mkDataServiceModule ''
                  chmod 0700 /var/lib/benefice
                  chmod 0600 ${oidc-secret}

                  chown -R benefice:benefice /var/lib/benefice
                '')
                ({lib, ...}: let
                  benefice = pkgs.benefice.${env};
                  enarx = pkgs.enarx.${env};
                  conf = pkgs.writeText "conf.toml" ''
                    command = "${enarx}/bin/enarx"
                    oidc-client = "${oidc-client}"
                    oidc-secret = "${oidc-secret}"
                    oidc-issuer = "https://${oidc.issuer}"
                    url = "https://${fqdn}"
                  '';
                in {
                  environment.systemPackages = [
                    benefice
                    enarx
                  ];

                  networking.firewall.enable = lib.mkForce false;

                  services.nginx.virtualHosts.${fqdn} = {
                    enableACME = true;
                    forceSSL = true;
                    locations."/".proxyPass = "http://localhost:3000";
                  };

                  systemd.services.benefice.after = [
                    "network-online.target"
                  ];
                  systemd.services.benefice.description = "Benefice";
                  systemd.services.benefice.enable = true;
                  systemd.services.benefice.serviceConfig =
                    hardenedServiceConfig
                    // {
                      ExecStart = "${benefice}/bin/benefice @${conf}";
                      MemoryDenyWriteExecute = false;
                      Restart = "always";
                      User = "benefice";
                    };
                  systemd.services.benefice.wantedBy = [
                    "multi-user.target"
                  ];
                  systemd.services.benefice.wants = [
                    "network-online.target"
                  ];
                })
              ]
              ++ modules;
          };

        mkDrawbridge = fqdn: oidc-client: env: modules: let
          tls.ca = cert.${env}.attest;
        in
          mkHost {
            name = "drawbridge";
            modules =
              [
                (mkDataServiceModule ''
                  mkdir -p /var/lib/drawbridge/store
                  chmod 0700 /var/lib/drawbridge/store

                  chown -R drawbridge:drawbridge /var/lib/drawbridge
                '')
                ({
                  config,
                  pkgs,
                  ...
                }: let
                  drawbridge = pkgs.drawbridge.${env};
                  certs = config.security.acme.certs.${fqdn}.directory;
                  conf = pkgs.writeText "conf.toml" ''
                    ca = "${tls.ca}"
                    cert = "${certs}/cert.pem"
                    key = "${certs}/key.pem"
                    store = "/var/lib/drawbridge/store"
                    oidc-client = "${oidc-client}"
                    oidc-label = "${oidc.issuer}"
                    oidc-issuer = "https://${oidc.issuer}"
                  '';
                in {
                  environment.systemPackages = [
                    drawbridge
                  ];

                  services.nginx.virtualHosts.${fqdn} = {
                    enableACME = true;
                    forceSSL = true;
                    locations."/".proxyPass = "https://localhost:8080";
                    sslTrustedCertificate = tls.ca;
                  };

                  systemd.services.drawbridge.after = [
                    "data.service"
                    "network-online.target"
                  ];
                  systemd.services.drawbridge.description = "Drawbridge";
                  systemd.services.drawbridge.enable = true;
                  systemd.services.drawbridge.serviceConfig =
                    hardenedServiceConfig
                    // {
                      ExecStart = "${drawbridge}/bin/drawbridge @${conf}";
                      ReadWritePaths = [
                        "/var/lib/drawbridge"
                      ];
                      Restart = "always";
                      User = "drawbridge";
                    };
                  systemd.services.drawbridge.wantedBy = [
                    "multi-user.target"
                  ];
                  systemd.services.drawbridge.wants = [
                    "network-online.target"
                  ];

                  users.users.drawbridge.extraGroups = [
                    "nginx"
                  ];
                })
              ]
              ++ modules;
          };

        mkSteward = fqdn: env: modules: let
          tls.certificate = cert.${env}.attest;
          tls.key = "/var/lib/steward/ca.key";
        in
          mkHost {
            name = "steward";
            modules =
              [
                (mkDataServiceModule ''
                  chmod 0700 /var/lib/steward
                  chmod 0600 ${tls.key}

                  chown -R steward:steward /var/lib/steward
                '')
                ({pkgs, ...}: let
                  steward = pkgs.steward.${env};
                  conf = pkgs.writeText "conf.toml" ''
                    crt = "${tls.certificate}"
                    key = "${tls.key}"
                  '';
                in {
                  environment.systemPackages = [
                    steward
                  ];

                  services.nginx.virtualHosts.${fqdn} = {
                    enableACME = true;
                    forceSSL = true;
                    http2 = false;
                    locations."/".proxyPass = "http://localhost:3000";
                  };

                  systemd.services.steward.after = [
                    "data.service"
                    "network-online.target"
                  ];
                  systemd.services.steward.description = "Steward";
                  systemd.services.steward.enable = true;
                  systemd.services.steward.serviceConfig =
                    hardenedServiceConfig
                    // {
                      ExecStart = "${steward}/bin/steward @${conf}";
                      ReadWritePaths = [
                        "/var/lib/steward"
                      ];
                      Restart = "always";
                      User = "steward";
                    };
                  systemd.services.steward.wantedBy = [
                    "multi-user.target"
                  ];
                  systemd.services.steward.wants = [
                    "network-online.target"
                  ];
                })
              ]
              ++ modules;
          };
      in {
        sgx-equinix-demo =
          mkBenefice
          hosts.demo.equinix.sgx
          oidc.client.demo.equinix.sgx
          "staging"
          [
            (mkDataServiceModule ''
              chmod 0700 /var/lib/pccs
              chmod 0600 /var/lib/pccs/api-key

              chown -R root:pccs /var/lib/pccs
            '')
            ({...}: {
              imports = [
                ./hosts/sgx.equinix.demo.enarx.dev
              ];
              networking.hostName = "sgx-equinix-demo";
              systemd.services.benefice.environment.RUST_LOG = "info";
            })
          ];

        snp-equinix-demo =
          mkBenefice
          hosts.demo.equinix.snp
          oidc.client.demo.equinix.snp
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/snp.equinix.demo.enarx.dev
              ];
              networking.hostName = "snp-equinix-demo";
              systemd.services.benefice.environment.RUST_LOG = "info";
            })
          ];

        attest-staging =
          mkSteward
          hosts.staging.attest
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/attest.staging.profian.com
              ];
              networking.hostName = "attest-staging";
              systemd.services.steward.environment.RUST_LOG = "info";
            })
          ];

        attest-testing =
          mkSteward
          hosts.testing.attest
          "testing"
          [
            ({...}: {
              imports = [
                ./hosts/attest.testing.profian.com
              ];
              networking.hostName = "attest-testing";
              systemd.services.steward.environment.RUST_LOG = "debug";
            })
          ];

        attest =
          mkSteward
          hosts.attest
          "production"
          [
            ({...}: {
              imports = [
                ./hosts/attest.profian.com
              ];
              networking.hostName = "attest";
            })
          ];

        store-testing =
          mkDrawbridge
          hosts.testing.store
          oidc.client.testing.store
          "testing"
          [
            ({...}: {
              imports = [
                ./hosts/store.testing.profian.com
              ];
              networking.hostName = "store-testing";
              systemd.services.drawbridge.environment.RUST_LOG = "debug";
            })
          ];

        store-staging =
          mkDrawbridge
          hosts.staging.store
          oidc.client.staging.store
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/store.staging.profian.com
              ];
              networking.hostName = "store-staging";
              systemd.services.drawbridge.environment.RUST_LOG = "info";
            })
          ];

        store =
          mkDrawbridge
          hosts.store
          oidc.client.store
          "production"
          [
            ({...}: {
              imports = [
                ./hosts/store.profian.com
              ];
              networking.hostName = "store";
            })
          ];
      };

      deploy.nodes = let
        mkNode = hostname: name: {
          inherit hostname;
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${name};
          profiles.system.sshUser = sshUser;
          profiles.system.user = "root";
        };
      in {
        sgx-equinix-demo = mkNode hosts.demo.equinix.sgx "sgx-equinix-demo";
        snp-equinix-demo = mkNode hosts.demo.equinix.snp "snp-equinix-demo";

        attest = mkNode hosts.attest "attest";
        attest-staging = mkNode hosts.staging.attest "attest-staging";
        attest-testing = mkNode hosts.testing.attest "attest-testing";

        store = mkNode hosts.store "store";
        store-staging = mkNode hosts.staging.store "store-staging";
        store-testing = mkNode hosts.testing.store "store-testing";
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
        set -e

        for host in hosts/attest.*; do
            pushd "$host"
            ./generate.sh
            popd
        done
      '';

      provision = pkgs.writeShellScriptBin "provision" ''
        set -e

        for host in hosts/attest.*; do
            host=''${host#'hosts/'}
            ${pkgs.openssh}/bin/ssh "root@$host" mkdir -p /var/lib/steward
            ${pkgs.openssh}/bin/scp "hosts/$host/ca.key" "root@$host:/var/lib/steward/ca.key"
        done

        for host in hosts/*.demo.enarx.dev; do
            host=''${host#'hosts/'}
            ${pkgs.openssh}/bin/ssh "root@$host" mkdir -p /var/lib/benefice
            ${pkgs.openssh}/bin/scp "hosts/$host/oidc-secret" "root@$host:/var/lib/benefice/oidc-secret"
        done
      '';
    in {
      formatter = pkgs.alejandra;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.nixUnstable
          pkgs.openssl

          deploy-rs.packages.${system}.default

          bootstrap
          provision
        ];
      };
    });
}
