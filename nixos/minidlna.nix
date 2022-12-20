{
  config,
  pkgs,
  ...
}: {
  # TODO: Make this generic

  networking.firewall.allowedTCPPorts = [
    8200
  ];

  networking.firewall.allowedUDPPorts = [
    1900
  ];

  services.minidlna.enable = true;
  services.minidlna.settings.friendly_name = "${config.networking.hostName}-dlna";
  services.minidlna.settings.inotify = "yes";
  services.minidlna.settings.network_interface = "enp0s31f6,enp3s0f0,eth0,wlan0";
  services.minidlna.settings.notify_interval = 900;
  services.minidlna.settings.serial = "";
  services.minidlna.settings.strict_dlna = "no";
  services.minidlna.mediaDirs = [
    "A,/var/lib/minidlna/audio"
    "P,/var/lib/minidlna/pictures"
    "V,/var/lib/minidlna/video"
  ];

  users.users.${config.resources.username}.extraGroups = [
    "minidlna"
  ];
}
