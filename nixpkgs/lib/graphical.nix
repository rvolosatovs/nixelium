{ lib, config, pkgs, unstable, secrets, ... }:

{
  imports = [
    #./colors.nix
    ./gtk.nix
  ];

  home.keyboard.layout = "lv,ru";
  home.keyboard.variant = "qwerty";
  home.keyboard.options = [
    "grp:alt_space_toggle"
    "terminate:ctrl_alt_bksp"
    "eurosign:5"
    "caps:escape"
  ];

  xsession.enable = true;
  xsession.windowManager.command = ''
      export _JAVA_AWT_WM_NONREPARENTING=1

     ''${HOME}/.local/bin/turbo disable

     ${pkgs.feh}/bin/feh --bg-fill "$HOME/pictures/wp"
     ${pkgs.dunst}/bin/dunst &
     ${pkgs.networkmanagerapplet}/bin/nm-applet &
     ${pkgs.xorg.xset}/bin/xset s off -dpms
     ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
     ${pkgs.wmname}/bin/wmname LG3D

     ${pkgs.sudo}/bin/sudo ''${HOME}/.local/bin/fix-keycodes

     ${pkgs.pulseaudioFull}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
     ${pkgs.pulseaudioFull}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

     ${pkgs.xbanish}/bin/xbanish &

     SXHKD_SHELL=/bin/sh ${pkgs.sxhkd}/bin/sxhkd &
     ${pkgs.bspwm}/bin/bspwm
  '';

  programs.browserpass.enable = true;
  programs.firefox.enable = true;
  programs.firefox.enableIcedTea = true;
  programs.firefox.package = unstable.firefox;
  programs.feh.enable = true;
  services.gnome-keyring.enable = true;
  services.network-manager-applet.enable = true;
  services.redshift.enable = true;
  services.redshift.latitude = secrets.latitude;
  services.redshift.longitude = secrets.longitude;
  services.screen-locker.enable = true;
  services.screen-locker.inactiveInterval = 20;
  services.screen-locker.lockCmd = "lock -i ~/pictures/lock";

  home.packages = with pkgs; [
    #autorandr
    #electrum
    #nerdfonts
    #wireshark
    #xorg.xset
    #xorg.xsetroot
    dunst
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
    pavucontrol
    rofi
    rofi-pass
    siji
    slop
    spotify
    sxhkd
    sxiv
    symbola
    termite
    unifont
    wmname
    x11_ssh_askpass
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
    #electrum
    #electrum-ltc
    #firefox
    #spotify
    chromium
    polybar
    thunderbird
  ]);
}
