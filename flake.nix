{
  description = "Network infrastructure à la Roman. Do not try this at home.";

  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";
  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.drawbridge.url = github:rvolosatovs/drawbridge;
  inputs.flake-compat.flake = false;
  inputs.flake-compat.url = github:edolstra/flake-compat;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixlib.url = github:nix-community/nixpkgs.lib;
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = github:Mic92/sops-nix;
  inputs.steward.url = github:rvolosatovs/steward;

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
      nixosConfigurations = import ./nixosConfigurations inputs;
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
              openssl
              sops
              ssh-to-age

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
