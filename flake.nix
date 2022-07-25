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
  inputs.enarx.url = "https://github.com/enarx/enarx/releases/download/v0.6.1/enarx-x86_64-unknown-linux-musl";
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
    with flake-utils.lib.system;
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

          is64BitLinux = system == x86_64-linux || system == aarch64-linux;

          packages = pkgs.lib.optionalAttrs is64BitLinux {
            inherit
              (pkgs)
              enarx-sev-amazon
              ;
          };

          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              age
              awscli2
              nixUnstable
              openssl
              sops
              ssh-to-age
              openssh

              aws-create-ami
              aws-create-vmimport-role
              aws-put-vmimport-role-policy

              bootstrap
              bootstrap-ca
              bootstrap-steward
              host-key
              ssh-for-each

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
