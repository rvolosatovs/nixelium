{ config, pkgs, lib, secrets, vars, ... }:

{
  #environment.sessionVariables.QT_QPA_PLATFORMTHEME = "gtk2";
  environment.sessionVariables."_JAVA_OPTIONS" = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true";
  environment.sessionVariables.GTK_PATH = "${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0";

  environment.systemPackages = with pkgs; [
    termite
    xclip
  ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = let
    hurmit = pkgs.nerdfonts.override {
      withFont = "Hermit";
    };
    fura = pkgs.nerdfonts.override {
      withFont = "FiraMono";
    };
  in
  with pkgs; [
    fira
    fura
    hurmit
    roboto-slab
    terminus_font
  ];
  fonts.fontconfig.allowBitmaps = true;
  fonts.fontconfig.allowType1 = false;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Hurmit Nerd Font" "Fura Mono Nerd Font" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Fira Sans" ];
  fonts.fontconfig.defaultFonts.serif = [ "Roboto Slab" ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.hinting.enable = true;

  programs.chromium.enable = true;
  programs.chromium.homepageLocation = "https://duckduckgo.com/?key=${secrets.duckduckgo.key}";
  programs.chromium.extensions = [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
    "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
    "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
    "hlepfoohegkhhmjieoechaddaejaokhf" # refined github
    "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
    "naepdomgkenhinolocfifgehidddafch" # browserpass-ce
    "ognfafcpbkogffpmmdglhbjboeojlefj" # keybase
    #"gieohaicffldbmiilohhggbidhephnjj" # vanilla cookie manager
  ];
  programs.light.enable = true;
  programs.qt5ct.enable = true;
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = vars.username;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.package = pkgs.zuki-themes;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.name = "Zukitre";
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.default = "bspwm";
}
