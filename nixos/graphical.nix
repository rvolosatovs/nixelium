{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    GTK_PATH = "${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true";
  };
  environment.systemPackages = with pkgs; [
    lxqt.lxqt-openssh-askpass
  ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    comic-relief
    fira
    furaCode
    roboto-slab
    siji
    symbola
    terminus_font
    unifont
  ];
  fonts.fontconfig.allowBitmaps = true;
  fonts.fontconfig.allowType1 = false;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [ "FuraCode Nerd Font" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Fira Sans" ];
  fonts.fontconfig.defaultFonts.serif = [ "Roboto Slab" ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.hinting.enable = true;

  programs.chromium.homepageLocation = "https://duckduckgo.com/?key=${config.resources.duckduckgo.key}";
  programs.chromium.extensions = [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
    "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
    "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
    "hlepfoohegkhhmjieoechaddaejaokhf" # refined github
    "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
    "naepdomgkenhinolocfifgehidddafch" # browserpass-ce
    "ognfafcpbkogffpmmdglhbjboeojlefj" # keybase
  ];
  programs.light.enable = true;
  programs.qt5ct.enable = true;
  programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";

  #programs.sway.enable = true;
  #users.users."${config.resources.username}".extraGroups = [ "sway" ];

  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = config.resources.username;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.name = "Zukitre";
  services.xserver.displayManager.lightdm.greeters.gtk.theme.package = pkgs.zuki-themes;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.default = "bspwm";

  services.xserver.layout = config.home-manager.users.${config.resources.username}.home.keyboard.layout;
  services.xserver.xkbOptions = lib.concatStringsSep ", " config.home-manager.users.${config.resources.username}.home.keyboard.options;
  services.xserver.xkbVariant = config.home-manager.users.${config.resources.username}.home.keyboard.variant;
}
