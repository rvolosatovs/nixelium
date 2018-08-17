{ pkgs, ... }:

{
  home.packages = with pkgs; [ 
    gtk_engines
    gtk-engine-murrine 
    qt5.qtbase.gtk
  ];
  home.sessionVariables.QT_QPA_PLATFORMTHEME="gtk2";

  gtk.enable = true;
  gtk.font.name = "Fira Sans 10";
  gtk.font.package = pkgs.fira;
  gtk.theme.name = "oomox-Tomorrow-Dark";
  gtk.iconTheme.name = "oomox-Tomorrow-Dark-flat";
  gtk.gtk2.extraConfig = ''
     gtk-cursor-theme-size=0
     gtk-toolbar-style=GTK_TOOLBAR_BOTH
     gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
     gtk-button-images=1
     gtk-menu-images=1
     gtk-enable-event-sounds=1
     gtk-enable-input-feedback-sounds=1
     gtk-xft-antialias=1
     gtk-xft-hinting=1
     gtk-xft-hintstyle="hintslight"
     gtk-xft-rgba="rgb"
  '';

  gtk.gtk3.extraConfig.gtk-cursor-theme-size=0;
  gtk.gtk3.extraConfig.gtk-toolbar-style="GTK_TOOLBAR_BOTH";
  gtk.gtk3.extraConfig.gtk-toolbar-icon-size="GTK_ICON_SIZE_LARGE_TOOLBAR";
  gtk.gtk3.extraConfig.gtk-button-images=1;
  gtk.gtk3.extraConfig.gtk-menu-images=1;
  gtk.gtk3.extraConfig.gtk-enable-event-sounds=1;
  gtk.gtk3.extraConfig.gtk-enable-input-feedback-sounds=1;
  gtk.gtk3.extraConfig.gtk-xft-antialias=1;
  gtk.gtk3.extraConfig.gtk-xft-hinting=1;
  gtk.gtk3.extraConfig.gtk-xft-hintstyle="hintslight";
  gtk.gtk3.extraConfig.gtk-xft-rgba="rgb";
  gtk.gtk3.extraCss = ''
     .window-frame, .window-frame:backdrop {
      box-shadow: 0 0 0 black;
      border-style: none;
      margin: 0;
      border-radius: 0;
     }
     .titlebar {
      border-radius: 0;
     }
     window decoration {
      margin: 0;
      border: 0;
     }
  '';
}
