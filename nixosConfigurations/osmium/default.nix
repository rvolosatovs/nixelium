{
  self,
  flake-utils,
  nixos-hardware,
  nixpkgs,
  ...
}:
with flake-utils.lib.system;
  nixpkgs.lib.nixosSystem {
    system = x86_64-linux;
    modules = [
      ({pkgs, ...}: {
        imports = [
          self.nixosModules.default

          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.system76
        ];

        boot.initrd.availableKernelModules = [
          "nvme"
          "rtsx_pci_sdmmc"
          "sd_mod"
          "usb_storage"
          "usbhid"
          "xhci_pci"
        ];
        boot.initrd.kernelModules = [
          "dm-snapshot"
        ];
        boot.initrd.luks.devices.luksroot.device = "/dev/nvme0n1p2";
        boot.kernelModules = [
          "kvm-intel"
        ];

        hardware.cpu.intel.updateMicrocode = true;

        networking.hostName = "osmium";

        networking.interfaces.enp34s0.useDHCP = true;
        networking.interfaces.enp37s0.useDHCP = true;
        networking.interfaces.wlan0.useDHCP = true;

        nixelium.profile.laptop.enable = true;
      })
    ];
  }
