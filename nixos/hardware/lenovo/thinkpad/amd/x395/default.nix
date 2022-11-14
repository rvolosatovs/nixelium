{
  pkgs,
  lib,
  ...
}: let
  wiredInterface = "enp3s0f0";
  wirelessInterface = "wlan0";
in {
  imports = [./.. ./../../../../../../vendor/nixos-hardware/lenovo/thinkpad/x395];

  boot.kernelParams = [
    "acpi_osi=Linux"
    "idle=nomwait"
    "iommu=soft"
  ];

  networking.interfaces."${wiredInterface}".useDHCP = true;
  networking.interfaces."${wirelessInterface}".useDHCP = true;

  # Related:
  # - https://linrunner.de/en/tlp/docs/tlp-faq.html#battery
  # - https://wiki.archlinux.org/index.php/TLP#Btrfs
  # - https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X395
  services.tlp.settings.CPU_BOOST_ON_AC = 1;
  services.tlp.settings.CPU_BOOST_ON_BAT = 0;
  services.tlp.settings.CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  services.tlp.settings.ENERGY_PERF_POLICY_ON_BAT = "powersave";
  services.tlp.settings.RUNTIME_PM_BLACKLIST = "05:00.3";
  services.tlp.settings.SATA_LINKPWR_ON_BAT = "max_performance";
  services.tlp.settings.START_CHARGE_THRESH_BAT0 = 75;
  services.tlp.settings.STOP_CHARGE_THRESH_BAT0 = 80;
  services.tlp.settings.USB_AUTOSUSPEND = 0;
}
