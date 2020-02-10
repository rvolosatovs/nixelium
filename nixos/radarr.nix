{ config, ... }:
{
  services.radarr.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "radarr" ];
}
