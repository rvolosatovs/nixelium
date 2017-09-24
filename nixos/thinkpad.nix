{ config, lib, ...}:

with lib;

{
  config = mkMerge [
    {
      hardware.trackpoint.emulateWheel = true;
    }
    (mkIf config.services.xserver.enable {
      services.xserver.libinput = {
        enable = true;
        scrollButton = 1;
        middleEmulation = false;
      };
    })
  ];
}
