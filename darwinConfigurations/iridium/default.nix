{
  self,
  flake-utils,
  nix-darwin,
  ...
}:
with flake-utils.lib.system;
  nix-darwin.lib.darwinSystem {
    system = aarch64-darwin;
    modules = [
      ({pkgs, ...}: {
        imports = [
          self.darwinModules.default
        ];

        networking.hostName = "iridium";

        networking.knownNetworkServices = [
          "Thunderbolt Bridge"
          "Wi-Fi"
        ];

        nix.linux-builder.config.virtualisation.darwin-builder.diskSize = 100 * 1024;
        nix.linux-builder.config.virtualisation.darwin-builder.memorySize = 8 * 1024;

        nixelium.profile.laptop.enable = true;
      })
    ];
  }
