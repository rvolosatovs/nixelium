{ lib, pkgs, config, ... }:

{
  imports = [ ./efi.nix ];
  config = lib.mkMerge [
    {

      boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call wireguard ];

      boot.extraModprobeConfig = ''
        options thinkpad_acpi force-load=1
        options snd-hda-intel model=thinkpad
      '';


      hardware.bluetooth.enable = true;
      hardware.pulseaudio.enable = true;
      hardware.pulseaudio.package = pkgs.pulseaudioFull;

      services.acpid.enable = true;
      services.fprintd.enable = true;
      services.thermald.enable = true;
      services.upower.enable = true;

      services.tlp.enable = true;
      services.tlp.extraConfig = ''
        SATA_LINKPWR_ON_BAT=max_performance

        # Battery health
        START_CHARGE_THRESH_BAT0=75
        STOP_CHARGE_THRESH_BAT0=90
        START_CHARGE_THRESH_BAT1=75
        STOP_CHARGE_THRESH_BAT1=90
      '';
    }

    (lib.mkIf config.services.xserver.enable {
      hardware.trackpoint.enable = true;
      hardware.trackpoint.sensitivity = 220;
      hardware.trackpoint.speed = 0;
      hardware.trackpoint.emulateWheel = true;

      services.xserver.libinput.enable = true;
      services.xserver.libinput.scrollButton = 1;
      services.xserver.libinput.middleEmulation = false;

      hardware.opengl.enable = true;
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
    })
  ];
}
