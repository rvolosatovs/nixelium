{ config, ... }:
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 1;

  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall.allowedUDPPorts = [
    config.resources.wireguard.port
  ];

  networking.wireguard.interfaces.wg0.listenPort = config.resources.wireguard.port;
  networking.wireguard.interfaces.wg0.ips = [ "10.0.0.1/24" ];
}
