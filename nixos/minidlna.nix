{ config, pkgs, ... }:
{
  # TODO: Make this generic

  networking.firewall.allowedTCPPorts = [
    8200
  ];

  networking.firewall.allowedUDPPorts = [
    1900
  ];

  services.minidlna.enable = true;
  services.minidlna.config = ''
    friendly_name=${config.networking.hostName}-dlna
    inotify=yes
    network_interface=enp3s0f0,eth0,wlan0
    notify_interval=900
    serial=
    strict_dlna=no
  '';
  services.minidlna.mediaDirs = [
    "A,/var/lib/minidlna/audio"
    "P,/var/lib/minidlna/pictures"
    "V,/var/lib/minidlna/video"
  ];

  users.users.${config.resources.username}.extraGroups = [
    "minidlna"
  ];
}
