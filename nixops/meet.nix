{ config, ... }:
let
  serviceName = "meet";
  secretName = "${serviceName}-secrets";
in
  {
    deployment.keys.${secretName} = {
      text = with config.resources; ''
        JICOFO_AUTH_PASSWORD=${jicofo.authPassword}
        JICOFO_COMPONENT_SECRET=${jicofo.componentSecret}
        JIGASI_XMPP_PASSWORD="${jigasi.xmppPassword}";
        JVB_AUTH_PASSWORD=${jvb.authPassword}
      '';

      user = serviceName;
    };

    systemd.services.${serviceName} = {
      serviceConfig.EnvironmentFile = config.deployment.keys.${secretName}.path;

      after = [ "${secretName}-key.service" ];
      wants = [ "${secretName}-key.service" ];
    };

    users.users.${serviceName}.extraGroups = [ "keys" ];
  }
