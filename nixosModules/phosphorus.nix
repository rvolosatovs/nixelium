{
  self,
  nixlib,
  ...
}: {...}: {
  boot.initrd.availableKernelModules = [
    "virtiofs"
    "xhci_pci"
  ];

  networking.hostName = "phosphorus";

  #nixelium.profile.laptop.enable = true;
  nixelium.system.isVirtual = true;

  virtualisation.spiceUSBRedirection.enable = true;
}
