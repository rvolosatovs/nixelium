{
  description = "Profian Inc Staging Network";

  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge-release.flake = false;
  inputs.drawbridge-release.url = "https://github.com/profianinc/drawbridge/releases/download/v0.1.0-rc3/drawbridge-x86_64-unknown-linux-musl";
  inputs.drawbridge-tip.inputs.flake-compat.follows = "flake-compat";
  inputs.drawbridge-tip.inputs.flake-utils.follows = "flake-utils";
  inputs.drawbridge-tip.inputs.nixpkgs.follows = "nixpkgs";
  inputs.drawbridge-tip.url = github:profianinc/drawbridge;
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
  inputs.steward-release.flake = false;
  inputs.steward-release.url = "https://github.com/profianinc/steward/releases/download/v0.1.0-rc1/steward-x86_64-unknown-linux-musl";
  inputs.steward-tip.inputs.flake-compat.follows = "flake-compat";
  inputs.steward-tip.inputs.flake-utils.follows = "flake-utils";
  inputs.steward-tip.inputs.nixpkgs.follows = "nixpkgs";
  inputs.steward-tip.url = github:profianinc/steward;

  outputs = {
    self,
    deploy-rs,
    drawbridge-release,
    drawbridge-tip,
    flake-compat,
    flake-utils,
    nixpkgs,
    steward-release,
    steward-tip,
  }: let
    sshUser = "deploy";

    emails.ops = "roman@profian.com"; # TODO: How about ops@profian.com ?

    hosts.staging.benefice = "benefice.staging.profian.com";
    hosts.staging.drawbridge = "drawbridge.staging.profian.com";
    hosts.staging.steward = "steward.staging.profian.com";

    hosts.testing.benefice = "benefice.testing.profian.com";
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

    keys.roman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX";
  in
    {
      nixosConfigurations = let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: let
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
              drawbridge.testing = drawbridge-tip.packages.x86_64-linux.default;
              drawbridge.staging = fromInput "drawbridge" drawbridge-release;

              steward.testing = steward-tip.packages.x86_64-linux.default;
              steward.staging = fromInput "steward" steward-release;
            })
          ];
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
          env,
          modules ? [],
        }:
          nixpkgs.lib.nixosSystem {
            inherit system;

            modules =
              [
                ({config, ...}: {
                  imports = [
                    "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
                  ];

                  documentation.nixos.enable = false;

                  ec2.hvm = true;

                  environment.shells = [
                    pkgs.bashInteractive
                  ];

                  environment.systemPackages = [
                    pkgs.curl
                    pkgs.emacs
                    pkgs.nano
                    pkgs.openssl
                  ];

                  networking.firewall.enable = true;
                  networking.firewall.allowedTCPPorts = [
                    80
                    443
                  ];

                  networking.hostName = "${name}-${env}";

                  nix.binaryCaches = [
                    "https://cache.nixos.org"
                    "https://enarx.cachix.org"
                  ];
                  nix.binaryCachePublicKeys = [
                    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                    "enarx.cachix.org-1:Izq345bPMThAWUW830X3uoGTTBjXW7ltGlfTBErgm4w="
                  ];
                  nix.extraOptions = "experimental-features = nix-command flakes";
                  nix.gc.automatic = true;
                  nix.optimise.automatic = true;
                  nix.requireSignedBinaryCaches = true;
                  nix.settings.auto-optimise-store = true;
                  nix.settings.allowed-users = [
                    "@deploy"
                    "@wheel"
                  ];
                  nix.settings.trusted-users = [
                    "@wheel"
                    "root"
                  ];

                  nixpkgs.pkgs = pkgs;

                  programs.bash.enableCompletion = true;

                  programs.neovim.enable = true;
                  programs.neovim.defaultEditor = true;
                  programs.neovim.viAlias = true;
                  programs.neovim.vimAlias = true;

                  security.acme.acceptTerms = true;
                  security.acme.defaults.email = emails.ops;

                  security.sudo.enable = true;
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
                        (nopasswd "/run/current-system/sw/bin/systemctl restart ${name}.service")
                        (nopasswd "/run/current-system/sw/bin/systemctl restart nginx.service")

                        (nopasswd "/run/current-system/sw/bin/systemctl start ${name}.service")
                        (nopasswd "/run/current-system/sw/bin/systemctl start nginx.service")

                        (nopasswd "/run/current-system/sw/bin/systemctl stop ${name}.service")
                        (nopasswd "/run/current-system/sw/bin/systemctl stop nginx.service")
                      ];
                    }
                  ];

                  services.nginx.enable = true;

                  services.openssh.enable = true;
                  services.openssh.passwordAuthentication = false;
                  services.openssh.startWhenNeeded = true;

                  system.stateVersion = "22.05";

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
                    roman
                  ];
                  users.users.ops.shell = pkgs.bashInteractive;

                  users.users.root.openssh.authorizedKeys.keys = with keys; [
                    roman
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

          bin = pkgs.drawbridge.${env};
          conf = pkgs.writeText "conf.toml" ''
            ca = "${tls.ca}"
            cert = "${tls.certificate}"
            key = "${tls.key}"
            store = "/var/lib/drawbridge/store"
            oidc-client = "${oidc.client.${env}.drawbridge}"
            oidc-label = "${oidc.issuer}"
            oidc-issuer = "https://${oidc.issuer}"
          '';
        in
          mkHost {
            inherit env;

            name = "drawbridge";
            modules = [
              (mkDataServiceModule ''
                chmod 0750 /var/lib/drawbridge
                chmod 0640 ${tls.key}

                mkdir -p /var/lib/drawbridge/store
                chmod 0700 /var/lib/drawbridge/store

                chown -R drawbridge:drawbridge /var/lib/drawbridge
              '')
              ({...}: {
                environment.systemPackages = [
                  bin
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
                    ExecStart = "${bin}/bin/drawbridge @${conf}";
                    ReadWritePaths = [
                      "/var/lib/drawbridge"
                    ];
                    User = "drawbridge";
                  };
                systemd.services.drawbridge.wantedBy = ["multi-user.target"];
                systemd.services.drawbridge.wants = ["network-online.target"];

                users.users.nginx.extraGroups = ["drawbridge"];
              })
            ];
          };

        mkSteward = env: modules: let
          fqdn = hosts.${env}.steward;
          tls.certificate = cert.${env}.steward;
          tls.key = "/var/lib/steward/ca.key";

          bin = pkgs.steward.${env};
          conf = pkgs.writeText "conf.toml" ''
            crt = "${tls.certificate}"
            key = "${tls.key}"
          '';
        in
          mkHost {
            inherit env;

            name = "steward";
            modules = [
              (mkDataServiceModule ''
                chmod 0700 /var/lib/steward
                chmod 0600 ${tls.key}

                chown -R steward:steward /var/lib/steward
              '')
              ({...}: {
                environment.systemPackages = [
                  bin
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
                    ExecStart = "${bin}/bin/steward @${conf}";
                    ReadWritePaths = [
                      "/var/lib/steward"
                    ];
                    User = "steward";
                  };
                systemd.services.steward.wantedBy = ["multi-user.target"];
                systemd.services.steward.wants = ["network-online.target"];
              })
            ];
          };
      in {
        drawbridge-staging = mkDrawbridge "staging" [
          ({...}: {
            systemd.services.drawbridge.environment.RUST_LOG = "info";
          })
        ];

        drawbridge-testing = mkDrawbridge "testing" [
          ({...}: {
            systemd.services.drawbridge.environment.RUST_LOG = "debug";
          })
        ];

        steward-staging = mkSteward "staging" [
          ({...}: {
            systemd.services.steward.environment.RUST_LOG = "info";
          })
        ];

        steward-testing = mkSteward "testing" [
          ({...}: {
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
