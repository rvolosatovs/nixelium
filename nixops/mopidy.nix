{ config, ... }:
let
  serviceName = "mopidy";
  secretName = "${serviceName}Secrets";
in
  {
    deployment.keys.${secretName} = {
      text = with config.resources; ''
        [soundcloud]
        auth_token = ${soundcloud.token}
        [spotify]
        username = ${spotify.username}
        password = ${spotify.password}
        client_id = ${spotify.clientID}
        client_secret = ${spotify.clientSecret}
      '';
      user = serviceName;
    };

    services.${serviceName}.extraConfigFiles = [ config.deployment.keys.${secretName}.path ];

    systemd.services.${serviceName} = {
      after = [ "${secretName}-key.service" ];
      wants = [ "${secretName}-key.service" ];
    };

    users.users.${serviceName}.extraGroups = [ "keys" ];
  }
