{ pkgs, lib, ... }:
let
  wiredInterface = "enp3s0f0";
  wirelessInterface = "wlan0";
in
{
  imports = [ 
    ./..
    ./../../../../../../vendor/nixos-hardware/lenovo/thinkpad/x395
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_5_5;
  boot.kernelParams = [
    "acpi_backlight=vendor"
    "acpi_osi=Linux"
    "idle=nomwait"
  ];

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

    USB_AUTOSUSPEND=0
  '';

  systemd.network.networks."50-wired".matchConfig.Name = wiredInterface;
  systemd.network.networks."50-wireless".matchConfig.Name = wirelessInterface;
}
