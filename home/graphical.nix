{ config, pkgs, lib, ... }:

let
  base00 = "#1d1f21";
  base01 = "#282a2e";
  base02 = "#373b41";
  base03 = "#969896";
  base04 = "#b4b7b4";
  base05 = "#c5c8c6";
  base06 = "#e0e0e0";
  base07 = "#ffffff";
  base08 = "#cc6666";
  base09 = "#de935f";
  base0a = "#f0c674";
  base0b = "#b5bd68";
  base0c = "#8abeb7";
  base0d = "#81a2be";
  base0e = "#b294bb";
  base0f = "#a3685a";

  serif     = "FuraCode Nerd Font";
  sansSerif = "FuraCode Nerd Font";
  monospace = "FuraCode Nerd Font Mono";
in
  {
    imports = [
      ./gtk.nix
      ./sxhkd.nix
    ];

    config = with lib; mkMerge [
      (rec {
        home.file.".themes" = xdg.configFile."themes";

        home.packages = with pkgs; [
          ffmpeg
          font-awesome-ttf
          imagemagick
          mpv
          youtube-dl
        ] ++ (with config.resources.programs; [
          terminal.package
        ]);

        programs.browserpass.enable = true;

        programs.zathura.enable = true;
        programs.zathura.options.completion-bg = base02;
        programs.zathura.options.completion-fg = base0c;
        programs.zathura.options.completion-highlight-bg = base0c;
        programs.zathura.options.completion-highlight-fg = base02;
        programs.zathura.options.default-bg = base00;
        programs.zathura.options.default-fg = base01;
        programs.zathura.options.highlight-active-color = base0d;
        programs.zathura.options.highlight-color = base0a;
        programs.zathura.options.index-active-bg = base0d;
        programs.zathura.options.inputbar-bg = base00;
        programs.zathura.options.inputbar-fg = base05;
        programs.zathura.options.notification-bg = base0b;
        programs.zathura.options.notification-error-bg = base08;
        programs.zathura.options.notification-error-fg = base00;
        programs.zathura.options.notification-fg = base00;
        programs.zathura.options.notification-warning-bg = base08;
        programs.zathura.options.notification-warning-fg = base00;
        programs.zathura.options.recolor = true;
        programs.zathura.options.recolor-darkcolor = base06;
        programs.zathura.options.recolor-keephue = true;
        programs.zathura.options.recolor-lightcolor = base00;
        programs.zathura.options.selection-clipboard = "clipboard";
        programs.zathura.options.statusbar-bg = base01;
        programs.zathura.options.statusbar-fg = base04;

        xdg.configFile."chromium/Default/User StyleSheets/devtools.css".source = ../dotfiles/chromium/devtools.css;
        xdg.configFile."kitty/kitty.conf".text = ''
          background                  ${base00}
          foreground                  ${base05}

          color0                      ${base00}
          color1                      ${base08}
          color2                      ${base0b}
          color3                      ${base0a}
          color4                      ${base0d}
          color5                      ${base0e}
          color6                      ${base0c}
          color7                      ${base05}
          color8                      ${base03}
          color9                      ${base08}
          color10                     ${base0b}
          color11                     ${base0a}
          color12                     ${base0d}
          color13                     ${base0e}
          color14                     ${base0c}
          color15                     ${base07}
          color16                     ${base09}
          color17                     ${base0f}
          color18                     ${base01}
          color19                     ${base02}
          color20                     ${base04}
          color21                     ${base06}

          close_on_child_death        yes
          cursor_blink_interval       0
          cursor_shape                underline
          cursor_stop_blinking_after  0
          editor                      ${config.resources.programs.editor.executable.path}
          font_family                 ${monospace}
          font_size                   ${if pkgs.stdenv.isDarwin then "18.0" else "15.0"}
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

        xresources.properties."*.background" = base00;
        xresources.properties."*.base00" = base00;
        xresources.properties."*.base01" = base01;
        xresources.properties."*.base02" = base02;
        xresources.properties."*.base03" = base03;
        xresources.properties."*.base04" = base04;
        xresources.properties."*.base05" = base05;
        xresources.properties."*.base06" = base06;
        xresources.properties."*.base07" = base07;
        xresources.properties."*.base08" = base08;
        xresources.properties."*.base09" = base09;
        xresources.properties."*.base0A" = base0a;
        xresources.properties."*.base0B" = base0b;
        xresources.properties."*.base0C" = base0c;
        xresources.properties."*.base0D" = base0d;
        xresources.properties."*.base0E" = base0e;
        xresources.properties."*.base0F" = base0f;
        xresources.properties."*.color0" = base00;
        xresources.properties."*.color1" = base08;
        xresources.properties."*.color2" = base0b;
        xresources.properties."*.color3" = base0a;
        xresources.properties."*.color4" = base0d;
        xresources.properties."*.color5" = base0e;
        xresources.properties."*.color6" = base0c;
        xresources.properties."*.color7" = base05;
        xresources.properties."*.color8" = base03;
        xresources.properties."*.color9" = base08;
        xresources.properties."*.color10" = base0b;
        xresources.properties."*.color11" = base0a;
        xresources.properties."*.color12" = base0d;
        xresources.properties."*.color13" = base0e;
        xresources.properties."*.color14" = base0c;
        xresources.properties."*.color15" = base07;
        xresources.properties."*.color16" = base09;
        xresources.properties."*.color17" = base0f;
        xresources.properties."*.color18" = base01;
        xresources.properties."*.color19" = base02;
        xresources.properties."*.color20" = base04;
        xresources.properties."*.color21" = base06;
        xresources.properties."*.cursorColor" = base05;
        xresources.properties."*.foreground" = base05;
        xresources.properties."rofi.auto-select" = false;
        xresources.properties."rofi.color-active" = [ base00 base0b base01 base03 base05 ];
        xresources.properties."rofi.color-normal" = [ base00 base04 base01 base03 base06 ];
        xresources.properties."rofi.color-urgent" = [ base00 base0f base01 base03 base06 ];
        xresources.properties."rofi.color-window" = [ base00 base01 ];
        xresources.properties."rofi.opacity" = 90;
        xresources.properties."ssh-askpass*background" = base00;
        xresources.properties."xscreensaver.logFile" = "/var/log/xscreensaver.log";
        xresources.properties."Xcursor.size" = 20;
        xresources.properties."Xft.antialias" = 1;
        xresources.properties."Xft.autohint" = 0;
        xresources.properties."Xft.hinting" = 1;
        xresources.properties."Xft.hintstyle" = "hintslight";
        xresources.properties."Xft.lcdfilter" = "lcddefault";
        xresources.properties."Xft.rgba" = "rgb";
      })

      (mkIf pkgs.stdenv.isDarwin {
        home.file.".chunkwmrc".executable = true;
        home.file.".chunkwmrc".text = ''
          #!${pkgs.bash}/bin/bash
          chunkc core::log_file stdout
          chunkc core::log_level warn
          chunkc core::plugin_dir /usr/local/opt/chunkwm/share/chunkwm/plugins
          chunkc core::hotload 0

          chunkc set bsp_optimal_ratio             1.618
          chunkc set bsp_spawn_left                1
          chunkc set bsp_split_mode                optimal
          chunkc set bsp_split_ratio               0.5
          chunkc set custom_bar_all_monitors       0
          chunkc set custom_bar_enabled            0
          chunkc set custom_bar_offset_bottom      0
          chunkc set custom_bar_offset_left        0
          chunkc set custom_bar_offset_right       0
          chunkc set custom_bar_offset_top         22
          chunkc set desktop_gap_step_size         5.0
          chunkc set desktop_padding_step_size     10.0
          chunkc set ffm_bypass_modifier           fn
          chunkc set ffm_standby_on_float          1
          chunkc set focused_border_color          0xff0f6288
          chunkc set focused_border_outline        0
          chunkc set focused_border_radius         0
          chunkc set focused_border_skip_floating  0
          chunkc set focused_border_skip_monocle   0
          chunkc set focused_border_width          5
          chunkc set global_desktop_mode           bsp
          chunkc set global_desktop_offset_bottom  3
          chunkc set global_desktop_offset_gap     2
          chunkc set global_desktop_offset_left    3
          chunkc set global_desktop_offset_right   3
          chunkc set global_desktop_offset_top     3
          chunkc set monitor_focus_cycle           1
          chunkc set mouse_follows_focus           intrinsic
          chunkc set mouse_motion_interval         35
          chunkc set mouse_move_window             \"cmd 1\"
          chunkc set mouse_resize_window           \"cmd 2\"
          chunkc set preselect_border_color        0xffd75f5f
          chunkc set preselect_border_outline      0
          chunkc set preselect_border_radius       0
          chunkc set preselect_border_width        5
          chunkc set window_fade_alpha             0.85
          chunkc set window_fade_duration          0.25
          chunkc set window_fade_inactive          0
          chunkc set window_float_next             0
          chunkc set window_float_topmost          0
          chunkc set window_focus_cycle            monitor
          chunkc set window_region_locked          1
          chunkc set window_use_cgs_move           0

          chunkc core::load border.so
          chunkc core::load tiling.so
          chunkc core::load ffm.so

          chunkc tiling::rule --owner Finder --name Copy --state float &
          chunkc tiling::rule --owner \"App Store\" --state float &
          chunkc tiling::rule --owner \"Calculator\" --state float &
        '';
      })

      (mkIf pkgs.stdenv.isLinux {
        home.packages = with pkgs; [
          gnome3.dconf
          gnome3.glib_networking
          gorandr
          i3lock
          libnotify
          maim
          pavucontrol
          rsibreak
          slop
          spotify
          sxhkd
          sxiv
          wmname
          xautolock
          xclip
          xdo
          xdotool
          xtitle
        ];

        home.keyboard.layout = "lv,ru";
        home.keyboard.options = [
          "grp:alt_space_toggle"
          "terminate:ctrl_alt_bksp"
          "eurosign:5"
          "caps:escape"
        ];

        home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

        programs.feh.enable = true;

        programs.rofi.enable = true;
        programs.rofi.terminal = config.resources.programs.terminal.executable.path;
        programs.rofi.separator = "none";
        programs.rofi.lines = 10;
        programs.rofi.width = 20;
        programs.rofi.scrollbar = false;

        services.dunst.enable = true;
        services.dunst.settings."global".browser = config.resources.programs.browser.executable.path;
        services.dunst.settings."global".dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
        services.dunst.settings."global".follow = "keyboard";
        services.dunst.settings."global".font = "Monospace 10";
        services.dunst.settings."global".format = "%a: <b>%p%s</b>\n%b";
        services.dunst.settings."global".icon_position = "left";
        services.dunst.settings."global".startup_notification = false;
        services.dunst.settings."shortcuts".close = "ctrl+space";
        services.dunst.settings."shortcuts".close_all = "ctrl+shift+space";
        services.dunst.settings."shortcuts".context = "ctrl+shift+period";
        services.dunst.settings."shortcuts".history = "ctrl+grave";
        services.dunst.settings."urgency_critical".background = base00;
        services.dunst.settings."urgency_critical".foreground = base08;
        services.dunst.settings."urgency_critical".timeout = 0;
        services.dunst.settings."urgency_low".background = base00;
        services.dunst.settings."urgency_low".foreground = base07;
        services.dunst.settings."urgency_low".timeout = 6;
        services.dunst.settings."urgency_normal".background = base00;
        services.dunst.settings."urgency_normal".foreground = base0d;
        services.dunst.settings."urgency_normal".timeout = 10;

        services.polybar.config = ../dotfiles/polybar/config;
        services.polybar.enable = true;
        services.polybar.script = ''
          i=0
          for m in $(${pkgs.gorandr}/bin/randrq -f '{{.Name}}:{{.Width}}'); do
            name="''${m%:*}"
            width="''${m#*:}"

            size="-small"
            [[ ''${width} -gt 1920 ]] && size="-big"

            suf=""
            [[ $i == 0 ]] && suf="-tray"

            MONITOR="''${name}" ${pkgs.polybar}/bin/polybar -r top''${size}''${suf}&

            let i=i+1
          done
        '';

        services.redshift.enable = true;
        services.redshift.provider = "manual";
        services.redshift.tray = true;

        services.screen-locker.enable = true;
        services.screen-locker.inactiveInterval = 20;
        services.screen-locker.lockCmd = "${pkgs.i3lock}/bin/i3lock -t -f -i ~/pictures/lock";

        xdg.configFile."bspwm/bspwmrc".executable = true;
        xdg.configFile."bspwm/bspwmrc".text = ''
          #!${pkgs.bash}/bin/bash
          initBSPWM() {
              ${pkgs.bspwm}/bin/bspc config automatic_scheme      spiral
              ${pkgs.bspwm}/bin/bspc config initial_polarity      first_child

              ${pkgs.bspwm}/bin/bspc config border_width          2
              ${pkgs.bspwm}/bin/bspc config window_gap            5
              ${pkgs.bspwm}/bin/bspc config split_ratio           0.5
              ${pkgs.bspwm}/bin/bspc config borderless_monocle    true
              ${pkgs.bspwm}/bin/bspc config gapless_monocle       true
              ${pkgs.bspwm}/bin/bspc config focus_follows_pointer false
              ${pkgs.bspwm}/bin/bspc config click_to_focus        button1

              ${pkgs.bspwm}/bin/bspc config normal_border_color   "${base00}"
              ${pkgs.bspwm}/bin/bspc config focused_border_color  "${base05}"
              ${pkgs.bspwm}/bin/bspc config active_border_color   "${base03}"
              ${pkgs.bspwm}/bin/bspc config presel_feedback_color "${base0a}"

              ${pkgs.bspwm}/bin/bspc rule -a "Spotify" desktop=^5
              ${pkgs.bspwm}/bin/bspc rule -a "Chromium-browser:crx_eggkanocgddhmamlbiijnphhppkpkmkl" state=floating
              ${pkgs.bspwm}/bin/bspc rule -a "mpv" state=floating

              local desktops_per_mon=5

              local oldM=$(${pkgs.bspwm}/bin/bspc query -M)
              local mons=$(${pkgs.gorandr}/bin/randrq -f '{{.Name}}:{{.Width}}x{{.Height}}')

              local x=0
              for m in ''${mons}; do
                  local name="''${m%:*}"
                  local mode="''${m#*:}"

                  xrandr --output "''${name}" --mode "''${mode}" --pos ''${x}x0

                  ${pkgs.bspwm}/bin/bspc wm -a "''${name}" "''${mode}+''${x}+0"

                  local names=()
                  for j in $(${pkgs.coreutils}/bin/seq $desktops_per_mon); do
                      names+=("$name/$j")
                  done

                  ${pkgs.bspwm}/bin/bspc monitor "$name" -d ''${names[@]}

                  x=$((''${x}+''${mode%x*}))
              done

              for m in ''${oldM}; do
                  local first="$(${pkgs.coreutils}/bin/head -1 <<< ''${mons} | ${pkgs.coreutils}/bin/cut -d':' -f1)/1"
                  for n in $(${pkgs.bspwm}/bin/bspc query -N -m "''${m}"); do
                      ${pkgs.bspwm}/bin/bspc node "''${n}" -d ''${first}
                  done
                  for d in $(${pkgs.bspwm}/bin/bspc query -D -m "''${m}"); do
                      ${pkgs.bspwm}/bin/bspc desktop "''${d}" -r
                  done
                  ${pkgs.bspwm}/bin/bspc monitor "''${m}" -r
              done

              ${pkgs.feh}/bin/feh --bg-fill "$HOME/pictures/wp"
              ${pkgs.systemd}/bin/systemctl --user restart polybar
          }

          initBSPWM
        '';
        xdg.configFile."sway/config".source = ../dotfiles/sway/config;

        xsession.enable = true;
        xsession.windowManager.command = ''
          ${pkgs.xorg.xset}/bin/xset s off -dpms
          ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
          ${pkgs.wmname}/bin/wmname LG3D

          ${pkgs.pulseaudioFull}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
          ${pkgs.pulseaudioFull}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

          ${pkgs.xbanish}/bin/xbanish &

          /run/wrappers/bin/sudo setkeycodes 0e 43
          /run/wrappers/bin/sudo setkeycodes 2b 14

          SXHKD_SHELL=${pkgs.bash}/bin/bash ${pkgs.sxhkd}/bin/sxhkd -m -1 &
          ${pkgs.bspwm}/bin/bspwm
        '';

        xsession.windowManager.i3.config.focus.followMouse = false;
        xsession.windowManager.i3.config.fonts = [
          "Unifont"
          monospace
        ];
      })
    ];
  }
