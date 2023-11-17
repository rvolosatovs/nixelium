{
  description = "Network infrastructure à la Roman. Do not try this at home.";

  nixConfig.extra-substituters = [
    "https://rvolosatovs.cachix.org"
    "https://wasmcloud.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "rvolosatovs.cachix.org-1:eRYUO4OXTSmpDFWu4wX3/X08MsP01baqGKi9GsoAmQ8="
    "wasmcloud.cachix.org-1:9gRBzsKh+x2HbVVspreFg/6iFRiD4aOcUQfXVDl3hiM="
  ];

  inputs.base16-shell.flake = false;
  inputs.base16-shell.url = "github:chriskempson/base16-shell";
  inputs.felixkratz-formulae.flake = false;
  inputs.felixkratz-formulae.url = "github:FelixKratz/homebrew-formulae";
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.firefox-addons.inputs.flake-utils.follows = "flake-utils";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.home-manager-unstable.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-nixos";
  inputs.home-manager.url = "github:nix-community/home-manager/release-23.05";
  inputs.homebrew-bundle.flake = false;
  inputs.homebrew-bundle.url = "github:homebrew/homebrew-bundle";
  inputs.homebrew-cask.flake = false;
  inputs.homebrew-cask.url = "github:homebrew/homebrew-cask";
  inputs.homebrew-core.flake = false;
  inputs.homebrew-core.url = "github:homebrew/homebrew-core";
  inputs.homebrew-services.flake = false;
  inputs.homebrew-services.url = "github:homebrew/homebrew-services";
  inputs.ioquake3-mac-install.flake = false;
  inputs.ioquake3-mac-install.url = "github:rvolosatovs/ioquake3-mac-install";
  inputs.koekeishiya-formulae.flake = false;
  inputs.koekeishiya-formulae.url = "github:koekeishiya/homebrew-formulae";
  inputs.lanzaboote.inputs.flake-utils.follows = "flake-utils";
  inputs.lanzaboote.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.lanzaboote.url = "github:nix-community/lanzaboote";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  inputs.nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
  inputs.nix-homebrew.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-homebrew.inputs.nix-darwin.follows = "nix-darwin";
  inputs.nix-homebrew.inputs.nixpkgs.follows = "nixpkgs-darwin";
  inputs.nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  inputs.nixify.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.nixify.url = "github:rvolosatovs/nixify";
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
  inputs.nixpkgs-firefox-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  inputs.nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  inputs.nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-nixos";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs = inputs @ {
    self,
    nixify,
    ...
  }:
    with nixify.lib; let
      flake = mkFlake {
        withOverlays = {overlays, ...}: overlays // import ./overlays inputs;
        overlays = [
          self.overlays.default
        ];

        withDevShells = {
          devShells,
          pkgs,
          ...
        }:
          extendDerivations {
            buildInputs = [
              pkgs.age
              pkgs.openssh
              pkgs.openssl
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.yubikey-manager
              pkgs.yubikey-personalization

              pkgs.bootstrap
              pkgs.bootstrap-ca
              pkgs.host-key
              pkgs.ssh-for-each
            ];
          }
          devShells;

        withChecks = {
          checks,
          pkgs,
          ...
        }:
          checks
          // import ./checks inputs pkgs;

        withPackages = {
          pkgs,
          packages,
          ...
        }:
          packages
          // {
            inherit
              (pkgs)
              host-key
              install-iso-aarch64-linux
              install-iso-x86_64-linux
              neovim
              partition-osmium
              ssh-for-each
              ;
          };
      };
    in
      flake
      // {
        darwinConfigurations = import ./darwinConfigurations inputs;
        darwinModules = import ./darwinModules inputs;
        homeModules = import ./homeModules inputs;
        lib = import ./lib inputs;
        nixosConfigurations = import ./nixosConfigurations inputs;
        nixosModules = import ./nixosModules inputs;
      };
}
