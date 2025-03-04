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
      ({
        config,
        pkgs,
        ...
      }: {
        imports = [
          self.nixosModules.default

          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel
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
          "msr"
        ];

        hardware.cpu.intel.updateMicrocode = true;
        hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
        ];

        networking.hostName = "osmium";

        networking.firewall.allowedTCPPorts = [
          9091
        ];

        networking.interfaces.enp34s0.useDHCP = true;
        networking.interfaces.enp34s0.wakeOnLan.enable = true;

        networking.interfaces.enp37s0.useDHCP = true;
        networking.interfaces.enp37s0.wakeOnLan.enable = true;

        networking.interfaces.wlan0.useDHCP = true;
        networking.interfaces.wlan0.wakeOnLan.enable = true;

        nixelium.build.enable = true;
        nixelium.profile.laptop.enable = true;

        services.jellyfin.enable = true;
        services.jellyfin.openFirewall = true;

        services.radarr.enable = true;
        services.radarr.openFirewall = true;

        services.sonarr.enable = true;
        services.sonarr.openFirewall = true;

        services.transmission.enable = true;
        services.transmission.openFirewall = true;
        services.transmission.openRPCPort = true;
        services.transmission.performanceNetParameters = true;

        systemd.services.system76-charge-thresholds.after = ["multi-user.target"];
        systemd.services.system76-charge-thresholds.description = "Set system76 laptop battery charge thresholds";
        systemd.services.system76-charge-thresholds.script = "${config.boot.kernelPackages.system76-power}/bin/system76-power charge-thresholds --profile max_lifespan";
        systemd.services.system76-charge-thresholds.wantedBy = ["multi-user.target"];

        users.users.owner.extraGroups = [
          config.users.groups.jellyfin.name
          config.users.groups.radarr.name
          config.users.groups.sonarr.name
          config.users.groups.transmission.name
        ];
      })
    ];
  }
