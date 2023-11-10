{
  self,
  home-manager,
  nixlib,
  ...
}: {
  config,
  pkgs,
  ...
}:
with nixlib.lib; let
  cfg = config.nixelium;
in {
  imports = [
    self.systemModules.default

    home-manager.darwinModules.home-manager
  ];
  config = mkMerge [
    {
      # TODO: Set user zsh config

      nix.configureBuildUsers = true;

      nix.settings.allowed-users = with config.users; [
        "@admin"
      ];
      nix.settings.trusted-users = with config.users; [
        "@admin"
      ];

      networking.dns = cfg.dns;

      programs.bash.enable = true;
      programs.bash.enableCompletion = true;

      services.nix-daemon.enable = true;

      system.stateVersion = 4;
    }
    (mkIf cfg.build.enable {
      users.groups.nix.gid = 542;
      users.groups.nix.members = ["nix"];

      users.knownGroups = with config.users; [
        groups.nix.name
      ];
      users.knownUsers = with config.users; [
        users.nix.name
        users.owner.name
      ];

      users.users.nix.createHome = true;
      users.users.nix.gid = config.users.groups.nix.gid;
      users.users.nix.home = "/Users/nix";
      users.users.nix.uid = config.users.groups.nix.gid;

      users.users.owner.uid = mkDefault 501;
    })
    (mkIf cfg.tailscale.enable {
      services.tailscale.domain = "${cfg.owner.username}.github";
      services.tailscale.magicDNS.enable = true;
    })
  ];
}
