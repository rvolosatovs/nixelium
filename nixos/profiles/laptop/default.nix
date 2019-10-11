{ config, pkgs, ... }:
{
  imports = [
    ./../..
    ./../../../vendor/nixos-hardware/common/pc/laptop
    ./../../boards.nix
    ./../../graphical.nix
    #./../../mopidy.nix
    #./../../virtualbox.nix
  ];

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" ];
  hardware.pulseaudio.tcp.enable = true;

  home-manager.users.${config.resources.username} = {...}: {
    imports = [
      ../../../home/profiles/laptop
      ../../../vendor/secrets/home
    ];
  };

  networking.dhcpcd.enable = false;

  networking.hosts = {
    "127.0.0.1" = [ "thethings.localhost" ];
  };
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
  networking.useNetworkd = true;
  networking.useDHCP = false;

  networking.wireless.iwd.enable = true;

  programs.adb.enable = true;

  services.printing.enable = true;
  services.resolved.enable = true;

  systemd.network.enable = true;
  systemd.network.networks."10-physical" = {
    linkConfig.RequiredForOnline = false;
    dhcpConfig.Anonymize = true;
    dhcpConfig.RouteTable = 2468;
    dhcpConfig.UseDNS = false;
    dhcpConfig.UseHostname = false;
    dhcpConfig.UseNTP = false;
    matchConfig.Name = "en* eth* wl*";
    networkConfig.DHCP = "yes";
    networkConfig.IPv6AcceptRA = true;
  };

  sound.enable = true;
  sound.mediaKeys.enable = true;

  systemd.services.audio-off.description = "Mute audio before suspend";
  systemd.services.audio-off.enable = true;
  systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
  systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
  systemd.services.audio-off.serviceConfig.Type = "oneshot";
  systemd.services.audio-off.serviceConfig.User = "${config.resources.username}";
  systemd.services.audio-off.wantedBy = [ "sleep.target" ];

  users.users.${config.resources.username}.extraGroups = [
    "adbusers"
  ];
}
