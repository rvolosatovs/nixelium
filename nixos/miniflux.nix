{
  config,
  pkgs,
  ...
}: let
  httpPort = 24004;
in {
  networking.firewall.allowedTCPPorts = [httpPort];

  services.miniflux.enable = true;
  services.miniflux.config.LISTEN_ADDR = ":${toString httpPort}";

  users.groups.miniflux = {};
  users.users.miniflux.group = "miniflux";
  users.users.miniflux.isSystemUser = true;
}
