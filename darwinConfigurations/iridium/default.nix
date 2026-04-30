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
    (
      { ... }:
      {
        imports = [ self.darwinModules.default ];

        networking.hostName = "iridium";

        networking.knownNetworkServices = [
          "Thunderbolt Bridge"
          "Wi-Fi"
        ];

        nixelium.profile.dev.enable = true;
        nixelium.profile.laptop.enable = true;
      }
    )
  ];
}
