{
  description = "Profian Inc Network Infrastructure";

  inputs.benefice-staging.flake = false;
  inputs.benefice-staging.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc6/benefice-x86_64-unknown-linux-musl";
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

    cert.staging.attest = ./hosts/attest.staging.profian.com/ca.crt;
    cert.testing.attest = ./hosts/attest.testing.profian.com/ca.crt;
    cert.production.attest = ./hosts/attest.profian.com/ca.crt;

    oidc.client.demo.equinix.sgx = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
    oidc.client.demo.equinix.snp = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";

    oidc.client.testing.benefice = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
    oidc.client.testing.store = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";

    oidc.client.staging.store = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";

    oidc.client.production.store = "2vq9XnQgcGZ9JCxsGERuGURYIld3mcIh";
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

          drawbridge.testing = drawbridge-testing.packages.x86_64-linux.drawbridge-debug-x86_64-unknown-linux-musl;
          drawbridge.staging = fromInput "drawbridge" drawbridge-staging;
          drawbridge.production = fromInput "drawbridge" drawbridge-production;

          enarx = fromInput "enarx" enarx;

          steward.testing = steward-testing.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
          steward.staging = fromInput "steward" steward-staging;
          steward.production = fromInput "steward" steward-production;
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [overlay];
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

        # TODO: remove this function
        mkBenefice = oidc-client: env: modules:
          mkHost {
            name = "benefice";
            modules =
              [
                (mkDataServiceModule ''
                  chmod 0700 /var/lib/benefice
                  chmod 0600 /var/lib/benefice/oidc-secret

                  chown -R benefice:benefice /var/lib/benefice
                '')
                ({lib, ...}: {
                  networking.firewall.enable = lib.mkForce false;

                  services.benefice.enable = true;
                  services.benefice.oidc.client = oidc-client;
                  services.benefice.oidc.secret = "/var/lib/benefice/oidc-secret";
                  services.benefice.package = pkgs.benefice.${env};
                })
              ]
              ++ modules;
          };

        mkSteward = env: modules: let
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
                ({
                  config,
                  pkgs,
                  ...
                }: let
                  steward = pkgs.steward.${env};
                  conf = pkgs.writeText "conf.toml" ''
                    crt = "${tls.certificate}"
                    key = "${tls.key}"
                  '';
                in {
                  environment.systemPackages = [
                    steward
                  ];

                  services.nginx.virtualHosts.${config.networking.fqdn} = {
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
                  systemd.services.steward.serviceConfig.ExecStart = "${steward}/bin/steward @${conf}";
                  systemd.services.steward.serviceConfig.KeyringMode = "private";
                  systemd.services.steward.serviceConfig.LockPersonality = true;
                  systemd.services.steward.serviceConfig.MemoryDenyWriteExecute = true;
                  systemd.services.steward.serviceConfig.NoNewPrivileges = true;
                  systemd.services.steward.serviceConfig.PrivateMounts = "yes";
                  systemd.services.steward.serviceConfig.PrivateTmp = "yes";
                  systemd.services.steward.serviceConfig.ProtectClock = true;
                  systemd.services.steward.serviceConfig.ProtectControlGroups = "yes";
                  systemd.services.steward.serviceConfig.ProtectHome = true;
                  systemd.services.steward.serviceConfig.ProtectHostname = true;
                  systemd.services.steward.serviceConfig.ProtectKernelLogs = true;
                  systemd.services.steward.serviceConfig.ProtectKernelModules = true;
                  systemd.services.steward.serviceConfig.ProtectKernelTunables = true;
                  systemd.services.steward.serviceConfig.ProtectProc = "invisible";
                  systemd.services.steward.serviceConfig.ProtectSystem = "strict";
                  systemd.services.steward.serviceConfig.ReadWritePaths = "/var/lib/steward";
                  systemd.services.steward.serviceConfig.RemoveIPC = true;
                  systemd.services.steward.serviceConfig.Restart = "always";
                  systemd.services.steward.serviceConfig.RestrictNamespaces = true;
                  systemd.services.steward.serviceConfig.RestrictRealtime = true;
                  systemd.services.steward.serviceConfig.RestrictSUIDSGID = true;
                  systemd.services.steward.serviceConfig.SystemCallArchitectures = "native";
                  systemd.services.steward.serviceConfig.UMask = "0077";
                  systemd.services.steward.serviceConfig.User = "steward";
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

              services.benefice.log.level = "info";
            })
          ];

        snp-equinix-demo =
          mkBenefice
          oidc.client.demo.equinix.snp
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/snp.equinix.demo.enarx.dev
              ];

              services.benefice.log.level = "info";
            })
          ];

        attest-staging =
          mkSteward
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/attest.staging.profian.com
              ];
              systemd.services.steward.environment.RUST_LOG = "info";
            })
          ];

        attest-testing =
          mkSteward
          "testing"
          [
            ({...}: {
              imports = [
                ./hosts/attest.testing.profian.com
              ];
              systemd.services.steward.environment.RUST_LOG = "debug";
            })
          ];

        attest =
          mkSteward
          "production"
          [
            ({...}: {
              imports = [
                ./hosts/attest.profian.com
              ];
            })
          ];

        store-testing = mkHost {
          name = "drawbridge";
          modules = [
            ({pkgs, ...}: {
              imports = [
                ./hosts/store.testing.profian.com
              ];

              services.drawbridge.enable = true;
              services.drawbridge.log.level = "debug";
              services.drawbridge.oidc.client = oidc.client.testing.store;
              services.drawbridge.package = pkgs.drawbridge.testing;
              services.drawbridge.tls.ca = cert.testing.attest;
            })
          ];
        };

        store-staging = mkHost {
          name = "drawbridge";
          modules = [
            ({pkgs, ...}: {
              imports = [
                ./hosts/store.staging.profian.com
              ];

              services.drawbridge.enable = true;
              services.drawbridge.log.level = "info";
              services.drawbridge.oidc.client = oidc.client.staging.store;
              services.drawbridge.package = pkgs.drawbridge.staging;
              services.drawbridge.tls.ca = cert.staging.attest;
            })
          ];
        };

        store = mkHost {
          name = "drawbridge";
          modules = [
            ({pkgs, ...}: {
              imports = [
                ./hosts/store.profian.com
              ];

              services.drawbridge.enable = true;
              services.drawbridge.oidc.client = oidc.client.production.store;
              services.drawbridge.package = pkgs.drawbridge.production;
              services.drawbridge.tls.ca = cert.production.attest;
            })
          ];
        };
      };

      deploy.nodes = let
        mkNode = name: {
          hostname = self.nixosConfigurations.${name}.config.networking.fqdn;
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${name};
          profiles.system.sshUser = sshUser;
          profiles.system.user = "root";
        };
      in {
        sgx-equinix-demo = mkNode "sgx-equinix-demo";
        snp-equinix-demo = mkNode "snp-equinix-demo";

        attest = mkNode "attest";
        attest-staging = mkNode "attest-staging";
        attest-testing = mkNode "attest-testing";

        store = mkNode "store";
        store-staging = mkNode "store-staging";
        store-testing = mkNode "store-testing";
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
