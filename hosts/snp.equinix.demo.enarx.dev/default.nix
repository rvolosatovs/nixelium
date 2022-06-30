{
  lib,
  pkgs,
  ...
}: {
  boot.extraModprobeConfig = "options bonding max_bonds=0";
  boot.initrd.availableKernelModules = [
    "ahci"
    "mpt3sas"
    "nvme"
    "sd_mod"
    "xhci_pci"
  ];
  boot.kernelModules = [
    "dm_multipath"
    "dm_round_robin"
    "ipmi_watchdog"
    "kvm-amd"
  ];
  boot.kernelPackages = pkgs.linuxPackages_5_18_hardened;
  boot.kernelPatches = [
    # TODO: add SNP kernel patches
  ];
  boot.kernelParams = [
    "console=ttyS1,115200n8"
  ];
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
    terminal_output serial console
    terminal_input serial console
  '';
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;

  fileSystems."/".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_214332305267-part3";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot/efi".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_214332305267-part1";
  fileSystems."/boot/efi".fsType = "vfat";

  hardware.enableAllFirmware = true;

  networking.hostId = "4a7d85ee";
  networking.interfaces.enp65s0f0.useDHCP = true;
  networking.interfaces.enp65s0f1.useDHCP = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;

  nix.maxJobs = lib.mkDefault 64;

  nixpkgs.config.allowUnfree = true;

  swapDevices = [
    {device = "/dev/disk/by-id/ata-MTFDDAV240TDU_214332305267-part2";}
  ];

  systemd.network.netdevs."10-bond0".bondConfig.DownDelaySec = 0.2;
  systemd.network.netdevs."10-bond0".bondConfig.LACPTransmitRate = "fast";
  systemd.network.netdevs."10-bond0".bondConfig.MIIMonitorSec = 0.1;
  systemd.network.netdevs."10-bond0".bondConfig.Mode = "802.3ad";
  systemd.network.netdevs."10-bond0".bondConfig.TransmitHashPolicy = "layer3+4";
  systemd.network.netdevs."10-bond0".bondConfig.UpDelaySec = 0.2;
  systemd.network.netdevs."10-bond0".netdevConfig.Kind = "bond";
  systemd.network.netdevs."10-bond0".netdevConfig.Name = "bond0";

  systemd.network.networks."30-enp65s0f0".matchConfig.Name = "enp65s0f0";
  systemd.network.networks."30-enp65s0f0".matchConfig.PermanentMACAddress = "b4:96:91:d1:f9:20";
  systemd.network.networks."30-enp65s0f0".networkConfig.Bond = "bond0";

  systemd.network.networks."30-enp65s0f1".matchConfig.Name = "enp65s0f1";
  systemd.network.networks."30-enp65s0f1".matchConfig.PermanentMACAddress = "b4:96:91:d1:f9:21";
  systemd.network.networks."30-enp65s0f1".networkConfig.Bond = "bond0";

  systemd.network.networks."40-bond0".addresses = [
    {addressConfig.Address = "147.28.141.201/31";}
    {addressConfig.Address = "2604:1380:4642:7c00::5/127";}
    {addressConfig.Address = "10.70.216.133/31";}
  ];
  systemd.network.networks."40-bond0".dns = [
    "147.75.207.207"
    "147.75.207.208"
  ];
  systemd.network.networks."40-bond0".linkConfig.MACAddress = "b4:96:91:d1:f9:20";
  systemd.network.networks."40-bond0".linkConfig.RequiredForOnline = "carrier";
  systemd.network.networks."40-bond0".matchConfig.Name = "bond0";
  systemd.network.networks."40-bond0".networkConfig.LinkLocalAddressing = "no";
  systemd.network.networks."40-bond0".routes = [
    {routeConfig.Gateway = "147.28.141.200";}
    {routeConfig.Gateway = "2604:1380:4642:7c00::4";}
    {routeConfig.Gateway = "10.70.216.132";}
  ];

  systemd.network.wait-online.anyInterface = true;
}
