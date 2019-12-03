{ config, pkgs, ... }:
{
  boot.extraModprobeConfig = ''
    blacklist dvb_usb_rtl28xxu
  '';

  services.udev.packages = with pkgs; [
    rtl-sdr
  ];

}
