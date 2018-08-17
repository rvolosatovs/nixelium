{
  imports = [ 
    ./..
    ./../../../../../vendor/nixos-hardware/lenovo/thinkpad/x260
  ];

  boot.kernelParams = [ "i915.fastboot=1" ];

  services.xserver.videoDrivers = [ "intel" ];
}
