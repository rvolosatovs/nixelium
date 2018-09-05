{ config, ... }:
{
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];

  users.users.${config.resources.username}.extraGroups = [
    "vboxusers"
  ];

  virtualisation.virtualbox.host.enable = true;

}
