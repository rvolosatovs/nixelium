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
  cfg = config.profian.monitoring;
in {
  options.profian.monitoring = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      sops.secrets.monitoring_token.format = "binary";
      sops.secrets.monitoring_token.mode = "0600";
      sops.secrets.monitoring_token.restartUnits = ["datadog-agent.service"];
      sops.secrets.monitoring_token.sopsFile = "${self}/secrets/monitoring_api_token";
      sops.secrets.monitoring_token.owner = config.users.users.datadog.name;
      sops.secrets.monitoring_token.group = config.users.groups.datadog.name;

      users.users.datadog.extraGroups = with config.users.groups; [
        systemd-journal.name
        "docker"
      ];

      services.datadog-agent.enable = true;
      services.datadog-agent.hostname = config.networking.fqdn;
      services.datadog-agent.site = "datadoghq.com";
      services.datadog-agent.apiKeyFile = config.sops.secrets.monitoring_token.path;
      services.datadog-agent.enableTraceAgent = true;
      services.datadog-agent.enableLiveProcessCollection = true;
      services.datadog-agent.logLevel = "ERROR";
      services.datadog-agent.tags = [
        "environment:${config.profian.environment}"
      ];
      services.datadog-agent.extraConfig = {
        logs_enabled = true;
      };
      services.datadog-agent.checks = {
      };
      services.datadog-agent.checks.journald.logs = [
        {
          type = "journald";
          container_mode = true;
        }
      ];
    })

    (mkIf (cfg.enable && config.services.nginx.enable) {
      services.datadog-agent.checks.nginx.instances = [
        {
          nginx_status_url = "http://localhost/nginx_status/";
        }
      ];
      services.datadog-agent.checks.nginx.logs = [
        {
          type = "file";
          path = "/var/log/nginx/access.log";
          service = "nginx";
          source = "nginx";
        }
        {
          type = "file";
          path = "/var/log/nginx/error.log";
          service = "nginx";
          source = "nginx";
        }
      ];
      services.nginx.statusPage = true;
    })
  ];
}
