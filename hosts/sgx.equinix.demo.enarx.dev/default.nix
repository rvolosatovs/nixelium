{
  lib,
  pkgs,
  ...
}: {
  boot.extraModprobeConfig = "options bonding max_bonds=0";
  boot.initrd.availableKernelModules = [
    "ahci"
    "megaraid_sas"
    "sd_mod"
    "xhci_pci"
  ];
  boot.kernelModules = [
    "dm_multipath"
    "dm_round_robin"
    "ipmi_watchdog"
    "kvm-intel"
  ];
  boot.kernelPackages = pkgs.linuxPackages_5_18_hardened;
  boot.kernelPatches = [
    # TODO: add SGX kernel patches
  ];
  boot.kernelParams = [
    "console=ttyS1,115200n8"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;

  fileSystems."/".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_220133CB3E88-part3";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot/efi".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_220133CB3E88-part1";
  fileSystems."/boot/efi".fsType = "vfat";

  hardware.enableAllFirmware = true;

  networking.hostId = "395c78d1";
  networking.interfaces.eno12399.useDHCP = true;
  networking.interfaces.eno12409.useDHCP = true;
  networking.interfaces.eno12419.useDHCP = true;
  networking.interfaces.eno12429.useDHCP = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;

  nix.maxJobs = lib.mkDefault 128;

  nixpkgs.config.allowUnfree = true;

  swapDevices = [
    {device = "/dev/disk/by-id/ata-MTFDDAV240TDU_220133CB3E88-part2";}
  ];

  systemd.network.netdevs."10-bond0".bondConfig.DownDelaySec = 0.2;
  systemd.network.netdevs."10-bond0".bondConfig.LACPTransmitRate = "fast";
  systemd.network.netdevs."10-bond0".bondConfig.MIIMonitorSec = 0.1;
  systemd.network.netdevs."10-bond0".bondConfig.Mode = "802.3ad";
  systemd.network.netdevs."10-bond0".bondConfig.TransmitHashPolicy = "layer3+4";
  systemd.network.netdevs."10-bond0".bondConfig.UpDelaySec = 0.2;
  systemd.network.netdevs."10-bond0".netdevConfig.Kind = "bond";
  systemd.network.netdevs."10-bond0".netdevConfig.Name = "bond0";

  systemd.network.networks."30-eno12399".matchConfig.Name = "eno12399";
  systemd.network.networks."30-eno12399".matchConfig.PermanentMACAddress = "40:a6:b7:6b:48:e8";
  systemd.network.networks."30-eno12399".networkConfig.Bond = "bond0";

  systemd.network.networks."30-eno12419".matchConfig.Name = "eno12419";
  systemd.network.networks."30-eno12419".matchConfig.PermanentMACAddress = "40:a6:b7:6b:48:ea";
  systemd.network.networks."30-eno12419".networkConfig.Bond = "bond0";

  systemd.network.networks."40-bond0".addresses = [
    {addressConfig.Address = "147.28.146.139/31";}
    {addressConfig.Address = "2604:1380:45f1:4800::3/127";}
    {addressConfig.Address = "10.68.40.3/31";}
  ];
  systemd.network.networks."40-bond0".dns = [
    "147.75.207.207"
    "147.75.207.208"
  ];
  systemd.network.networks."40-bond0".linkConfig.MACAddress = "40:a6:b7:6b:48:e8";
  systemd.network.networks."40-bond0".linkConfig.RequiredForOnline = "carrier";
  systemd.network.networks."40-bond0".matchConfig.Name = "bond0";
  systemd.network.networks."40-bond0".networkConfig.LinkLocalAddressing = "no";
  systemd.network.networks."40-bond0".routes = [
    {routeConfig.Gateway = "147.28.146.138";}
    {routeConfig.Gateway = "2604:1380:45f1:4800::2";}
    {routeConfig.Gateway = "10.68.40.2";}
  ];

  systemd.network.wait-online.anyInterface = true;
}
