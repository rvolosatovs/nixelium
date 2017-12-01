{ ... }:

{
  imports = [ ./lenovo.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" ];

  powerManagement.scsiLinkPolicy = "max_performance";

  services.thinkfan.sensor = "/sys/class/hwmon/hwmon0/temp1_input";

  services.xserver.xkbModel = "thinkpad60";
}
