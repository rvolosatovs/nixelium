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

        home-manager.users.rvolosatovs.home.packages = [
          pkgs.claude-code
          pkgs.codex
          pkgs.rustup

          pkgs.pkgsUnstable.bun
          pkgs.pkgsUnstable.gemini-cli
          pkgs.pkgsUnstable.gh
          pkgs.pkgsUnstable.github-copilot-cli
          pkgs.pkgsUnstable.nodejs
          pkgs.pkgsUnstable.python3
          pkgs.pkgsUnstable.uv
        ];

        networking.hostName = "darwin-aarch64-vm";

        security.sudo.extraConfig = ''
          %admin ALL=(ALL) NOPASSWD: ALL
        '';
      }
    )
  ];
}
