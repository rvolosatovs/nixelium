{
  config,
  pkgs,
  lib,
  ...
}: {
  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;

  users.users.syncthing.extraGroups = ["users"];
  users.users.${config.resources.username}.extraGroups = ["syncthing"];
}
