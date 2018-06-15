{ ... }:

{
  imports = [ ./lenovo.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" ];
  boot.kernelParams = [ "i915.fastboot=1" ];

  services.thinkfan.sensor = "/sys/class/hwmon/hwmon0/temp1_input";

  services.xserver.xkbModel = "thinkpad60";
  services.xserver.videoDrivers = [ "intel" ];
}
