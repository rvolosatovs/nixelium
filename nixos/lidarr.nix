{ config, ... }:
{
  services.lidarr.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "lidarr" ];
}
