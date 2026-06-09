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
      { config, ... }:
      {
        imports = [ self.darwinModules.default ];

        networking.hostName = "darwin-aarch64-vm";

        home-manager.sharedModules = [ { home.stateVersion = "26.05"; } ];

        nixelium.profile.dev.enable = true;
        nixelium.profile.vm.enable = true;

        home-manager.users.${config.system.primaryUser}.nixelium.profile.unrestricted-ai.enable = true;

        security.sudo.extraConfig = ''
          %admin ALL=(ALL) NOPASSWD: ALL
        '';

        system.stateVersion = 7;
      }
    )
  ];
}
