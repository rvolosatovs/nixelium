{ pkgs, ... }:
let
  wiredInterface = "enp3s0f0";
  wirelessInterface = "wlan0";
in
{
  imports = [ 
    ./..
    ./../../../../../../vendor/nixos-hardware/lenovo/thinkpad/x395
  ];

  boot.kernelPackages = pkgs.linuxPackages_5_3;
  boot.kernelParams = [ "acpi_backlight=vendor" ];

  networking.interfaces."${wiredInterface}".useDHCP = true;
  networking.interfaces."${wirelessInterface}".useDHCP = true;

  # See https://linrunner.de/en/tlp/docs/tlp-faq.html#battery https://wiki.archlinux.org/index.php/TLP#Btrfs
  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=75
    STOP_CHARGE_THRESH_BAT0=80

    SATA_LINKPWR_ON_BAT=max_performance

    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave

    CPU_BOOST_ON_AC=1
    CPU_BOOST_ON_BAT=0
  '';

  services.thermald.enable = false;

  systemd.network.networks."20-wired" = {
    dhcpConfig.RouteMetric = "10";
    matchConfig.Name = wiredInterface;
  };
  systemd.network.networks."25-wireless" = {
    dhcpConfig.RouteMetric = "20";
    matchConfig.Name = wirelessInterface;
  };
}