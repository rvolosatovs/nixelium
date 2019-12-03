{
  hardware.enableRedistributableFirmware = true;

  systemd.network.networks."50-wired".dhcpConfig.RouteMetric = "512";
  systemd.network.networks."50-wireless".dhcpConfig.RouteMetric = "1024";
}
