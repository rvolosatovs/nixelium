{ config, pkgs, ... }:
{
  # TODO: Make this generic

  services.minidlna.enable = true;
  services.minidlna.config = ''
    friendly_name=neon
    inotify=yes
    notify_interval=900
    serial=
    strict_dlna=no
  '';
  services.minidlna.mediaDirs = [
    "V,/var/lib/minidlna/video"
  ];

  networking.firewall.allowedTCPPorts = [
    8200
  ];

  networking.firewall.allowedUDPPorts = [
    1900
  ];
}
