{ config, ... }:
{
  services.sonarr.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "sonarr" ];
}
