{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true";
    BROWSER = config.resources.programs.browser.executable.path;
    GTK_PATH = "${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0";
  };
  environment.systemPackages = with pkgs; [
    config.resources.programs.browser.package
    lxqt.lxqt-openssh-askpass
  ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    comic-relief
    fira
    fira-code
    nerdfonts
    roboto-slab
    siji
    symbola
    terminus_font
    unifont
  ];
  fonts.fontconfig.allowBitmaps = true;
  fonts.fontconfig.allowType1 = false;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Fira Code" "FiraCode Nerd Font" ];
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

  programs.sway.enable = true;

  systemd.defaultUnit = "graphical.target";
}
