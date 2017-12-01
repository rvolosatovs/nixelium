{ pkgs, config, ... }:

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
}
