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

  networking.interfaces."${wiredInterface}".useDHCP = true;
  networking.interfaces."${wirelessInterface}".useDHCP = true;

  # See https://linrunner.de/en/tlp/docs/tlp-faq.html#battery https://wiki.archlinux.org/index.php/TLP#Btrfs
  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=75
    STOP_CHARGE_THRESH_BAT0=80
    START_CHARGE_THRESH_BAT1=75
    STOP_CHARGE_THRESH_BAT1=80

    SATA_LINKPWR_ON_BAT=max_performance

    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave

    CPU_BOOST_ON_AC=1
    CPU_BOOST_ON_BAT=0
  '';
  services.xserver.videoDrivers = [ "intel" ];

  systemd.network.networks."50-wired".matchConfig.Name = wiredInterface;
  systemd.network.networks."50-wireless".matchConfig.Name = wirelessInterface;
}
