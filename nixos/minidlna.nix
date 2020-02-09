{ config, pkgs, ... }:
{
  # TODO: Make this generic

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
    "P,/home/${config.resources.username}/pictures"
    "V,/home/${config.resources.username}/video"
  ];

  networking.firewall.allowedTCPPorts = [
    8200
  ];

  networking.firewall.allowedUDPPorts = [
    1900
  ];
}
