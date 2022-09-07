{
  self,
  sops-nix,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.services.cloudflared;
in {
  options.services.cloudflared = {
    tunnel_name = mkOption {
      type = types.str;
    };
  };

  config = mkMerge [
    ({
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      sops.secrets.cloudflare_token.format = "binary";
      sops.secrets.cloudflare_token.mode = "0000";
      sops.secrets.cloudflare_token.restartUnits = ["cloudflared.service"];
      sops.secrets.cloudflare_token.sopsFile = "${self}/secrets/${config.profian.environment}/cloudflared/${cfg.tunnel_name}";

      systemd.services.cloudflared = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $tunnel_token";
          EnvironmentFile = "${config.sops.secrets.cloudflare_token.path}";
          User = config.users.users.cloudflared.name;
          Group = config.users.groups.cloudflared.name;
        };
      };

      users.groups.cloudflared = {};
      users.users.cloudflared.isSystemUser = true;
      users.users.cloudflared.group = config.users.groups.cloudflared.name;

      environment.systemPackages = [pkgs.cloudflared];
    })
  ];
}
