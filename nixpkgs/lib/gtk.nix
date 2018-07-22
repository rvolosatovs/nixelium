{ pkgs, ... }:

{
  home.packages = with pkgs; [ 
    gtk_engines
    gtk-engine-murrine 
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

     style "default"
     {
       engine "hcengine" {
         edge_thickness = 2
       }
     
       xthickness = 2
       ythickness = 2
     
       EelEditableLabel::cursor_aspect_ratio = 0.1
       EelEditableLabel::cursor_color    = "#81a2be"
     
       GtkEntry::cursor_color    = "#81a2be"
       GtkEntry::cursor_aspect_ratio = 0.1
     
       GtkHSV::focus-line-pattern = "\0"
     
       GtkRange::stepper-size = 20
     
       GtkTextView::cursor_aspect_ratio = 0.1
       GtkTextView::cursor_color    = "#81a2be"
     
       GtkTreeView::expander-size = 16
     
       GtkWidget::focus-line-pattern = "\4\2"
       GtkWidget::focus-line-width = 2
       GtkWidget::focus-padding = 0
       GtkWidget::interior_focus = 1
       GtkWidget::link-color = "#81a2be"
       GtkWidget::visited-link-color = "#b294bb"
     
       # Nautilus
       NautilusIconContainer::frame_text = 1
     
       # Pidgin
       GtkIMHtml::hyperlink-color = "#81a2be"
       GtkIMHtml::hyperlink-visited-color = "#b294bb"
       GtkIMHtml::hyperlink-prelight-color = "#ffffff"
     
       # Evolution
       GtkHTML::link_color = "#81a2be"
       GtkHTML::vlink_color = "#b294bb"
       GtkHTML::cite_color = "#ffffff"
     
       fg[NORMAL]      = "#b4b7b4"
       text[NORMAL]    = "#b4b7b4"
       bg[NORMAL]      = "#1d1f21"
       base[NORMAL]    = "#1d1f21"
     
       fg[INSENSITIVE]      = "#b4b7b4"
       bg[INSENSITIVE]      = "#282a2e"
       text[INSENSITIVE]    = "#b4b7b4"
       base[INSENSITIVE]    = "#282a2e"
     
       fg[PRELIGHT]    = "#1d1f21"
       text[PRELIGHT]  = "#1d1f21"
       bg[PRELIGHT]    = "#b4b7b4"
       base[PRELIGHT]  = "#b4b7b4"
     
       fg[ACTIVE]      = "#c5c8c6"
       text[ACTIVE]    = "#c5c8c6"
       bg[ACTIVE]      = "#373b41"
       base[ACTIVE]    = "#373b41"
     
       fg[SELECTED]    = "#1d1f21"
       text[SELECTED]  = "#1d1f21"
       bg[SELECTED]    = "#b4b7b4"
       base[SELECTED]  = "#ffffff"
     }
     
     class "GtkWidget" style "default"
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

     @define-color theme_base_color #1d1f21;
     @define-color theme_fg_color #b4b7b4;
     @define-color theme_active_color #373b41;
     @define-color theme_insensitive_color #b4b7b4;
     @define-color theme_insensitive_bg #1d1f21;
     
     @define-color theme_cursor_color #81a2be;
     
     /* fallback mode */
     @define-color os_chrome_bg_color #1d1f21;
     @define-color os_chrome_fg_color #b4b7b4;
     @define-color os_chrome_selected_bg_color #e0e0e0;
     @define-color os_chrome_selected_fg_color #373b41;
     
     * {
         /* Pidgin */
         -GtkIMHtml-hyperlink-color: #81a2be;
         -GtkIMHtml-hyperlink-visited-color: #b294bb;
         -GtkIMHtml-hyperlink-prelight-color: #ffffff;
     
         /* Evolution */
         -GtkHTML-link-color: #81a2be;
         -GtkHTML-vlink-color: #b294bb;
         -GtkHTML-cite-color: #b5bd68;
     
         -GtkWidget-link-color: #81a2be;
         -GtkWidget-visited-link-color: #b294bb;
     }
     
     @import url("resource:///org/gnome/HighContrastInverse/a11y.css");
  '';
}
