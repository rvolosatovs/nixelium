{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./..
  ];

  config = mkMerge [
    {
      boot.extraModprobeConfig = ''
        options snd-hda-intel model=thinkpad
      '';

      environment.systemPackages = with pkgs; [
        powertop
      ];

      hardware.cpu.intel.updateMicrocode = true;

      services.thermald.enable = true;
    }

    (mkIf config.services.xserver.enable {
      hardware.opengl.extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    })
  ];
}
