{ lib, config, pkgs, secrets, ... }:

{
  imports = [
    #./colors.nix
    ./gtk.nix
  ];

  xsession.enable = true;
  xsession.windowManager.command = ''
    export _JAVA_AWT_WM_NONREPARENTING=1
    SXHKD_SHELL=/bin/sh ${pkgs.sxhkd}/bin/sxhkd &
    ${pkgs.bspwm}/bin/bspwm
    '';

  services.redshift.enable = true;
  services.redshift.latitude = secrets.latitude;
  services.redshift.longitude = secrets.longitude;
  services.network-manager-applet.enable = true;
  services.screen-locker.enable = true;
  services.screen-locker.lockCmd = "lock -s -p";

  programs.firefox.enable = true;
  #programs.chromium.enable = true;
}
