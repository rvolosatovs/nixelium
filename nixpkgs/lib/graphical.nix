{ lib, config, pkgs,  secrets, dotDir, ... }:

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

  home.packages = with pkgs; [
    chromium
    dunst
    ffmpeg
    font-awesome-ttf
    gnome3.dconf
    gnome3.glib_networking
    i3lock
    imagemagick
    libnotify
    lxappearance
    maim
    mpv
    networkmanagerapplet
    pavucontrol
    polybar
    rofi
    rofi-pass
    slop
    spotify
    sxhkd
    sxiv
    termite
    thunderbird
    wmname
    x11_ssh_askpass
    xautolock
    xclip
    xdo
    xdotool
    xsel
    xtitle
    youtube-dl
    zathura
  ];

  programs.browserpass.enable = true;
  programs.firefox.enable = true;
  programs.firefox.enableIcedTea = true;
  programs.feh.enable = true;

  services.dunst.enable = true;
  services.gnome-keyring.enable = true;
  services.network-manager-applet.enable = true;
  services.redshift.enable = true;
  services.redshift.latitude = secrets.latitude;
  services.redshift.longitude = secrets.longitude;
  #services.polybar.enable = true;
  #services.polybar.package = pkgs.polybar.override {
      #alsaSupport = true;
      #mpdSupport = true;
      #githubSupport = true;
  #};
  #services.polybar.config = ../../polybar/config; # TODO: migrate
  services.screen-locker.enable = true;
  services.screen-locker.inactiveInterval = 20;
  services.screen-locker.lockCmd = "${pkgs.i3lock}/bin/i3lock -t -f -i ~/pictures/lock";

  xdg.configFile."bspwm/bspwmrc".source = dotDir + "/bspwm/bspwmrc";
  xdg.configFile."mpv/config".source = dotDir + "/mpv/config";
  xdg.configFile."oomox/colors".source = dotDir + "/oomox/colors";
  xdg.configFile."polybar/config".source = dotDir + "/polybar/config";
  xdg.configFile."stalonetray/stalonetrayrc".source = dotDir + "/stalonetray/stalonetrayrc";
  xdg.configFile."sxhkd/sxhkdrc".source = dotDir + "/sxhkd/sxhkdrc";
  xdg.configFile."termite/config".source = dotDir + "/termite/config"; # TODO: use options
  xdg.configFile."themes".source = dotDir + "/themes";
  home.file.".themes".source = dotDir + "/themes";
  xdg.configFile."zathura/zathurarc".source = dotDir + "/zathura/zathurarc";

  xsession.enable = true;
  xsession.windowManager.command = ''
      export _JAVA_AWT_WM_NONREPARENTING=1

     ''${HOME}/.local/bin/turbo disable

     ${pkgs.feh}/bin/feh --bg-fill "$HOME/pictures/wp"
     ${pkgs.networkmanagerapplet}/bin/nm-applet &
     ${pkgs.xorg.xset}/bin/xset s off -dpms
     ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
     ${pkgs.wmname}/bin/wmname LG3D

     ${pkgs.sudo}/bin/sudo ''${HOME}/.local/bin/fix-keycodes

     ${pkgs.pulseaudioFull}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
     ${pkgs.pulseaudioFull}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

     ${pkgs.xbanish}/bin/xbanish &

     SXHKD_SHELL=${pkgs.bash}/bin/bash ${pkgs.sxhkd}/bin/sxhkd -m -1 &
     ${pkgs.bspwm}/bin/bspwm
  '';
}
