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
      { pkgs, ... }:
      {
        imports = [ self.nixosModules.default ];

        system.image.id = "aarch64-linux-vm";
        system.image.version = "1";

        networking.hostName = "aarch64-linux-vm";

        nixelium.system.isVirtual = true;

        nixvm.guest.rootSize = "128G";

        home-manager.users.owner.home.packages = [
          pkgs.claude-code
          pkgs.codex
          pkgs.rustup

          pkgs.pkgsUnstable.github-copilot-cli
        ];
      }
    )
  ];
}
