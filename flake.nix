{
  description = "Profian Inc Staging Network";

  inputs.benefice-release.flake = false;
  inputs.benefice-release.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc1/benefice-x86_64-unknown-linux-musl";
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

    # TODO: Uncomment once DNS assignment is made
    #hosts.staging.benefice = "sgx.equinix.demo.enarx.dev";
    hosts.staging.benefice = "147.28.146.139";
    hosts.staging.drawbridge = "drawbridge.staging.profian.com";
    hosts.staging.steward = "steward.staging.profian.com";

    hosts.testing.drawbridge = "drawbridge.testing.profian.com";
    hosts.testing.steward = "steward.testing.profian.com";

    oidc.issuer = "auth.profian.com";

    oidc.client.staging.benefice = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
    oidc.client.staging.drawbridge = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";

    oidc.client.testing.benefice = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";
    oidc.client.testing.drawbridge = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";

    cert.staging.drawbridge = ./hosts/drawbridge.staging.profian.com/server.crt;
    cert.staging.steward = ./hosts/steward.staging.profian.com/ca.crt;

    cert.testing.drawbridge = ./hosts/drawbridge.testing.profian.com/server.crt;
    cert.testing.steward = ./hosts/steward.testing.profian.com/ca.crt;

    keys.ci = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJagVarhqfhuneWIHMknGBORRB7cuUzqcM2qJDdHxdus";
    keys.nathaniel = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDY5lUiLQkHiSAcvIK0RNzZfGQqyt/jjmnq/vUvLLjaEzwFEHemzaOEOACQT/SC0SP/RyN/taQBkcyGGaJ9lf5Q=";
    keys.roman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX";
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
          benefice.testing = benefice-tip.packages.x86_64-linux.default;
          benefice.staging = fromInput "benefice" benefice-release;

          drawbridge.testing = drawbridge-tip.packages.x86_64-linux.default;
          drawbridge.staging = fromInput "drawbridge" drawbridge-release;

          enarx.staging = fromInput "enarx" enarx-release;

          steward.testing = steward-tip.packages.x86_64-linux.default;
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
          Restart = "always";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          Type = "simple";
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

                  security.sudo.extraRules = let
                    # systemPath is the path where the system being activated is uploaded by `deploy`.
                    systemPath = "/nix/store/*-activatable-nixos-system-${config.networking.hostName}-*";

                    nopasswd = command: {
                      inherit command;
                      options = ["NOPASSWD" "SETENV"];
                    };
                  in [
                    {
                      groups = ["deploy"];
                      runAs = "root";
                      commands = [
                        (nopasswd "${systemPath}/activate-rs activate *")
                        (nopasswd "${systemPath}/activate-rs wait *")
                        (nopasswd "/run/current-system/sw/bin/rm /tmp/deploy-rs*")
                      ];
                    }
                    {
                      groups = ["ops"];
                      runAs = "root";
                      commands = [
                        (nopasswd "/run/current-system/sw/bin/systemctl reboot")

                        (nopasswd "/run/current-system/sw/bin/systemctl restart ${name}.service")
                        (nopasswd "/run/current-system/sw/bin/systemctl restart nginx.service")

                        (nopasswd "/run/current-system/sw/bin/systemctl start ${name}.service")
                        (nopasswd "/run/current-system/sw/bin/systemctl start nginx.service")

                        (nopasswd "/run/current-system/sw/bin/systemctl stop ${name}.service")
                        (nopasswd "/run/current-system/sw/bin/systemctl stop nginx.service")
                      ];
                    }
                  ];

                  users.groups.${name} = {};
                  users.groups.deploy = {};
                  users.groups.ops = {};

                  users.users.${name} = {
                    group = name;
                    isSystemUser = true;
                  };

                  users.users.deploy.isSystemUser = true;
                  users.users.deploy.group = "deploy";
                  users.users.deploy.openssh.authorizedKeys.keys = with keys; [
                    ci
                    nathaniel
                    roman
                  ];
                  users.users.deploy.shell = pkgs.bashInteractive;

                  users.users.ops.isNormalUser = true;
                  users.users.ops.group = "ops";
                  users.users.ops.extraGroups = [
                    "deploy"
                    "wheel"
                  ];
                  users.users.ops.openssh.authorizedKeys.keys = with keys; [
                    nathaniel
                    roman
                  ];
                  users.users.ops.shell = pkgs.bashInteractive;

                  users.users.root.openssh.authorizedKeys.keys = with keys; [
                    nathaniel
                    roman
                  ];
                })
              ]
              ++ modules;
          };

        mkBenefice = env: modules: let
          fqdn = hosts.${env}.benefice;
        in
          mkHost {
            name = "benefice";
            modules =
              [
                ({lib, ...}: let
                  benefice = pkgs.benefice.${env};
                  enarx = pkgs.enarx.${env};
                  conf = pkgs.writeText "conf.toml" ''
                    oidc-client = "${oidc.client.${env}.benefice}"
                    oidc-issuer = "https://${oidc.issuer}"
                  '';
                in {
                  environment.systemPackages = [
                    benefice
                    enarx
                  ];

                  services.nginx.virtualHosts.${fqdn} = {
                    # TODO: Enable TLS once DNS assignment is done
                    #enableACME = true;
                    #forceSSL = true;
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

        mkDrawbridge = env: modules: let
          fqdn = hosts.${env}.drawbridge;
          tls.ca = cert.${env}.steward;
          tls.certificate = cert.${env}.drawbridge;
          tls.key = "/var/lib/drawbridge/server.key";
        in
          mkHost {
            name = "drawbridge";
            modules =
              [
                (mkDataServiceModule ''
                  chmod 0750 /var/lib/drawbridge
                  chmod 0640 ${tls.key}

                  mkdir -p /var/lib/drawbridge/store
                  chmod 0700 /var/lib/drawbridge/store

                  chown -R drawbridge:drawbridge /var/lib/drawbridge
                '')
                ({pkgs, ...}: let
                  drawbridge = pkgs.drawbridge.${env};
                  conf = pkgs.writeText "conf.toml" ''
                    ca = "${tls.ca}"
                    cert = "${tls.certificate}"
                    key = "${tls.key}"
                    store = "/var/lib/drawbridge/store"
                    oidc-client = "${oidc.client.${env}.drawbridge}"
                    oidc-label = "${oidc.issuer}"
                    oidc-issuer = "https://${oidc.issuer}"
                  '';
                in {
                  environment.systemPackages = [
                    drawbridge
                  ];

                  services.nginx.virtualHosts.${fqdn} = {
                    forceSSL = true;
                    locations."/".proxyPass = "https://localhost:8080";
                    sslCertificate = tls.certificate;
                    sslCertificateKey = tls.key;
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
                      User = "drawbridge";
                    };
                  systemd.services.drawbridge.wantedBy = [
                    "multi-user.target"
                  ];
                  systemd.services.drawbridge.wants = [
                    "network-online.target"
                  ];

                  users.users.nginx.extraGroups = [
                    "drawbridge"
                  ];
                })
              ]
              ++ modules;
          };

        mkSteward = env: modules: let
          fqdn = hosts.${env}.steward;
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
        benefice-staging = mkBenefice "staging" [
          ({...}: {
            imports = [
              ./hosts/sgx.equinix.demo.enarx.dev
            ];
            networking.hostName = "benefice-staging";
            systemd.services.benefice.environment.RUST_LOG = "info";
          })
        ];

        drawbridge-staging = mkDrawbridge "staging" [
          ({...}: {
            imports = [
              ./hosts/drawbridge.staging.profian.com
            ];
            networking.hostName = "drawbridge-staging";
            systemd.services.drawbridge.environment.RUST_LOG = "info";
          })
        ];

        drawbridge-testing = mkDrawbridge "testing" [
          ({...}: {
            imports = [
              ./hosts/drawbridge.testing.profian.com
            ];
            networking.hostName = "drawbridge-testing";
            systemd.services.drawbridge.environment.RUST_LOG = "debug";
          })
        ];

        steward-staging = mkSteward "staging" [
          ({...}: {
            imports = [
              ./hosts/steward.staging.profian.com
            ];
            networking.hostName = "steward-staging";
            systemd.services.steward.environment.RUST_LOG = "info";
          })
        ];

        steward-testing = mkSteward "testing" [
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
        mkNode = name: env: {
          hostname = hosts.${env}.${name};
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."${name}-${env}";
          profiles.system.sshUser = sshUser;
          profiles.system.user = "root";
        };
      in {
        benefice-staging = mkNode "benefice" "staging";

        drawbridge-staging = mkNode "drawbridge" "staging";
        drawbridge-testing = mkNode "drawbridge" "testing";

        steward-staging = mkNode "steward" "staging";
        steward-testing = mkNode "steward" "testing";
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

        for host in hosts/drawbridge.*; do
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

        for host in hosts/drawbridge.*; do
            host=''${host#'hosts/'}
            ${pkgs.openssh}/bin/ssh "root@$host" mkdir -p /var/lib/drawbridge
            ${pkgs.openssh}/bin/scp "hosts/$host/server.key" "root@$host:/var/lib/drawbridge/server.key"
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
