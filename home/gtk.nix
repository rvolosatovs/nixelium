{ config, pkgs, lib, ... }:

{
  config = with lib; mkMerge [
    (mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        gtk_engines
        gtk-engine-murrine
      ];

      gtk.enable = true;
      gtk.font.name = "Fira Sans 10";
      gtk.font.package = pkgs.fira;
      gtk.iconTheme.name = "Adwaita-dark";
      gtk.iconTheme.package = pkgs.gnome3.gnome_themes_standard;
      gtk.theme.name = "Adwaita-dark";
      gtk.theme.package = pkgs.gnome3.gnome_themes_standard;
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
        /* remove window title from Client-Side Decorations */
        .solid-csd headerbar .title {
            font-size: 0;
        }
        
        /* hide extra window decorations/double border */
        window decoration {
            margin: 0;
            border: none;
            padding: 0;
        }
      '';
    })
  ];
}
