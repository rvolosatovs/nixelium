{ config, pkgs, ... }:
{
  services.minidlna.enable = true;
  services.minidlna.config = ''
    enable_tivo=no
    friendly_name=neon
    inotify=yes
    model_number=AllShare1.0
    network_interface=wlp4s0
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
