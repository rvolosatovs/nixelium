{ config, pkgs, lib, ... }:
let
  composeFile = ./../vendor/docker-jitsi-meet/docker-compose.yml;
  composeFileOverrides = builtins.toFile "docker-compose.overrides.yml" ''
    version: '3'

    services:
        web:
            image: rvolosatovs/jitsi-web

        prosody:
            image: rvolosatovs/prosody

        jicofo:
            image: rvolosatovs/jicofo

        jvb:
            image: rvolosatovs/jvb
  '';
  composeCmd = "${pkgs.docker_compose}/bin/docker-compose -f ${composeFile} -f ${composeFileOverrides}";

  configHome = "/var/lib/meet";
  httpPort = 24001;
  httpsPort = 24101;
in
  {
    services.nginx.enable = true;
    services.nginx.virtualHosts."meet".enableACME = true;
    services.nginx.virtualHosts."meet".forceSSL = true;
    services.nginx.virtualHosts."meet".locations."/".proxyPass = "http://localhost:${builtins.toString httpPort}";
    services.nginx.virtualHosts."meet".serverName = "meet.${config.resources.domainName}";

    systemd.services.meet.after = [ "network.target" ];
    systemd.services.meet.description = "Jitsi Meet conferencing";
    systemd.services.meet.enable = true;

    systemd.services.meet.environment.CONFIG = configHome;
    systemd.services.meet.environment.DISABLE_HTTPS = "1";
    systemd.services.meet.environment.ENABLE_AUTH = "1";
    systemd.services.meet.environment.ENABLE_GUESTS = "1";
    systemd.services.meet.environment.ENABLE_LETSENCRYPT = "0";
    systemd.services.meet.environment.HTTPS_PORT = builtins.toString httpsPort;
    systemd.services.meet.environment.HTTP_PORT = builtins.toString httpPort;
    systemd.services.meet.environment.JICOFO_AUTH_USER="focus";
    systemd.services.meet.environment.JIGASI_BREWERY_MUC = "jigasibrewery";
    systemd.services.meet.environment.JIGASI_PORT_MAX = "20050";
    systemd.services.meet.environment.JIGASI_PORT_MIN = "20000";
    systemd.services.meet.environment.JIGASI_XMPP_USER = "jigasi";
    systemd.services.meet.environment.JVB_AUTH_USER = "jvb";
    systemd.services.meet.environment.JVB_BREWERY_MUC = "jvbbrewery";
    systemd.services.meet.environment.JVB_PORT = "10000";
    systemd.services.meet.environment.JVB_STUN_SERVERS = "stun.l.google.com:19302,stun1.l.google.com:19302,stun2.l.google.com:19302";
    systemd.services.meet.environment.JVB_TCP_HARVESTER_DISABLED = "true";
    systemd.services.meet.environment.JVB_TCP_PORT = "4443";
    systemd.services.meet.environment.LETSENCRYPT_DOMAIN = "meet.${config.resources.domainName}";
    systemd.services.meet.environment.LETSENCRYPT_EMAIL = config.resources.email;
    systemd.services.meet.environment.TZ = "Europe/Amsterdam";
    systemd.services.meet.environment.XMPP_AUTH_DOMAIN = "auth.meet.jitsi";
    systemd.services.meet.environment.XMPP_DOMAIN = "meet.jitsi";
    systemd.services.meet.environment.XMPP_GUEST_DOMAIN = "guest.meet.jitsi";
    systemd.services.meet.environment.XMPP_INTERNAL_MUC_DOMAIN = "internal-muc.meet.jitsi";
    systemd.services.meet.environment.XMPP_MUC_DOMAIN = "muc.meet.jitsi";

    # TODO: Set proper permissions, remove configs on start
    systemd.services.meet.script = ''
      ${composeCmd} pull
      ${composeCmd} up
    '';

    systemd.services.meet.serviceConfig.ExecStartPost = (pkgs.writeShellScriptBin "post-start" ''
      sleep 1
      until ${pkgs.docker}/bin/docker exec $(${composeCmd} ps -q prosody) /bin/bash -c 'prosodyctl --config /config/prosody.cfg.lua register ${config.resources.username} meet.jitsi ${config.resources.meet.userPassword}'; do sleep 0.5; done
    '') + "/bin/post-start";

    systemd.services.meet.serviceConfig.ExecStop = "${composeCmd} stop";
    systemd.services.meet.serviceConfig.User = "meet";
    systemd.services.meet.serviceConfig.Group = "docker";
    systemd.services.meet.serviceConfig.WorkingDirectory = configHome;
    systemd.services.meet.wantedBy = [ "multi-user.target" ];

    users.users.meet = {
      createHome = true;
      description = "Jitsi Meet user";
      home = configHome;
    };

    virtualisation.docker.enable = true;
  }
