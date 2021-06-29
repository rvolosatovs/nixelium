{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./..
  ];

  config = mkMerge [
    {
      boot.kernelModules = [
        "amdgpu"
      ];

      hardware.cpu.amd.updateMicrocode = true;
    }

    (mkIf config.resources.graphics.enable {
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];

      hardware.opengl.extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];

      services.xserver.videoDrivers = [
        "amdgpu"
      ];
    })
  ];
}
