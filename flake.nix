{
  description = "Profian Inc Network Infrastructure";

  inputs.benefice-staging.flake = false;
  inputs.benefice-staging.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc6/benefice-x86_64-unknown-linux-musl";
  inputs.benefice-testing.url = github:profianinc/benefice;
  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge-production.flake = false;
  inputs.drawbridge-production.url = "https://github.com/profianinc/drawbridge/releases/download/v0.2.0/drawbridge-x86_64-unknown-linux-musl";
  inputs.drawbridge-staging.flake = false;
  inputs.drawbridge-staging.url = "https://github.com/profianinc/drawbridge/releases/download/v0.2.0/drawbridge-x86_64-unknown-linux-musl";
  inputs.drawbridge-testing.url = github:profianinc/drawbridge;
  inputs.enarx.flake = false;
  # TODO: Use upstream release
  inputs.enarx.url = "https://github.com/rvolosatovs/enarx/releases/download/v0.6.1-rc1/enarx-x86_64-unknown-linux-musl";
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-generators.url = github:nix-community/nixos-generators;
  inputs.nixpkgs.url = github:profianinc/nixpkgs;
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.steward-production.flake = false;
  inputs.steward-production.url = "https://github.com/profianinc/steward/releases/download/v0.1.0/steward-x86_64-unknown-linux-musl";
  inputs.steward-staging.flake = false;
  inputs.steward-staging.url = "https://github.com/profianinc/steward/releases/download/v0.1.0/steward-x86_64-unknown-linux-musl";
  inputs.steward-testing.url = github:profianinc/steward;

  outputs = {
    self,
    benefice-staging,
    benefice-testing,
    deploy-rs,
    drawbridge-production,
    drawbridge-staging,
    drawbridge-testing,
    enarx,
    flake-compat,
    flake-utils,
    nixos-generators,
    nixpkgs,
    sops-nix,
    steward-production,
    steward-staging,
    steward-testing,
  }: let
    sshUser = "deploy";

    emails.ops = "roman@profian.com"; # TODO: How about ops@profian.com ?

    oidc.client.demo.equinix.sgx = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
    oidc.client.demo.equinix.snp = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";

    oidc.client.testing.benefice = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
    oidc.client.testing.store = "zFrR7MKMakS4OpEflR0kNw3ceoP7sr3s";

    oidc.client.staging.store = "9SVWiB3sQQdzKqpZmMNvsb9rzd8Ha21F";

    oidc.client.production.store = "2vq9XnQgcGZ9JCxsGERuGURYIld3mcIh";

    serviceOverlay = self: super: let
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

    mkHost = system: modules:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            ./modules
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
              nixpkgs.overlays = [serviceOverlay];

              security.acme.defaults.email = emails.ops;
            })
          ]
          ++ modules;
      };

    mkService = base: system: modules: mkHost system (base ++ modules);

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

        sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        sops.secrets.oidc-secret.format = "binary";
        sops.secrets.oidc-secret.mode = "0000";
        sops.secrets.oidc-secret.restartUnits = ["benefice.service"];

        systemd.services.benefice.serviceConfig.ExecStartPre = "+${exposeKey pkgs "benefice" config.sops.secrets.oidc-secret.path}";
        systemd.services.benefice.serviceConfig.ExecStop = "+${hideKey pkgs config.users.users.root.name config.sops.secrets.oidc-secret.path}";
        systemd.services.benefice.serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
      })
    ];

    mkDrawbridge = mkService [
      {
        services.drawbridge.enable = true;
      }
    ];

    mkSteward = mkService [
      sops-nix.nixosModules.sops
      ({
        config,
        pkgs,
        ...
      }: {
        services.steward.enable = true;
        services.steward.keyFile = config.sops.secrets.key.path;

        sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        sops.secrets.key.format = "binary";
        sops.secrets.key.mode = "0000";
        sops.secrets.key.restartUnits = ["steward.service"];

        systemd.services.steward.serviceConfig.ExecStartPre = "+${exposeKey pkgs "steward" config.sops.secrets.key.path}";
        systemd.services.steward.serviceConfig.ExecStop = "+${hideKey pkgs config.users.users.root.name config.sops.secrets.key.path}";
        systemd.services.steward.serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
      })
    ];

    mkEnarxImage = pkgs: format: modules:
      nixos-generators.nixosGenerate {
        inherit format pkgs;
        modules =
          [
            ./modules/common.nix
            ({pkgs, ...}: {
              networking.firewall.allowedTCPPorts = [
                80
                443
              ];

              nixpkgs.overlays = [serviceOverlay];
              services.enarx.enable = true;
            })
          ]
          ++ modules;
      };

    mkEnarxSevImage = pkgs: format: modules:
      mkEnarxImage pkgs format ([
          {
            boot.kernelModules = [
              "kvm-amd"
            ];
            boot.kernelPackages = pkgs.linuxPackages_enarx;

            hardware.cpu.amd.sev.enable = true;
            hardware.cpu.amd.sev.mode = "0777";

            hardware.cpu.amd.updateMicrocode = true;

            services.enarx.backend = "sev";
          }
        ]
        ++ modules);

    hostKey = pkgs: let
      grep = "${pkgs.gnugrep}/bin/grep";
      ssh-keyscan = "${pkgs.openssh}/bin/ssh-keyscan";
      ssh-to-age = "${pkgs.ssh-to-age}/bin/ssh-to-age";
    in
      pkgs.writeShellScriptBin "host-key" ''
        set -e

        ${ssh-keyscan} "''${1}" 2> /dev/null | ${grep} 'ssh-ed25519' | ${ssh-to-age}
      '';

    bootstrapCA = pkgs: let
      key = ''"ca/''${1}/ca.key"'';
      crt = ''"ca/''${1}/ca.crt"'';
      conf = pkgs.writeText "ca.conf" ''
        [req]
        distinguished_name = req_distinguished_name
        prompt = no
        x509_extensions = v3_ca

        [req_distinguished_name]
        C   = US
        ST  = North Carolina
        L   = Raleigh
        CN  = Proof of Concept

        [v3_ca]
        basicConstraints = critical,CA:TRUE
        keyUsage = cRLSign, keyCertSign
        nsComment = "Profian CA certificate"
        subjectKeyIdentifier = hash
      '';

      openssl = "${pkgs.openssl}/bin/openssl";
      sops = "${pkgs.sops}/bin/sops";
    in
      pkgs.writeShellScriptBin "bootstrap-ca" ''
        set -xe

        umask 0077

        ${openssl} ecparam -genkey -name prime256v1 | ${openssl} pkcs8 -topk8 -nocrypt -out ${key}
        ${openssl} req -new -x509 -days 365 -config ${conf} -key ${key} -out ${crt}
        ${sops} -e -i ${key}
      '';

    bootstrapSteward = pkgs: let
      ca.key = ''"ca/''${1}/ca.key"'';
      ca.crt = ''"ca/''${1}/ca.crt"'';

      steward.key = ''"hosts/attest.''${1}/steward.key"'';
      steward.csr = ''"hosts/attest.''${1}/steward.csr"'';
      steward.crt = ''"hosts/attest.''${1}/steward.crt"'';

      conf = pkgs.writeText "steward.conf" ''
        [req]
        distinguished_name = req_distinguished_name
        prompt = no
        x509_extensions = v3_ca

        [req_distinguished_name]
        C   = US
        ST  = North Carolina
        L   = Raleigh
        CN  = Proof of Concept

        [v3_ca]
        basicConstraints = critical,CA:TRUE
        keyUsage = cRLSign, keyCertSign
        nsComment = "Profian attestation service CA certificate"
        subjectKeyIdentifier = hash
      '';

      openssl = "${pkgs.openssl}/bin/openssl";
      sops = "${pkgs.sops}/bin/sops";

      sign-cert = "${pkgs.writeShellScriptBin "sign-cert" ''
        set -xe

        ${openssl} x509 -req -days 365 -CAcreateserial -CA ${ca.crt} -CAkey "''${2}" -in ${steward.csr} -out ${steward.crt} -extfile ${conf} -extensions v3_ca
      ''}/bin/sign-cert";
    in
      pkgs.writeShellScriptBin "bootstrap-steward" ''
        set -xe

        umask 0077

        ${openssl} ecparam -genkey -name prime256v1 | ${openssl} pkcs8 -topk8 -nocrypt -out ${steward.key}
        ${openssl} req -new -config ${conf} -key ${steward.key} -out ${steward.csr}
        ${sops} -e -i ${steward.key}

        ${sops} exec-file ${ca.key} "${sign-cert} \"''${1}\" {}"
      '';

    bootstrap = pkgs: let
      bootstrap-ca = "${pkgs.bootstrap-ca}/bin/bootstrap-ca";
      bootstrap-steward = "${pkgs.bootstrap-steward}/bin/bootstrap-steward";
    in
      pkgs.writeShellScriptBin "bootstrap" ''
        set -e

        for host in ca/*; do
            ${bootstrap-ca} "''${host#'ca/'}"
        done

        for host in hosts/attest.*; do
            ${bootstrap-steward} "''${host#'hosts/attest.'}"
        done
      '';

    toolingOverlay = self: super: {
      bootstrap = bootstrap self;
      bootstrap-ca = bootstrapCA self;
      bootstrap-steward = bootstrapSteward self;
      host-key = hostKey self;
    };

    mkDeployNode = system: nixos: {
      hostname = nixos.config.networking.fqdn;
      profiles.system.path = deploy-rs.lib.${system}.activate.nixos nixos;
      profiles.system.sshUser = sshUser;
      profiles.system.user = "root";
    };
  in
    with flake-utils.lib.system;
      {
        nixosConfigurations.sgx-equinix-demo = mkBenefice x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/sgx.equinix.demo.enarx.dev
            ];

            services.benefice.log.level = "info";
            services.benefice.oidc.client = oidc.client.demo.equinix.sgx;
            services.benefice.package = pkgs.benefice.staging;

            sops.secrets.oidc-secret.sopsFile = ./hosts/sgx.equinix.demo.enarx.dev/oidc-secret;
          })
        ];

        nixosConfigurations.snp-equinix-demo = mkBenefice x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/snp.equinix.demo.enarx.dev
            ];

            services.benefice.log.level = "info";
            services.benefice.oidc.client = oidc.client.demo.equinix.snp;
            services.benefice.package = pkgs.benefice.staging;

            sops.secrets.oidc-secret.sopsFile = ./hosts/snp.equinix.demo.enarx.dev/oidc-secret;
          })
        ];

        nixosConfigurations.attest-staging = mkSteward x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/attest.staging.profian.com
            ];

            services.steward.certFile = "${./hosts/attest.staging.profian.com/steward.crt}";
            services.steward.log.level = "info";
            services.steward.package = pkgs.steward.staging;

            sops.secrets.key.sopsFile = ./hosts/attest.staging.profian.com/steward.key;
          })
        ];

        nixosConfigurations.attest-testing = mkSteward x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/attest.testing.profian.com
            ];

            services.steward.certFile = "${./hosts/attest.testing.profian.com/steward.crt}";
            services.steward.log.level = "debug";
            services.steward.package = pkgs.steward.testing;

            sops.secrets.key.sopsFile = ./hosts/attest.testing.profian.com/steward.key;
          })
        ];

        nixosConfigurations.attest = mkSteward x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/attest.profian.com
            ];

            services.steward.certFile = "${./hosts/attest.profian.com/steward.crt}";
            services.steward.package = pkgs.steward.production;

            sops.secrets.key.sopsFile = ./hosts/attest.profian.com/steward.key;
          })
        ];

        nixosConfigurations.store-testing = mkDrawbridge x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/store.testing.profian.com
            ];

            services.drawbridge.log.level = "debug";
            services.drawbridge.oidc.client = oidc.client.testing.store;
            services.drawbridge.package = pkgs.drawbridge.testing;
            services.drawbridge.tls.caFile = "${./ca/testing.profian.com/ca.crt}";
          })
        ];

        nixosConfigurations.store-staging = mkDrawbridge x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/store.staging.profian.com
            ];

            services.drawbridge.log.level = "info";
            services.drawbridge.oidc.client = oidc.client.staging.store;
            services.drawbridge.package = pkgs.drawbridge.staging;
            services.drawbridge.tls.caFile = "${./ca/staging.profian.com/ca.crt}";
          })
        ];

        nixosConfigurations.store = mkDrawbridge x86_64-linux [
          ({pkgs, ...}: {
            imports = [
              ./hosts/store.profian.com
            ];

            services.drawbridge.oidc.client = oidc.client.production.store;
            services.drawbridge.package = pkgs.drawbridge.production;
            services.drawbridge.tls.caFile = "${./ca/profian.com/ca.crt}";
          })
        ];

        deploy.nodes.sgx-equinix-demo = mkDeployNode x86_64-linux self.nixosConfigurations.sgx-equinix-demo;
        deploy.nodes.snp-equinix-demo = mkDeployNode x86_64-linux self.nixosConfigurations.snp-equinix-demo;

        deploy.nodes.attest = mkDeployNode x86_64-linux self.nixosConfigurations.attest;
        deploy.nodes.attest-staging = mkDeployNode x86_64-linux self.nixosConfigurations.attest-staging;
        deploy.nodes.attest-testing = mkDeployNode x86_64-linux self.nixosConfigurations.attest-testing;

        deploy.nodes.store = mkDeployNode x86_64-linux self.nixosConfigurations.store;
        deploy.nodes.store-staging = mkDeployNode x86_64-linux self.nixosConfigurations.store-staging;
        deploy.nodes.store-testing = mkDeployNode x86_64-linux self.nixosConfigurations.store-testing;

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      }
      // flake-utils.lib.eachDefaultSystem (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              serviceOverlay
              toolingOverlay
            ];
          };

          enarx-sev-amazon = mkEnarxSevImage pkgs "amazon" [
            {
              amazonImage.sizeMB = 12 * 1024; # TODO: Figure out how much we actually need

              ec2.ena = false;
            }
          ];
        in {
          formatter = pkgs.alejandra;

          packages = pkgs.lib.optionalAttrs (system == x86_64-linux || system == aarch64-linux) {
            inherit enarx-sev-amazon;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.age
              pkgs.nixUnstable
              pkgs.openssl
              pkgs.sops
              pkgs.ssh-to-age

              pkgs.bootstrap
              pkgs.bootstrap-ca
              pkgs.bootstrap-steward
              pkgs.host-key

              deploy-rs.packages.${system}.default
            ];
          };
        }
      );
}
