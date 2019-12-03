{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in
  {
    imports = [
      ./../../../resources/hosts/neon
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/neon
      ./../../../vendor/secrets/resources/hosts/neon
      ./../../hardware/lenovo/thinkpad/intel/x260
      ./../../minidlna.nix
      ./../../profiles/server
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

      fileSystems."/".options = mountOpts;
      fileSystems."/home".options = mountOpts;

      home-manager.users.${config.resources.username} = {...}: {
        imports = [
          ./../../../home/hosts/neon
        ];
      };

      networking.dhcpcd.enable = false;

      networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
      networking.useNetworkd = true;
      networking.useDHCP = false;

      networking.hostName = "neon";
      networking.firewall.allowedTCPPorts = [
        1885
        8885
      ];
      networking.firewall.allowedUDPPorts = [
        1700
      ];

      services.resolved.enable = true;
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
    };
  }
