{
  self,
  sops-nix,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.steward;
in {
  options.services.steward = {
    nginx.enable = mkEnableOption "nginx reverse proxy";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.steward.certFile = pkgs.writeText "steward.crt" (builtins.readFile "${self}/hosts/${config.networking.fqdn}/steward.crt");
      services.steward.keyFile = config.sops.secrets.key.path;

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      sops.secrets.key.format = "binary";
      sops.secrets.key.mode = "0000";
      sops.secrets.key.restartUnits = ["steward.service"];
      sops.secrets.key.sopsFile = "${self}/hosts/${config.networking.fqdn}/steward.key";

      systemd.services.steward = self.lib.systemd.withSecret config pkgs "steward" "key";

      # Workaround for https://github.com/profianinc/infrastructure/issues/109
      users.groups.steward = {};

      users.users.steward.isSystemUser = true;
      users.users.steward.group = config.users.groups.steward.name;
    })
    (mkIf cfg.nginx.enable {
      services.nginx.enable = true;
      services.nginx.virtualHosts.${config.networking.fqdn} = {
        enableACME = true;
        forceSSL = true;
        http2 = false;
        locations."/".proxyPass = "http://localhost:3000";
      };
    })
  ];
}
