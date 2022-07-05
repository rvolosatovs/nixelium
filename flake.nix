{
  description = "Profian Inc Staging Network";

  inputs.benefice-release.flake = false;
  inputs.benefice-release.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc2/benefice-x86_64-unknown-linux-musl";
  inputs.benefice-tip.inputs.cargo2nix.follows = "cargo2nix";
  inputs.benefice-tip.inputs.flake-compat.follows = "flake-compat";
  inputs.benefice-tip.inputs.flake-utils.follows = "flake-utils";
  inputs.benefice-tip.inputs.nixpkgs.follows = "nixpkgs";
  inputs.benefice-tip.inputs.rust-overlay.follows = "rust-overlay";
  inputs.benefice-tip.url = github:profianinc/benefice;
  inputs.cargo2nix.inputs.flake-compat.follows = "flake-compat";
  inputs.cargo2nix.inputs.flake-utils.follows = "flake-utils";
  inputs.cargo2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.cargo2nix.inputs.rust-overlay.follows = "rust-overlay";
  inputs.cargo2nix.url = github:cargo2nix/cargo2nix;
  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge-release.flake = false;
  inputs.drawbridge-release.url = "https://github.com/profianinc/drawbridge/releases/download/v0.1.0-rc3/drawbridge-x86_64-unknown-linux-musl";
  inputs.drawbridge-tip.inputs.cargo2nix.follows = "cargo2nix";
  inputs.drawbridge-tip.inputs.flake-compat.follows = "flake-compat";
  inputs.drawbridge-tip.inputs.flake-utils.follows = "flake-utils";
  inputs.drawbridge-tip.inputs.nixpkgs.follows = "nixpkgs";
  inputs.drawbridge-tip.inputs.rust-overlay.follows = "rust-overlay";
  inputs.drawbridge-tip.url = github:profianinc/drawbridge;
  inputs.enarx-release.flake = false;
  inputs.enarx-release.url = "https://github.com/enarx/enarx/releases/download/v0.5.1/enarx-x86_64-unknown-linux-musl";
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rust-overlay.url = github:oxalica/rust-overlay;
  inputs.steward-release.flake = false;
  inputs.steward-release.url = "https://github.com/profianinc/steward/releases/download/v0.1.0-rc1/steward-x86_64-unknown-linux-musl";
  inputs.steward-tip.inputs.flake-compat.follows = "flake-compat";
  inputs.steward-tip.inputs.flake-utils.follows = "flake-utils";
  inputs.steward-tip.inputs.nixpkgs.follows = "nixpkgs";
  inputs.steward-tip.url = github:profianinc/steward;

  outputs = {
    self,
    benefice-release,
    benefice-tip,
    cargo2nix,
    deploy-rs,
    drawbridge-release,
    drawbridge-tip,
    enarx-release,
    flake-compat,
    flake-utils,
    nixpkgs,
    rust-overlay,
    steward-release,
    steward-tip,
  }: let
    sshUser = "deploy";

    emails.ops = "roman@profian.com"; # TODO: How about ops@profian.com ?

    hosts.demo.equinix.sgx = "sgx.equinix.demo.enarx.dev";
    hosts.demo.equinix.snp = "snp.equinix.demo.enarx.dev";

    hosts.staging.drawbridge = "drawbridge.staging.profian.com";
    hosts.staging.steward = "steward.staging.profian.com";

    hosts.testing.drawbridge = "drawbridge.testing.profian.com";
    hosts.testing.steward = "steward.testing.profian.com";

    oidc.issuer = "auth.profian.com";

    oidc.client.demo.equinix.sgx = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
    oidc.client.demo.equinix.snp = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";

    oidc.client.staging.drawbridge = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";

    oidc.client.testing.benefice = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
    oidc.client.testing.drawbridge = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";

    cert.staging.drawbridge = ./hosts/drawbridge.staging.profian.com/server.crt;
    cert.staging.steward = ./hosts/steward.staging.profian.com/ca.crt;

    cert.testing.drawbridge = ./hosts/drawbridge.testing.profian.com/server.crt;
    cert.testing.steward = ./hosts/steward.testing.profian.com/ca.crt;
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
          benefice.testing = benefice-tip.packages.x86_64-linux.benefice-debug-x86_64-unknown-linux-musl;
          benefice.staging = fromInput "benefice" benefice-release;

          drawbridge.testing = drawbridge-tip.packages.x86_64-linux.drawbridge-debug-x86_64-unknown-linux-musl;
          drawbridge.staging = fromInput "drawbridge" drawbridge-release;

          enarx.staging = fromInput "enarx" enarx-release;

          steward.testing = steward-tip.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
          steward.staging = fromInput "steward" steward-release;
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

        mkBenefice = fqdn: oidc-client: env: modules:
          mkHost {
            name = "benefice";
            modules =
              [
                ({lib, ...}: let
                  benefice = pkgs.benefice.${env};
                  enarx = pkgs.enarx.${env};
                  conf = pkgs.writeText "conf.toml" ''
                    command = "${enarx}/bin/enarx"
                    oidc-client = "${oidc-client}"
                    oidc-issuer = "https://${oidc.issuer}"
                  '';
                in {
                  environment.systemPackages = [
                    benefice
                    enarx
                  ];

                  networking.firewall.enable = lib.mkForce false;

                  services.nginx.virtualHosts.${fqdn} = {
                    addSSL = true;
                    enableACME = true;
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
          tls.ca = cert.${env}.steward;
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
          tls.certificate = cert.${env}.steward;
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

        drawbridge-staging =
          mkDrawbridge
          hosts.staging.drawbridge
          oidc.client.staging.drawbridge
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/drawbridge.staging.profian.com
              ];
              networking.hostName = "drawbridge-staging";
              systemd.services.drawbridge.environment.RUST_LOG = "info";
            })
          ];

        drawbridge-testing =
          mkDrawbridge
          hosts.testing.drawbridge
          oidc.client.testing.drawbridge
          "testing"
          [
            ({...}: {
              imports = [
                ./hosts/drawbridge.testing.profian.com
              ];
              networking.hostName = "drawbridge-testing";
              systemd.services.drawbridge.environment.RUST_LOG = "debug";
            })
          ];

        steward-staging =
          mkSteward
          hosts.staging.steward
          "staging"
          [
            ({...}: {
              imports = [
                ./hosts/steward.staging.profian.com
              ];
              networking.hostName = "steward-staging";
              systemd.services.steward.environment.RUST_LOG = "info";
            })
          ];

        steward-testing =
          mkSteward
          hosts.testing.steward
          "testing"
          [
            ({...}: {
              imports = [
                ./hosts/steward.testing.profian.com
              ];
              networking.hostName = "steward-testing";
              systemd.services.steward.environment.RUST_LOG = "debug";
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

        drawbridge-staging = mkNode hosts.staging.drawbridge "drawbridge-staging";
        drawbridge-testing = mkNode hosts.testing.drawbridge "drawbridge-testing";

        steward-staging = mkNode hosts.staging.steward "steward-staging";
        steward-testing = mkNode hosts.testing.steward "steward-testing";
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
        set -e

        for host in hosts/steward.*; do
            pushd "$host"
            ./generate.sh
            popd
        done
      '';

      provision = pkgs.writeShellScriptBin "provision" ''
        set -e

        for host in hosts/steward.*; do
            host=''${host#'hosts/'}
            ${pkgs.openssh}/bin/ssh "root@$host" mkdir -p /var/lib/steward
            ${pkgs.openssh}/bin/scp "hosts/$host/ca.key" "root@$host:/var/lib/steward/ca.key"
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
