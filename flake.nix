{
  description = "Profian Inc Network Infrastructure";

  inputs.benefice-production.url = github:profianinc/benefice/v0.1.2-rc6;
  inputs.benefice-staging.url = github:profianinc/benefice/v0.1.2-rc6;
  inputs.benefice-testing.url = github:profianinc/benefice;
  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge-production.url = github:profianinc/drawbridge/v0.2.2;
  inputs.drawbridge-staging.url = github:profianinc/drawbridge/v0.2.2;
  inputs.drawbridge-testing.url = github:profianinc/drawbridge;
  inputs.enarx.url = github:enarx/enarx; # temporarily use `main` until version above v0.6.3 is released
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixlib.url = github:nix-community/nixpkgs.lib;
  inputs.nixpkgs.url = github:profianinc/nixpkgs;
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = github:Mic92/sops-nix;
  inputs.steward-production.url = github:profianinc/steward/v0.1.0;
  inputs.steward-staging.url = github:profianinc/steward/v0.1.0;
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

        devShells.base = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixUnstable
            openssh

            deploy-rs.packages.${system}.default
          ];
        };

        devShells.default = devShells.base.overrideAttrs (attrs: {
          buildInputs = with pkgs;
            attrs.buildInputs
            ++ [
              age
              awscli2
              openssl
              sops
              ssh-to-age
              tailscale

              bootstrap
              bootstrap-ca
              bootstrap-steward
              host-key
              ssh-for-each
            ];
        });
      in {
        inherit devShells;

        formatter = pkgs.alejandra;
      }
    );
}
