{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    GTK_PATH = "${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true";
  };

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = let
    furaCode = pkgs.nerdfonts.override {
      withFont = "FiraCode";
    };
  in
  with pkgs; [
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

  programs.chromium.enable = true;
  programs.chromium.homepageLocation = "https://duckduckgo.com/?key=${config.meta.duckduckgo.key}";
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
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
  #programs.sway.enable = true;
  #users.users."${config.meta.username}".extraGroups = [ "sway" ];

  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = config.meta.username;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.package = pkgs.zuki-themes;
  services.xserver.displayManager.lightdm.greeters.gtk.theme.name = "Zukitre";
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.default = "bspwm";
}
