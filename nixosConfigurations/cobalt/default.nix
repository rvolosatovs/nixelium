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
    (
      { pkgs, ... }:
      {
        imports = [
          self.nixosModules.default

          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-pc-laptop-ssd
        ];

        boot.initrd.availableKernelModules = [
          "ehci_pci"
          "nvme"
          "sd_mod"
          "usb_storage"
          "xhci_pci"
        ];
        boot.initrd.kernelModules = [ "dm-snapshot" ];
        boot.initrd.luks.devices.luksroot.device = "/dev/nvme0n1p2";
        boot.kernelModules = [ "kvm-amd" ];

        networking.hostName = "cobalt";

        networking.interfaces.enp3s0f0.useDHCP = true;
        networking.interfaces.wlan0.useDHCP = true;

        nixelium.profile.dev.enable = true;
        nixelium.profile.laptop.enable = true;

        system.stateVersion = "23.11";

        virtualisation.docker.enable = true;
        virtualisation.docker.enableOnBoot = false;

        virtualisation.podman.dockerCompat = false;
        virtualisation.podman.dockerSocket.enable = false;
      }
    )
  ];
}
