{ config, pkgs, lib, ... }:
let
  wiredInterface = if config.networking.usePredictableInterfaceNames then "enp0s31f6" else "eth0";
  wirelessInterface = "wlan0";
in
{
  imports = [
    ./..
    ./../../../../../../vendor/nixos-hardware/lenovo/thinkpad/x260
  ];

  boot.initrd.availableKernelModules = [
    "iwlwifi"
    "e1000e"
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_4_14;
  boot.kernelParams = [ "i915.fastboot=1" ];

  networking.interfaces."${wiredInterface}".useDHCP = lib.mkDefault true;
  # TODO: Find a way to disable this per-host. An option maybe?
  #networking.interfaces."${wirelessInterface}".useDHCP = lib.mkDefault true;

  # See https://linrunner.de/en/tlp/docs/tlp-faq.html#battery https://wiki.archlinux.org/index.php/TLP#Btrfs
  services.tlp.settings.CPU_BOOST_ON_AC = 1;
  services.tlp.settings.CPU_BOOST_ON_BAT = 0;
  services.tlp.settings.CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  services.tlp.settings.ENERGY_PERF_POLICY_ON_BAT = "powersave";
  services.tlp.settings.START_CHARGE_THRESH_BAT0 = 75;
  services.tlp.settings.START_CHARGE_THRESH_BAT1 = 75;
  services.tlp.settings.STOP_CHARGE_THRESH_BAT0 = 80;
  services.tlp.settings.STOP_CHARGE_THRESH_BAT1 = 80;

  services.xserver.videoDrivers = [ "intel" ];

  systemd.network.networks."50-wired".matchConfig.Name = wiredInterface;
  # TODO: Find a way to disable this per-host. An option maybe?
  #systemd.network.networks."50-wireless".matchConfig.Name = wirelessInterface;
}
