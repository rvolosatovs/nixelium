{ config, pkgs, ... }:
let
  configHome = "/var/lib/miniflux";

  httpPort = 24004;
in
  {
    environment.systemPackages = [
      pkgs.miniflux
    ];

    services.nginx.enable = true;
    services.nginx.virtualHosts."news".addSSL = true;
    services.nginx.virtualHosts."news".enableACME = true;
    services.nginx.virtualHosts."news".locations."/".proxyPass = "http://localhost:${toString httpPort}";
    services.nginx.virtualHosts."news".serverName = "news.${config.resources.domainName}";

    services.postgresql.enable = true;

    systemd.services.miniflux.after = [ "network.target" "postgresql.service" ];
    systemd.services.miniflux.description = "Miniflux service";
    systemd.services.miniflux.enable = true;
    systemd.services.miniflux.environment.DATABASE_URL = "postgres://miniflux:miniflux@localhost:${toString config.services.postgresql.port}/miniflux?sslmode=disable";
    systemd.services.miniflux.environment.LISTEN_ADDR = "localhost:${toString httpPort}";
    systemd.services.miniflux.environment.RUN_MIGRATIONS = "1";
    systemd.services.miniflux.serviceConfig.ExecStart = "${pkgs.miniflux}/bin/miniflux";
    systemd.services.miniflux.serviceConfig.Group = "miniflux";
    systemd.services.miniflux.serviceConfig.PermissionsStartOnly = true;
    systemd.services.miniflux.serviceConfig.User = "miniflux";
    systemd.services.miniflux.wantedBy = [ "multi-user.target" ];

    systemd.services.miniflux.preStart = ''
      if ! [ -e ${configHome}/.db-created ]; then
        ${pkgs.sudo}/bin/sudo -u ${config.services.postgresql.superUser} \
          ${config.services.postgresql.package}/bin/createuser miniflux
        ${pkgs.sudo}/bin/sudo -u ${config.services.postgresql.superUser} \
          ${config.services.postgresql.package}/bin/createdb -O miniflux miniflux
        ${pkgs.sudo}/bin/sudo -u ${config.services.postgresql.superUser} \
          ${config.services.postgresql.package}/bin/psql miniflux -c \
            "ALTER ROLE miniflux WITH PASSWORD 'miniflux';" || true
        ${pkgs.sudo}/bin/sudo -u ${config.services.postgresql.superUser} \
          ${config.services.postgresql.package}/bin/psql miniflux -c \
            "CREATE EXTENSION IF NOT EXISTS hstore"
        touch ${configHome}/.db-created
      fi
    '';

    users.users.miniflux = {
      createHome = true;
      description = "Miniflux user";
      group = "miniflux";
      home = configHome;
      isSystemUser = true;
    };
    users.groups.miniflux = {};
  }
