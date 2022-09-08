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

    enableMonitoring = mkOption {
      type = types.bool;
      default = true;
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

    (mkIf (cfg.enableMonitoring) {
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      sops.secrets.monitoring_token.format = "binary";
      sops.secrets.monitoring_token.mode = "0600";
      sops.secrets.monitoring_token.restartUnits = ["datadog-agent.service"];
      sops.secrets.monitoring_token.sopsFile = "${self}/secrets/monitoring_api_token";
      sops.secrets.monitoring_token.owner = config.users.users.datadog.name;
      sops.secrets.monitoring_token.group = config.users.groups.datadog.name;

      users.users.datadog.extraGroups = [
        config.users.groups.systemd-journal.name
      ];

      services.datadog-agent.enable = true;
      services.datadog-agent.hostname = config.networking.fqdn;
      services.datadog-agent.site = "datadoghq.com";
      services.datadog-agent.apiKeyFile = config.sops.secrets.monitoring_token.path;
      services.datadog-agent.enableTraceAgent = true;
      services.datadog-agent.enableLiveProcessCollection = true;
      services.datadog-agent.logLevel = "WARN";
      services.datadog-agent.tags = [
        "environment:${cfg.environment}"
      ];
      services.datadog-agent.extraConfig = {
        logs_enabled = true;
      };
      services.datadog-agent.checks.journald.logs = [
        {
          type = "journald";
          container_mode = true;
        }
      ];
    })
  ];
}
