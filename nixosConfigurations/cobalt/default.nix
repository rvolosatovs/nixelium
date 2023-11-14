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

      nixos-hardware.nixosModules.common-cpu-amd
      nixos-hardware.nixosModules.common-pc-laptop-ssd
      ({pkgs, ...}: {
        boot.initrd.availableKernelModules = [
          "ehci_pci"
          "nvme"
          "sd_mod"
          "usb_storage"
          "xhci_pci"
        ];
        boot.initrd.kernelModules = [
          "dm-snapshot"
        ];
        boot.initrd.luks.devices.luksroot.device = "/dev/nvme0n1p2";
        boot.kernelModules = [
          "kvm-amd"
        ];

        networking.hostName = "cobalt";

        networking.interfaces.enp3s0f0.useDHCP = true;
        networking.interfaces.wlan0.useDHCP = true;

        nixelium.profile.laptop.enable = true;

        nix.buildMachines = [
          {
            hostName = "osmium.ghost-ordinal.ts.net";
            maxJobs = 8;
            speedFactor = 2;
            sshKey = "/root/.ssh/id_osmium_nix";
            sshUser = "nix";
            supportedFeatures = [
              "benchmark"
              "big-parallel"
              "kvm"
              "nixos-test"
            ];
            systems = [
              "aarch64-linux"
              "x86_64-linux"
            ];
          }
          {
            hostName = "iridium.ghost-ordinal.ts.net";
            maxJobs = 12;
            speedFactor = 2;
            sshKey = "/root/.ssh/id_iridium_nix";
            sshUser = "nix";
            systems = [
              "aarch64-darwin"
              "x86_64-darwin"
            ];
          }
        ];
        nix.distributedBuilds = true;

        virtualisation.docker.enable = true;
        virtualisation.docker.enableOnBoot = false;

        virtualisation.podman.dockerCompat = false;
        virtualisation.podman.dockerSocket.enable = false;
      })
    ];
  }
