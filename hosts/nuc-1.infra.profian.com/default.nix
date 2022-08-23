{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "sd_mod"
    "sdhci_pci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelPackages = pkgs.linuxPackages_enarx;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  fileSystems."/".device = "/dev/disk/by-uuid/717d3b1a-5c6d-463b-b983-8ef9236ee495";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-uuid/55E8-FE93";
  fileSystems."/boot".fsType = "vfat";

  hardware.cpu.intel.updateMicrocode = true;

  networking.useDHCP = true;

  powerManagement.cpuFreqGovernor = "powersave";

  swapDevices = [
    {device = "/dev/disk/by-uuid/4dfb994a-b4cb-4b76-8dae-8f3c497c6eff";}
  ];

  time.timeZone = "America/New_York";
}
