{
  description = "Profian Inc Network Infrastructure";

  inputs.benefice-staging.flake = false;
  inputs.benefice-staging.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc9/benefice-x86_64-unknown-linux-musl";
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
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";
  inputs.nixos-generators.inputs.nixlib.follows = "nixlib";
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

  outputs = inputs @ {
    self,
    deploy-rs,
    flake-utils,
    nixos-generators,
    nixpkgs,
    ...
  }:
    with flake-utils.lib.system; let
      mkEnarxImage = pkgs: format: modules:
        nixos-generators.nixosGenerate {
          inherit format pkgs;
          modules =
            [
              "${self}/modules/common.nix"
              ({pkgs, ...}: {
                networking.firewall.allowedTCPPorts = [
                  80
                  443
                ];

                nixpkgs.overlays = [self.overlays.service];
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
    in
      {
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        deploy = import ./deploy inputs;
        nixosConfigurations = import ./nixosConfigurations inputs;
        overlays = import ./overlays inputs;
      }
      // flake-utils.lib.eachDefaultSystem (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [self.overlays.default];
          };

          enarx-sev-amazon = mkEnarxSevImage pkgs "amazon" [
            {
              amazonImage.sizeMB = 12 * 1024; # TODO: Figure out how much we actually need

              ec2.ena = false;
            }
          ];

          packages = pkgs.lib.optionalAttrs (system == x86_64-linux || system == aarch64-linux) {
            inherit enarx-sev-amazon;
          };

          devShell = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.age
              pkgs.aws
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
        in {
          inherit packages;

          formatter = pkgs.alejandra;
          devShells.default = devShell;
        }
      );
}
