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

        home-manager.sharedModules = [ { home.stateVersion = "26.05"; } ];

        nixelium.profile.dev.enable = true;
        nixelium.profile.laptop.enable = true;

        system.stateVersion = 6;
      }
    )
  ];
}
