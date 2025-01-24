{
  self,
  flake-utils,
  nix-darwin,
  nix-rosetta-builder,
  ...
}:
with flake-utils.lib.system;
  nix-darwin.lib.darwinSystem {
    system = aarch64-darwin;
    modules = [
      ({pkgs, ...}: {
        imports = [
          self.darwinModules.default

          nix-rosetta-builder.darwinModules.default
        ];

        networking.hostName = "iridium";

        networking.knownNetworkServices = [
          "Thunderbolt Bridge"
          "Wi-Fi"
        ];

        nix.linux-builder.enable = false;

        nixelium.profile.laptop.enable = true;
      })
    ];
  }
