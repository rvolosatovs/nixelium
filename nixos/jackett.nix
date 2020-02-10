{ config, ... }:
{
  services.jackett.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "jackett" ];
}
