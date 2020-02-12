{ config, ... }:
let
  serviceName = "deluge";
  secretName = "${serviceName}-secrets";
in
  {
    deployment.keys.${secretName} = {
      text = with config.resources; ''
        localclient:${deluge.localclientPassword}:10
        ${username}:${deluge.userPassword}:10
      '';
      user = serviceName;
    };

    services.${serviceName}.authFile = config.deployment.keys.${secretName}.path;

    systemd.services.deluged = {
      after = [ "${secretName}-key.service" ];
      wants = [ "${secretName}-key.service" ];
    };

    users.users.${serviceName}.extraGroups = [ "keys" ];
  }
