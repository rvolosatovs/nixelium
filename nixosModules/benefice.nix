{
  self,
  enarx,
  sops-nix,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.benefice;

  enarx-oci = enarx.packages.x86_64-linux.enarx-x86_64-unknown-linux-musl-oci;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [pkgs.enarx];

      networking.firewall.enable = mkForce false;

      profian.adminGroups = with config.users.groups; [docker.name];

      services.benefice.enarx.backend = config.services.enarx.backend;
      services.benefice.oci.backend = "docker";
      services.benefice.oci.image = "${enarx-oci.imageName}:${enarx-oci.imageTag}";
      services.benefice.oidc.secretFile = config.sops.secrets.oidc-secret.path;
      services.benefice.sessionKey = config.sops.secrets.benefice-session-key.path;

      services.enarx.enable = true;

      services.nginx.clientMaxBodySize = "100m";
      services.nginx.enable = true;
      services.nginx.appendHttpConfig = ''
        add_header Strict-Transport-Security "max-age=0";
      '';

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      sops.secrets.oidc-secret.format = "binary";
      sops.secrets.oidc-secret.mode = "0000";
      sops.secrets.oidc-secret.restartUnits = ["benefice.service"];
      sops.secrets.oidc-secret.sopsFile = "${self}/hosts/${config.networking.fqdn}/oidc-secret";

      sops.secrets.benefice-session-key.format = "binary";
      sops.secrets.benefice-session-key.mode = "0000";
      sops.secrets.benefice-session-key.restartUnits = ["benefice.service"];
      sops.secrets.benefice-session-key.sopsFile = "${self}/hosts/${config.networking.fqdn}/session-key";

      systemd.services.load-enarx-image.script = "${pkgs.docker}/bin/docker load < ${enarx-oci}";
      systemd.services.load-enarx-image.serviceConfig.Type = "oneshot";
      systemd.services.load-enarx-image.serviceConfig.DynamicUser = true;
      systemd.services.load-enarx-image.serviceConfig.SupplementaryGroups = with config.users.groups; [docker.name];
      systemd.services.load-enarx-image.wantedBy = ["multi-user.target"];

      # Workaround for https://github.com/profianinc/infrastructure/issues/109
      users.groups.benefice = {};

      # NOTE: This is essentially equal to giving `benefice` user `root` access, which is a terrible idea.
      # Ideally, we should use podman instead (see `virtualisation.podman.*`)
      # Alternatively, we could explore `virtualisation.docker.rootless.*`
      # Ideally, we should also split Benefice into a producer and consumer,
      # which communicate via a message queue like a Redis 6 stream.
      users.users.benefice.extraGroups = with config.users.groups; [docker.name];
      users.users.benefice.group = config.users.groups.benefice.name;
      users.users.benefice.isSystemUser = true;
    })
  ];
}
