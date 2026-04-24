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
      { pkgs, ... }:
      {
        imports = [ self.darwinModules.default ];

        networking.hostName = "darwin-aarch64-vm";

        security.sudo.extraConfig = ''
          %admin ALL=(ALL) NOPASSWD: ALL
        '';

        home-manager.users.rvolosatovs.home.packages = [ pkgs.claude-code ];
      }
    )
  ];
}
