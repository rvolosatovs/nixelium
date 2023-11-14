{
  self,
  flake-utils,
  nixos-hardware,
  nixpkgs-nixos,
  ...
}:
with flake-utils.lib.system;
  nixpkgs-nixos.lib.nixosSystem {
    system = x86_64-linux;
    modules = [
      self.nixosModules.default

      nixos-hardware.nixosModules.common-cpu-intel
      nixos-hardware.nixosModules.common-pc-laptop-ssd
      nixos-hardware.nixosModules.system76
      ({
        config,
        pkgs,
        ...
      }: {
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
          "msr"
        ];

        hardware.cpu.intel.updateMicrocode = true;

        networking.hostName = "osmium";

        networking.interfaces.enp34s0.useDHCP = true;
        networking.interfaces.enp34s0.wakeOnLan.enable = true;

        networking.interfaces.enp37s0.useDHCP = true;
        networking.interfaces.enp37s0.wakeOnLan.enable = true;

        networking.interfaces.wlan0.useDHCP = true;
        networking.interfaces.wlan0.wakeOnLan.enable = true;

        systemd.services.system76-charge-thresholds.after = ["multi-user.target"];
        systemd.services.system76-charge-thresholds.description = "Set system76 laptop battery charge thresholds";
        systemd.services.system76-charge-thresholds.script = "${config.boot.kernelPackages.system76-power}/bin/system76-power charge-thresholds --profile balanced";
        systemd.services.system76-charge-thresholds.wantedBy = ["multi-user.target"];

        nixelium.build.enable = true;
        nixelium.profile.laptop.enable = true;
      })
    ];
  }
