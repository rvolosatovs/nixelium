{
  self,
  flake-utils,
  nixpkgs-nixos,
  nixvm,
  ...
}:
with flake-utils.lib.system;
nixpkgs-nixos.lib.nixosSystem {
  system = aarch64-linux;
  modules = [
    nixvm.nixosModules.guest
    (
      { config, ... }:
      {
        imports = [ self.nixosModules.default ];

        networking.hostName = "linux-aarch64-vm";

        nixelium.profile.dev.enable = true;
        nixelium.profile.vm.enable = true;

        home-manager.users.owner.nixelium.profile.unrestricted-ai.enable = true;

        nixvm.guest.rootSize = "128G";

        services.getty.autologinUser = config.users.users.owner.name;

        system.image.id = "linux-aarch64-vm";
        system.image.version = "1";
      }
    )
  ];
}
