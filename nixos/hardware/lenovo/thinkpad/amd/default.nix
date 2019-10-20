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

    (mkIf config.services.xserver.enable {
      services.xserver.videoDrivers = [
        "amdgpu"
      ];
    })
  ];
}
