{ config, ... }:
{
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];

  users.users.${config.meta.username}.extraGroups = [
    "vboxusers"
  ];

  virtualisation.virtualbox.host.enable = true;

}
