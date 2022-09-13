{
  self,
  sops-nix,
  ...
}: {
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profian;

  emails.ops = "ops@profian.com";
in {
  options.profian = {
    environment = mkOption {
      type = types.enum ["production" "staging" "testing"];
      description = "Service environment.";
    };
  };

  imports = [
    self.nixosModules.benefice
    self.nixosModules.common
    self.nixosModules.drawbridge
    self.nixosModules.providers
    self.nixosModules.shells
    self.nixosModules.steward
    self.nixosModules.users
    self.nixosModules.monitoring
    sops-nix.nixosModules.sops
  ];

  config = mkMerge [
    {
      environment.systemPackages = with pkgs; [
        curl
        emacs
        nano
        openssl
      ];

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      nix.settings.allowed-users = with config.users; [
        "@${groups.wheel.name}"
        users.root.name
      ];
      nix.settings.trusted-users = with config.users; [
        users.root.name
      ];

      nixpkgs.overlays = [self.overlays.service];

      profian.users.deploy.enable = true;
      profian.users.haraldh.enable = true;
      profian.users.npmccallum.enable = true;
      profian.users.platten.enable = true;
      profian.users.puiterwijk.enable = true;
      profian.users.rvolosatovs.enable = true;

      programs.neovim.enable = true;

      security.acme.defaults.email = emails.ops;

      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = false;

      services.openssh.enable = true;
    }

    (mkIf (cfg.environment == "testing") {
      profian.users.deploy.ciAccess = true;
    })

    (mkIf (cfg.environment == "staging") {
      profian.users.deploy.ciAccess = true;
    })

    (mkIf (cfg.environment == "production") {
      })
  ];
}
