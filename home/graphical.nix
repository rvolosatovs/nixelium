{ config, pkgs, lib, ... }:

let
  internalMonitor = "eDP-1";
  externalMonitor = "Ancor Communications Inc PA328 F7LMQS054477";
in
  with config.resources.base16.colors;
  {
    imports = [
      ./gtk.nix
    ];

    config = with lib; mkMerge [
      (
        rec {
          home.file.".themes" = xdg.configFile."themes";

          home.packages = with pkgs; [
            font-awesome-ttf
            mpv
          ] ++ (
            with config.resources.programs; [
              browser.package
              terminal.package
            ]
          );

          home.sessionVariables.BROWSER = config.resources.programs.browser.executable.path;

          programs.browserpass.enable = true;

          programs.zathura.enable = true;
          programs.zathura.options.completion-bg = "#${base02}";
          programs.zathura.options.completion-fg = "#${base0C}";
          programs.zathura.options.completion-highlight-bg = "#${base0C}";
          programs.zathura.options.completion-highlight-fg = "#${base02}";
          programs.zathura.options.default-bg = "#${base00}";
          programs.zathura.options.default-fg = "#${base01}";
          programs.zathura.options.highlight-active-color = "#${base0D}";
          programs.zathura.options.highlight-color = "#${base0A}";
          programs.zathura.options.index-active-bg = "#${base0D}";
          programs.zathura.options.inputbar-bg = "#${base00}";
          programs.zathura.options.inputbar-fg = "#${base05}";
          programs.zathura.options.notification-bg = "#${base0B}";
          programs.zathura.options.notification-error-bg = "#${base08}";
          programs.zathura.options.notification-error-fg = "#${base00}";
          programs.zathura.options.notification-fg = "#${base00}";
          programs.zathura.options.notification-warning-bg = "#${base08}";
          programs.zathura.options.notification-warning-fg = "#${base00}";
          programs.zathura.options.recolor = true;
          programs.zathura.options.recolor-darkcolor = "#${base06}";
          programs.zathura.options.recolor-keephue = true;
          programs.zathura.options.recolor-lightcolor = "#${base00}";
          programs.zathura.options.selection-clipboard = "clipboard";
          programs.zathura.options.statusbar-bg = "#${base01}";
          programs.zathura.options.statusbar-fg = "#${base04}";

          xdg.configFile."chromium/Default/User StyleSheets/devtools.css".source = ../dotfiles/chromium/devtools.css;

          # Colors based on https://github.com/kdrag0n/base16-kitty/blob/742d0326db469cae2b77ede3e10bedc323a41547/templates/default-256.mustache#L3-L42
          xdg.configFile."kitty/kitty.conf".text = ''
            background                  #${base00}
            foreground                  #${base05}
            selection_background        #${base05}
            selection_foreground        #${base00}
            url_color                   #${base04}
            cursor                      #${base05}
            active_border_color         #${base03}
            inactive_border_color       #${base01}
            active_tab_background       #${base00}
            active_tab_foreground       #${base05}
            inactive_tab_background     #${base01}
            inactive_tab_foreground     #${base04}

            color0                      #${base00}
            color1                      #${base08}
            color2                      #${base0B}
            color3                      #${base0A}
            color4                      #${base0D}
            color5                      #${base0E}
            color6                      #${base0C}
            color7                      #${base05}
            color8                      #${base03}
            color9                      #${base08}
            color10                     #${base0B}
            color11                     #${base0A}
            color12                     #${base0D}
            color13                     #${base0E}
            color14                     #${base0C}
            color15                     #${base05}
            color16                     #${base09}
            color17                     #${base0F}
            color18                     #${base01}
            color19                     #${base02}
            color20                     #${base04}
            color21                     #${base06}

            close_on_child_death        yes
            cursor_blink_interval       0
            cursor_shape                underline
            cursor_stop_blinking_after  0
            disable_ligatures           cursor
            editor                      ${config.resources.programs.editor.executable.path}
            font_size                   15.0
            hide_window_decorations     yes
            initial_window_height       800
            initial_window_width        1200
            scrollback_pager            ${pkgs.less}/bin/less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
            tab_bar_edge                top
          '';
          xdg.configFile."mpv/config".text = ''
            alang=eng,en,rus,ru
          '';
          xdg.configFile."oomox/colors".source = ../dotfiles/oomox/colors;
          xdg.configFile."themes".source = ../dotfiles/themes;

          xresources.properties."*.background" = "#${base00}";
          xresources.properties."*.base00" = "#${base00}";
          xresources.properties."*.base01" = "#${base01}";
          xresources.properties."*.base02" = "#${base02}";
          xresources.properties."*.base03" = "#${base03}";
          xresources.properties."*.base04" = "#${base04}";
          xresources.properties."*.base05" = "#${base05}";
          xresources.properties."*.base06" = "#${base06}";
          xresources.properties."*.base07" = "#${base07}";
          xresources.properties."*.base08" = "#${base08}";
          xresources.properties."*.base09" = "#${base09}";
          xresources.properties."*.base0A" = "#${base0A}";
          xresources.properties."*.base0B" = "#${base0B}";
          xresources.properties."*.base0C" = "#${base0C}";
          xresources.properties."*.base0D" = "#${base0D}";
          xresources.properties."*.base0E" = "#${base0E}";
          xresources.properties."*.base0F" = "#${base0F}";
          xresources.properties."*.color0" = "#${base00}";
          xresources.properties."*.color1" = "#${base08}";
          xresources.properties."*.color2" = "#${base0B}";
          xresources.properties."*.color3" = "#${base0A}";
          xresources.properties."*.color4" = "#${base0D}";
          xresources.properties."*.color5" = "#${base0E}";
          xresources.properties."*.color6" = "#${base0C}";
          xresources.properties."*.color7" = "#${base05}";
          xresources.properties."*.color8" = "#${base03}";
          xresources.properties."*.color9" = "#${base08}";
          xresources.properties."*.color10" = "#${base0B}";
          xresources.properties."*.color11" = "#${base0A}";
          xresources.properties."*.color12" = "#${base0D}";
          xresources.properties."*.color13" = "#${base0E}";
          xresources.properties."*.color14" = "#${base0C}";
          xresources.properties."*.color15" = "#${base07}";
          xresources.properties."*.color16" = "#${base09}";
          xresources.properties."*.color17" = "#${base0F}";
          xresources.properties."*.color18" = "#${base01}";
          xresources.properties."*.color19" = "#${base02}";
          xresources.properties."*.color20" = "#${base04}";
          xresources.properties."*.color21" = "#${base06}";
          xresources.properties."*.cursorColor" = "#${base05}";
          xresources.properties."*.foreground" = "#${base05}";
          xresources.properties."rofi.auto-select" = false;
          xresources.properties."rofi.color-active" = [ "#${base00}" "#${base0B}" "#${base01}" "#${base03}" "#${base05}" ];
          xresources.properties."rofi.color-normal" = [ "#${base00}" "#${base04}" "#${base01}" "#${base03}" "#${base06}" ];
          xresources.properties."rofi.color-urgent" = [ "#${base00}" "#${base0F}" "#${base01}" "#${base03}" "#${base06}" ];
          xresources.properties."rofi.color-window" = [ "#${base00}" "#${base01}" ];
          xresources.properties."rofi.opacity" = 90;
          xresources.properties."ssh-askpass*background" = "#${base00}";
          xresources.properties."xscreensaver.logFile" = "/var/log/xscreensaver.log";
          xresources.properties."Xcursor.size" = 20;
          xresources.properties."Xft.antialias" = 1;
          xresources.properties."Xft.autohint" = 0;
          xresources.properties."Xft.dpi" = 96;
          xresources.properties."Xft.hinting" = 1;
          xresources.properties."Xft.hintstyle" = "hintslight";
          xresources.properties."Xft.lcdfilter" = "lcddefault";
          xresources.properties."Xft.rgba" = "rgb";
        }
      )

      (
        mkIf pkgs.stdenv.isLinux {
          home.packages = with pkgs; [
            clipman
            gnome3.dconf
            gnome3.glib_networking
            grim
            imv
            kanshi
            libnotify
            pavucontrol
            slurp
            spotify
            waybar
            wl-clipboard
            wofi
            ydotool
          ];

          home.keyboard.layout = "lv,ru";
          home.keyboard.options = [
            "eurosign:5"
            "grp:alt_space_toggle"
          ];

          home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";
          home.sessionVariables.ECORE_EVAS_ENGINE = "wayland_egl";
          home.sessionVariables.ELM_ENGINE = "wayland_egl";
          home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
          home.sessionVariables.QT_QPA_PLATFORM = "wayland-egl";
          home.sessionVariables.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          home.sessionVariables.QT_WAYLAND_FORCE_DPI = "physical";
          home.sessionVariables.SAL_USE_VCLPLUGIN = "gtk3";
          home.sessionVariables.SDL_VIDEODRIVER = "wayland";
          home.sessionVariables.XDG_CURRENT_DESKOP = "Unity";

          programs.firefox.enable = true;
          programs.firefox.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            auto-tab-discard
            cookie-autodelete
            dark-night-mode
            gopass-bridge
            https-everywhere
            link-cleaner
            multi-account-containers
            octotree
            peertubeify
            privacy-badger
            reddit-enhancement-suite
            refined-github
            save-page-we
            stylus
            text-contrast-for-dark-themes
            transparent-standalone-image
            ublock-origin
            vim-vixen
          ];
          programs.firefox.package = with pkgs; wrapFirefox.override {
            config = lib.setAttrByPath [ firefox.browserName or (builtins.parseDrvName firefox.name).name ] {
              enableBrowserpass = true;
              enableDjvu = true;
              enableGoogleTalkPlugin = true;
            };
          } firefox-wayland {};

          programs.mako.enable = true;
          programs.mako.backgroundColor = "#${base00}";
          programs.mako.borderColor = "#${base0D}";
          programs.mako.defaultTimeout = 5000;
          programs.mako.textColor = "#${base05}";
          programs.mako.font = "monospace 10";

          programs.skim.defaultOptions = [
            "--bind='ctrl-d:execute(\${TERM:-${config.resources.programs.terminal.executable.path}} -d $(${pkgs.busybox}/bin/dirname {}))'"
            "--bind='ctrl-y:execute(echo {} | ${pkgs.wl-clipboard}/bin/wl-copy)'"
          ];

          programs.zsh.loginExtra = ''
            if [ "$(${pkgs.busybox}/bin/tty)" = "/dev/tty1" ]; then
              exec "${config.wayland.windowManager.sway.package}/bin/sway"
            fi
          '';

          services.redshift.enable = true;
          services.redshift.package = pkgs.redshift-wlr;
          services.redshift.provider = "manual";
          services.redshift.tray = true;

          wayland.windowManager.sway.enable = true;
          wayland.windowManager.sway.extraConfig = ''
            focus output "${externalMonitor}"
          '';

          xdg.configFile."kanshi/config".text = ''
            profile "home" {
                output "${internalMonitor}" position 0,1080
                output "${externalMonitor}" position 1920,0
            }

            profile "otg" {
                output "${internalMonitor}" 
            }
          '';

          # Based on https://github.com/Eluminae/base16-mako/blob/f46c99682c03d30f52436741f1902db36738bf06/templates/default.mustache#L6-L18
          xdg.configFile."mako/config".text = mkAfter ''
            [urgency=low]
            background-color=#${base00}
            text-color=#${base0A}
            border-color=#${base0D}
          
            [urgency=high]
            background-color=#${base00}
            text-color=#${base08}
            border-color=#${base0D}
          '';

          # Based on https://github.com/Calinou/base16-godot/blob/72af0d32c6944ce1030139cdba2f25a708c37382/templates/default.mustache#L4-L38
          xdg.configFile."godot/text_editor_themes/base16.tet".text = ''
            [color_theme]

            background_color="ff${base00}"
            base_type_color="ff${base0C}"
            brace_mismatch_color="ff${base08}"
            breakpoint_color="30${base0A}"
            caret_background_color="ff${base05}"
            caret_color="ff${base05}"
            code_folding_color="ff${base04}"
            comment_color="ff${base03}"
            completion_background_color="ff${base01}"
            completion_existing_color="40${base03}"
            completion_font_color="ff${base04}"
            completion_scroll_color="ff${base04}"
            completion_selected_color="90${base02}"
            current_line_color="25${base03}"
            engine_type_color="ff${base0A}"
            function_color="ff${base0D}"
            gdscript/function_definition_color="ff${base0D}"
            gdscript/node_path_color="ff${base0F}"
            keyword_color="ff${base0E}"
            line_length_guideline_color="ff${base01}"
            line_number_color="ff${base03}"
            mark_color="40ff5555"
            member_variable_color="ff${base08}"
            number_color="ff${base09}"
            safe_line_number_color="ff${base04}"
            search_result_border_color="30${base0A}"
            search_result_color="30${base0A}"
            selection_color="90${base02}"
            string_color="ff${base0B}"
            symbol_color="ff${base05}"
            text_color="ff${base05}"
            text_selected_color="ff${base05}"
            word_highlighted_color="25${base05}"
          '';
        }
      )
    ];
  }
