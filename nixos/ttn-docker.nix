{ config, pkgs, lib, ... }:
let
  composeFile = ./../../../../go.thethings.network/lorawan-stack/docker-compose.yml;
  composeFileOverrides = builtins.toFile "docker-compose.overrides.yml" ''
    version: '3.5'

    secrets:
      cert.pem:
        file: ${config.security.acme.directory}/ttn.${config.resources.domainName}/full.pem
      key.pem:
        file: ${config.security.acme.directory}/ttn.${config.resources.domainName}/key.pem

  '';
  composeCmd = "${pkgs.docker_compose}/bin/docker-compose -f ${composeFile} -f ${composeFileOverrides}";

  configHome = "/var/lib/ttn";
  httpPort = 1885;
in
  {
    services.nginx.enable = true;
    services.nginx.virtualHosts."ttn".addSSL = true;
    services.nginx.virtualHosts."ttn".enableACME = true;
    services.nginx.virtualHosts."ttn".locations."/".proxyPass = "http://localhost:${toString httpPort}";
    services.nginx.virtualHosts."ttn".serverName = "ttn.${config.resources.domainName}";

    systemd.services.ttn.after = [ "network.target" ];
    systemd.services.ttn.description = "The Things Network LoRaWAN stack";
    systemd.services.ttn.enable = true;

    systemd.services.ttn.script = ''
      ${composeCmd} pull
      ${composeCmd} up
    '';

    systemd.services.ttn.environment.DEV_DATA_DIR = configHome;

    systemd.services.ttn.serviceConfig.ExecStop = "${composeCmd} stop";
    systemd.services.ttn.serviceConfig.User = "ttn";
    systemd.services.ttn.serviceConfig.Group = "docker";
    systemd.services.ttn.serviceConfig.WorkingDirectory = configHome;
    systemd.services.ttn.wantedBy = [ "multi-user.target" ];

    users.users.ttn = {
      createHome = true;
      description = "The Things Network user";
      home = configHome;
      extraGroups = [ "nginx" ];
    };

    virtualisation.docker.enable = true;
  }
