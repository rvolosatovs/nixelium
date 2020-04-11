{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../.
    ../../efi.nix
  ];

  config = mkMerge [
    {
      boot.extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
      ];

      boot.extraModprobeConfig = ''
        options thinkpad_acpi force-load=1
      '';
      boot.kernelModules = [
        "acpi_call"
      ];

      environment.systemPackages = with config.boot.kernelPackages; [
        acpi_call
      ];

      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;

      #security.polkit.extraConfig = ''
      #  /* https://wiki.archlinux.org/index.php/Fprint#Restrict_enrolling */
      #  polkit.addRule(function (action, subject) {
      #    if (action.id == "net.reactivated.fprint.device.enroll") {
      #      return subject.user == "root" ? polkit.Result.YES : polkit.result.NO
      #    }
      #  })
      #'';

      services.acpid.enable = true;
      #services.fprintd.enable = true;
      services.upower.enable = true;
    }

    (mkIf config.services.xserver.enable {
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.enable = true;

      hardware.trackpoint.emulateWheel = true;
      hardware.trackpoint.enable = true;
      hardware.trackpoint.sensitivity = 250;
      hardware.trackpoint.speed = 120;

      services.xserver.libinput.enable = true;
      services.xserver.libinput.middleEmulation = false;
      services.xserver.libinput.scrollButton = 1;
      services.xserver.xkbModel = "thinkpad60";
    })
  ];
}
