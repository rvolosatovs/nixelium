{ config, pkgs, lib, secrets, vars, unstable, ... }:

{
  #environment.sessionVariables.QT_QPA_PLATFORMTHEME = "gtk2";
  environment.sessionVariables."_JAVA_OPTIONS" = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true";
  environment.sessionVariables.GTK_PATH = "${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0";

  environment.systemPackages = with pkgs; [
    termite
  ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    dejavu_fonts
    fira
    fira-mono
    font-awesome-ttf
    roboto-slab
    symbola
    terminus_font
  ];
  fonts.fontconfig.allowBitmaps = true;
  fonts.fontconfig.allowType1 = false;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Hurmit Nerd Font" "Fira Sans Mono" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Fira Sans" ];
  fonts.fontconfig.defaultFonts.serif = [ "Roboto Slab" ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.hinting.enable = true;

  programs.chromium.enable = true;
  programs.chromium.homepageLocation = "https://duckduckgo.com/?key=${secrets.duckduckgo.key}";
  programs.chromium.extensions = [
    "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
    "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
    "naepdomgkenhinolocfifgehidddafch" # browserpass-ce
    "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
    "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    "gieohaicffldbmiilohhggbidhephnjj" # vanilla cookie manager
  ];
  programs.light.enable = true;
  programs.qt5ct.enable = true;
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  services.gnome3.gnome-keyring.enable = true;
  services.gnome3.seahorse.enable = true;
  services.kbfs.enable = true;
  services.keybase.enable = true;
  services.printing.enable = true;
  services.redshift.enable = true;
  services.redshift.latitude = secrets.latitude;
  services.redshift.longitude = secrets.longitude;
  services.xbanish.enable = true;
  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = vars.username;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.package = pkgs.zuki-themes;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.name = "Zukitre";
  services.xserver.displayManager.sessionCommands = ''
     #eval `${pkgs.keychain}/bin/keychain --eval id_rsa ttn`
     #eval `${pkgs.keychain}/bin/keychain --eval --agents gpg`
     #eval `${pkgs.keychain}/bin/keychain --eval --agents ssh`

     ${config.hardware.pulseaudio.package}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
     ${config.hardware.pulseaudio.package}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

     #${pkgs.feh}/bin/feh  --bg-fill "$HOME/pictures/wp"
     ##${pkgs.stalonetray}/bin/stalonetray -c "''${XDG_CONFIG_HOME}/stalonetray/stalonetrayrc" &
     #${pkgs.dunst}/bin/dunst &
     #${pkgs.networkmanagerapplet}/bin/nm-applet &
     #${pkgs.xorg.xset}/bin/xset s off -dpms
     #${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
     #${pkgs.wmname}/bin/wmname LG3D

     #${pkgs.sudo}/bin/sudo ''${HOME}/.local/bin/fix-keycodes

     #''${HOME}/.local/bin/turbo disable

     ## Screen Locking (time-based & on suspend)
     #${pkgs.xautolock}/bin/xautolock -detectsleep -time 5 \
     #-locker "/home/${vars.username}/.local/bin/lock -s -p" \
     #-notify 10 -notifier "${pkgs.libnotify}/bin/notify-send -u critical -t 10000 -- 'Screen will be locked in 10 seconds'" &
     #${pkgs.xss-lock}/bin/xss-lock -- /home/${vars.username}/.local/bin/lock -s -p &
  '';
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "lv,ru";
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.default = "bspwm";
  #services.xserver.xautolock.enable = true;
  #services.xserver.xautolock.locker = "/home/${vars.username}/.local/bin/lock -s -p";
  services.xserver.xkbOptions = "grp:alt_space_toggle,terminate:ctrl_alt_bksp,eurosign:5,caps:escape";
  services.xserver.xkbVariant = "qwerty";
}
