{
  self,
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"

    # Other groups
    ./common.nix
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

  fileSystems."/".device = "/dev/disk/by-label/nixos";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-label/boot";
  fileSystems."/boot".fsType = "vfat";

  hardware.cpu.intel.updateMicrocode = true;

  networking.useDHCP = true;

  swapDevices = [
    {device = "/dev/disk/by-label/swap";}
  ];
}
