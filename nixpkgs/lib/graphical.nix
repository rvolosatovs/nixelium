{ lib, config, pkgs, unstable, secrets, ... }:

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
  programs.firefox.package = unstable.firefox;

  programs.browserpass.enable = true;
  #programs.browserpass.browsers = ["firefox" "chromium"];

  home.packages = with pkgs; [
    #autorandr
    #nerdfonts
    #xorg.xset
    #xorg.xsetroot
    dunst
    electrum
    electrum-ltc
    ffmpeg
    fira
    font-awesome-ttf
    gnome3.dconf
    gnome3.glib_networking
    i3lock-color
    imagemagick
    libnotify
    lxappearance
    maim
    mpv
    networkmanagerapplet
    rofi
    rofi-pass
    siji
    slop
    sxhkd
    sxiv
    symbola
    termite
    unifont
    wmname
    xautolock
    xclip
    xdo
    xdotool
    xsel
    xss-lock
    xtitle
    youtube-dl
    zathura
  ] ++ (with unstable; [
    chromium
    #firefox
    polybar
    spotify
    thunderbird
  ]);
}
