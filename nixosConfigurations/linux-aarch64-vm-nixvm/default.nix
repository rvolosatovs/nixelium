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
      { config, pkgs, ... }:
      {
        imports = [ self.nixosModules.default ];

        home-manager.users.owner.home.packages = [
          pkgs.claude-code
          pkgs.codex
          pkgs.rustup

          pkgs.pkgsUnstable.github-copilot-cli
        ];

        networking.hostName = "linux-aarch64-vm";

        nixelium.system.isVirtual = true;

        nixvm.guest.rootSize = "128G";

        services.getty.autologinUser = config.users.users.owner.name;

        system.image.id = "linux-aarch64-vm";
        system.image.version = "1";
      }
    )
  ];
}
