{ config, pkgs, lib, ... }:
let
  mountOpts = [ "ssd" "noatime" "autodefrag" "compress=zstd" ];
in
  {
    imports = [
      ./../../../resources/hosts/neon
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/neon
      ./../../../vendor/secrets/resources/hosts/neon
      ./../../btrfs.nix
      ./../../deluge.nix
      ./../../hardware/lenovo/thinkpad/intel/x260
      ./../../jackett.nix
      ./../../lan.nix
      ./../../lidarr.nix
      ./../../minidlna.nix
      ./../../profiles/server
      ./../../radarr.nix
      ./../../sonarr.nix
      ./../../syncthing.nix
      ./hardware-configuration.nix
    ];

    config = {
      boot.initrd.luks.devices = [
        {
          name="luksroot";
          device="/dev/sda2";
          preLVM=true;
          allowDiscards=true;
        }
      ];

      home-manager.users.${config.resources.username} = {...}: import ./../../../home/hosts/neon;

      networking.dhcpcd.enable = false;

      networking.firewall.allowedTCPPorts = [
        1885
        8384 # syncthing GUI
        8885
      ];
      networking.firewall.allowedUDPPorts = [
        1700
      ];

      networking.hostName = "neon";

      networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
      networking.useNetworkd = true;
      networking.useDHCP = false;

      services.jackett.openFirewall = true;
      services.lidarr.openFirewall = true;
      services.radarr.openFirewall = true;
      services.sonarr.openFirewall = true;

      services.minidlna.mediaDirs = [
        "A,/var/lib/lidarr/music"
        "V,/var/lib/radarr/movies"
        "V,/var/lib/sonarr/TV"
      ];

      services.resolved.enable = true;

      # TODO: Configure syncthing /var/lib/deluge/completed sync from oxygen

      services.wakeonlan.interfaces = [{
        interface = "eth0";
        method = "magicpacket";
      }];

      systemd.network.enable = true;
      systemd.network.networks."10-physical" = {
        linkConfig.RequiredForOnline = false;
        dhcpConfig.Anonymize = true;
        dhcpConfig.RouteTable = 2468;
        dhcpConfig.UseDNS = false;
        dhcpConfig.UseHostname = false;
        dhcpConfig.UseNTP = false;
        matchConfig.Name = "eth0 wlan0";
        networkConfig.DHCP = "yes";
        networkConfig.IPv6AcceptRA = true;
      };
      systemd.network.networks."50-wireless".enable = false;

      users.users.radarr.extraGroups = [
        "deluge"
        "syncthing"
      ];
      users.users.minidlna.extraGroups = [
        "deluge"
        "radarr"
        "sonarr"
        "syncthing"
      ];
      users.users.sonarr.extraGroups = [
        "deluge"
        "syncthing"
      ];
    };
  }
