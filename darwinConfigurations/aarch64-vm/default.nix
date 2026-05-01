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
    ({
      imports = [ self.darwinModules.default ];

      networking.hostName = "darwin-aarch64-vm";

      nixelium.profile.dev.enable = true;
      nixelium.profile.vm.enable = true;

      security.sudo.extraConfig = ''
        %admin ALL=(ALL) NOPASSWD: ALL
      '';
    })
  ];
}
