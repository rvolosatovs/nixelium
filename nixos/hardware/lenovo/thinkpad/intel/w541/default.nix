{ ... }:

{
  imports = [ 
    ./.. 
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
  ];
  boot.kernelModules = [
    "acpi_call"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
