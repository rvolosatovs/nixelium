{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./..
  ];

  config = mkMerge [
    {
      hardware.cpu.amd.updateMicrocode = true;
    }

    (mkIf config.resources.graphics.enable {
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
      ];

      services.xserver.videoDrivers = [
        "amdgpu"
      ];
    })
  ];
}
