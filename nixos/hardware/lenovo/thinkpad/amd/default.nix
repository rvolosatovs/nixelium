{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./..
  ];

  config = mkMerge [
    {
      hardware.cpu.amd.updateMicrocode = true;

      environment.sessionVariables.RADV_PERFTEST="aco";
    }

    (mkIf config.resources.graphics.enable {
      services.xserver.videoDrivers = [
        "amdgpu"
      ];
    })
  ];
}
