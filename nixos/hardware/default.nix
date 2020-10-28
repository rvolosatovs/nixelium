{
  hardware.enableRedistributableFirmware = true;

  systemd.network.networks."50-wired".dhcpV4Config.RouteMetric = 512;
  systemd.network.networks."50-wireless".dhcpV4Config.RouteMetric = 1024;
}
