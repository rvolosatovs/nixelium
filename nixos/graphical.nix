{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    BROWSER = config.resources.programs.browser.executable.path;
  };
  environment.systemPackages = with pkgs; [
    config.resources.programs.browser.package
    lxqt.lxqt-openssh-askpass
  ];

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

  fonts.fontDir.enable = true;

  hardware.opengl.enable = true;

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
  programs.sway.extraPackages = with pkgs; [
    swayidle
    swaylock
    v4l-utils
    wf-recorder
    wofi
    xwayland
  ];

  services.pipewire.enable = true;

  systemd.defaultUnit = "graphical.target";

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
  xdg.portal.gtkUsePortal = true;
}
