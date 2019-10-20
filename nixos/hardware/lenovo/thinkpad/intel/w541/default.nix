{ ... }:

{
  imports = [ 
    ./.. 
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
