{config, ...}: let
  serviceName = "miniflux";
  secretName = "${serviceName}-secrets";
in {
  deployment.keys.${secretName} = {
    text = with config.resources; ''
      ADMIN_USERNAME = ${username}
      ADMIN_PASSWORD = ${miniflux.adminPassword}
    '';
    user = serviceName;
  };

  services.${serviceName}.adminCredentialsFile = config.deployment.keys.${secretName}.path;

  systemd.services.${serviceName} = {
    after = ["${secretName}-key.service"];
    wants = ["${secretName}-key.service"];
  };

  users.users.${serviceName}.extraGroups = ["keys"];
}
