{
  description = "Profian Inc Network Infrastructure";

  inputs.benefice-staging.flake = false;
  inputs.benefice-staging.url = "https://github.com/profianinc/benefice/releases/download/v0.1.0-rc13/benefice-x86_64-unknown-linux-musl";
  inputs.benefice-testing.url = github:profianinc/benefice;
  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge-production.url = github:profianinc/drawbridge/v0.2.2;
  inputs.drawbridge-staging.url = github:profianinc/drawbridge/v0.2.2;
  inputs.drawbridge-testing.url = github:profianinc/drawbridge;
  inputs.enarx.flake = false;
  inputs.enarx.url = "https://github.com/rvolosatovs/enarx/releases/download/v0.6.3-rc1/enarx-x86_64-unknown-linux-musl";
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixlib.url = github:nix-community/nixpkgs.lib;
  inputs.nixpkgs.url = github:profianinc/nixpkgs;
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = github:Mic92/sops-nix;
  inputs.steward-production.flake = false;
  inputs.steward-production.url = "https://github.com/profianinc/steward/releases/download/v0.1.0/steward-x86_64-unknown-linux-musl";
  inputs.steward-staging.flake = false;
  inputs.steward-staging.url = "https://github.com/profianinc/steward/releases/download/v0.1.0/steward-x86_64-unknown-linux-musl";
  inputs.steward-testing.url = github:profianinc/steward;

  outputs = inputs @ {
    self,
    deploy-rs,
    flake-utils,
    nixpkgs,
    ...
  }:
    {
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      deploy = import ./deploy inputs;
      lib = import ./lib inputs;
      nixosConfigurations = import ./nixosConfigurations inputs;
      nixosModules = import ./nixosModules inputs;
      overlays = import ./overlays inputs;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            age
            awscli2
            nixUnstable
            openssh
            openssl
            sops
            ssh-to-age
            tailscale

            bootstrap
            bootstrap-ca
            bootstrap-steward
            host-key
            ssh-for-each

            deploy-rs.packages.${system}.default
          ];
        };
      in {
        devShells.default = devShell;
        formatter = pkgs.alejandra;
      }
    );
}
