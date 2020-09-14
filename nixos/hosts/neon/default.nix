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
      ./../../deluge.nix
      ./../../hardware/lenovo/thinkpad/intel/x260
      ./../../jackett.nix
      ./../../lan.nix
      ./../../lidarr.nix
      ./../../minidlna.nix
      ./../../quake3.server.nix
      ./../../miniflux.nix
      ./../../profiles/server
      ./../../radarr.nix
      ./../../sonarr.nix
      ./../../syncthing.nix
      ./hardware-configuration.nix
    ];

    config = {
      boot.initrd.luks.devices.luksroot.device="/dev/sda2";
      boot.initrd.luks.devices.luksroot.preLVM=true;
      boot.initrd.luks.devices.luksroot.allowDiscards=true;

      boot.initrd.network.ssh.hostRSAKey = "/etc/secrets/initrd/ssh_host_rsa_key";

      home-manager.users.${config.resources.username} = import ./../../../home/hosts/neon;

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

      networking.mullvad.enable = true;
      networking.mullvad.client.privateKey = builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/wg.mullvad.private;

      networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
      networking.useNetworkd = true;
      networking.useDHCP = false;

      services.borgbackup.repos.home.path = "/var/lib/borgbackup/home";
      services.borgbackup.repos.home.authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7bHvo7Fen2ZkdcCoZKztgkWcPIOfuckbv5Lon/aBi5"
      ];
      services.borgbackup.repos.root.path = "/var/lib/borgbackup/root";
      services.borgbackup.repos.root.authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMo5GlPNjHac6q4k9F0t50OoefQ7McxAd1UXndtVCcg"
      ];

      services.btrfs.butter.uuid = "95f03ff6-b94c-4a7b-b122-9ef73507e26b";

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
        interface = "enp0s31f6";
        method = "magicpacket";
      }];

      systemd.network.enable = true;
      systemd.network.networks."10-physical".dhcpConfig.Anonymize = true;
      systemd.network.networks."10-physical".dhcpConfig.RouteTable = 2;
      systemd.network.networks."10-physical".dhcpConfig.UseDNS = false;
      systemd.network.networks."10-physical".dhcpConfig.UseHostname = false;
      systemd.network.networks."10-physical".dhcpConfig.UseNTP = false;
      systemd.network.networks."10-physical".linkConfig.RequiredForOnline = false;
      systemd.network.networks."10-physical".matchConfig.Name = "enp0s31f6";
      systemd.network.networks."10-physical".networkConfig.DHCP = "yes";
      systemd.network.networks."10-physical".networkConfig.IPv6AcceptRA = true;
      systemd.network.networks."10-physical".extraConfig = ''
        [RoutingPolicyRule]
        FirewallMark=2
        Table=2
      '';
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
