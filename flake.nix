{
  description = "Network infrastructure à la Roman. Do not try this at home.";

  nixConfig.extra-substituters = [
    "https://rvolosatovs.cachix.org"
    "https://nixify.cachix.org"
    "https://crane.cachix.org"
    "https://nix-community.cachix.org"
    "https://bytecodealliance.cachix.org"
    "https://wasmcloud.cachix.org"
  ];
  nixConfig.extra-trusted-substituters = [
    "https://rvolosatovs.cachix.org"
    "https://nixify.cachix.org"
    "https://crane.cachix.org"
    "https://nix-community.cachix.org"
    "https://bytecodealliance.cachix.org"
    "https://wasmcloud.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "rvolosatovs.cachix.org-1:eRYUO4OXTSmpDFWu4wX3/X08MsP01baqGKi9GsoAmQ8="
    "nixify.cachix.org-1:95SiUQuf8Ij0hwDweALJsLtnMyv/otZamWNRp1Q1pXw="
    "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "bytecodealliance.cachix.org-1:0SBgh//n2n0heh0sDFhTm+ZKBRy2sInakzFGfzN531Y="
    "wasmcloud.cachix.org-1:9gRBzsKh+x2HbVVspreFg/6iFRiD4aOcUQfXVDl3hiM="
  ];

  inputs.base16-shell.flake = false;
  inputs.base16-shell.url = "github:chriskempson/base16-shell";
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.home-manager-unstable.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-nixos";
  inputs.home-manager.url = "github:nix-community/home-manager/release-25.05";
  inputs.ioquake3-mac-install.flake = false;
  inputs.ioquake3-mac-install.url = "github:rvolosatovs/ioquake3-mac-install";
  inputs.lanzaboote.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.lanzaboote.url = "github:nix-community/lanzaboote";
  inputs.neovim.inputs.flake-utils.follows = "flake-utils";
  inputs.neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.neovim.url = "github:neovim/neovim/dd00b6b442a6d3a8a4758b0ee10ac93d07e7db72?dir=contrib"; # last-known good commit
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  inputs.nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
  inputs.nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
  inputs.nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs-darwin";
  inputs.nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
  inputs.nixify.inputs.nixlib.follows = "nixlib";
  inputs.nixify.inputs.nixpkgs-darwin.follows = "nixpkgs-darwin";
  inputs.nixify.inputs.nixpkgs-nixos.follows = "nixpkgs-nixos";
  inputs.nixify.url = "github:rvolosatovs/nixify";
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs-23_05.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
  inputs.nixpkgs-neovim.url = "github:NixOS/nixpkgs/f8776630508052f95ac72f149cb70d805152b512"; # neovim 0.10.4
  inputs.nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-25.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.wit-deps.url = "github:bytecodealliance/wit-deps/v0.5.0";

  outputs = inputs @ {
    self,
    nixify,
    wit-deps,
    ...
  }:
    with nixify.lib; let
      flake = mkFlake {
        withOverlays = {overlays, ...}: overlays // import ./overlays inputs;
        overlays = [
          self.overlays.default
          wit-deps.overlays.default
        ];

        excludePaths = [
          ".envrc"
          ".github"
          ".gitignore"
          "flake.nix"
          "LICENSE"
          "README.md"
        ];

        withDevShells = {
          devShells,
          pkgs,
          ...
        }:
          extendDerivations {
            buildInputs = [
              pkgs.age
              pkgs.nixos-rebuild
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
              firefox
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
