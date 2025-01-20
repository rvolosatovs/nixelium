{
  self,
  flake-utils,
  nixpkgs-nixos,
  raspberry-pi-nix,
  ...
}:
with flake-utils.lib.system;
  nixpkgs-nixos.lib.nixosSystem {
    system = aarch64-linux;
    modules = [
      ({pkgs, ...}: {
        imports = [
          raspberry-pi-nix.nixosModules.raspberry-pi
          raspberry-pi-nix.nixosModules.sd-image
          self.nixosModules.default
        ];

        #boot.kernelParams = ["console=serial0,115200" "console=tty1"];
        boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxKernel.packages.linux_rpi3;

        hardware.raspberry-pi.config.all.base-dt-params.audio.enable = true;
        hardware.raspberry-pi.config.all.base-dt-params.audio.value = "on";
        hardware.raspberry-pi.config.all.base-dt-params.krnbt.enable = true;
        hardware.raspberry-pi.config.all.base-dt-params.krnbt.value = "on";
        hardware.raspberry-pi.config.all.dt-overlays.vc4-kms-v3d.enable = true;
        hardware.raspberry-pi.config.all.options.arm_64bit.enable = true;
        hardware.raspberry-pi.config.all.options.arm_64bit.value = true;
        hardware.raspberry-pi.config.all.options.arm_boost.enable = true;
        hardware.raspberry-pi.config.all.options.arm_boost.value = true;
        hardware.raspberry-pi.config.all.options.camera_auto_detect.enable = true;
        hardware.raspberry-pi.config.all.options.camera_auto_detect.value = true;
        hardware.raspberry-pi.config.all.options.disable_fw_kms_setup.enable = true;
        hardware.raspberry-pi.config.all.options.disable_fw_kms_setup.value = true;
        hardware.raspberry-pi.config.all.options.disable_overscan.enable = true;
        hardware.raspberry-pi.config.all.options.disable_overscan.value = true;
        hardware.raspberry-pi.config.all.options.display_auto_detect.enable = true;
        hardware.raspberry-pi.config.all.options.display_auto_detect.value = true;
        hardware.raspberry-pi.config.all.options.max_framebuffers.enable = true;
        hardware.raspberry-pi.config.all.options.max_framebuffers.value = 2;
        hardware.raspberry-pi.config.cm4.options.otg_mode.enable = true;
        hardware.raspberry-pi.config.cm4.options.otg_mode.value = true;
        hardware.raspberry-pi.config.cm5.dt-overlays.dwc2.enable = true;
        hardware.raspberry-pi.config.cm5.dt-overlays.dwc2.params.dr_mode.enable = true;
        hardware.raspberry-pi.config.cm5.dt-overlays.dwc2.params.dr_mode.value = "host";

        networking.hostName = "rpi02";
        networking.interfaces.wlan0.useDHCP = true;

        raspberry-pi-nix.board = "bcm2711";
      })
    ];
  }
