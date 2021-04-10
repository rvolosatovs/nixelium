{ config, pkgs, lib, ... }:

let
  choosePass = "${pkgs.gopass}/bin/gopass list --flat \${@} | ${pkgs.wofi}/bin/wofi --dmenu";
  typeStdin = "${pkgs.ydotool}/bin/ydotool type --file -";

  headphones = "70:26:05:CF:7F:C2";
  wirelessInterface = "wlan0"; # TODO: make generic

  cfg = config.wayland.windowManager.sway;

  exec = cmd: "exec '${cmd}'";

  mkXkbOptions = lib.concatStringsSep ",";
  defaultXkbOptions = mkXkbOptions config.home.keyboard.options;
  extendDefaultXkbOptions = xs: mkXkbOptions (config.home.keyboard.options ++ xs);
in
  {
    config =
      with pkgs;
      with config.resources.programs;
      with config.resources.base16.colors; 
      lib.mkIf cfg.enable { 
        home.packages = [
          clipman
          grim
          ip-link-toggle
          kanshi
          spotify
          waybar
          wl-clipboard
          wofi
          ydotool
        ];

        programs.mako.enable = true;

        wayland.windowManager.sway.config.input."1:1:AT_Translated_Set_2_keyboard" = {
          xkb_layout = config.home.keyboard.layout;
          xkb_options = extendDefaultXkbOptions [
            "caps:escape"
          ];
        };
        wayland.windowManager.sway.config.input."4617:8961:Keyboardio_Model_01_Keyboard" = {
          xkb_layout = config.home.keyboard.layout;
          xkb_options = defaultXkbOptions;
        };
        wayland.windowManager.sway.config.input."1149:8264:Primax_Kensington_Eagle_Trackball" = {
          pointer_accel = "0.5";
          scroll_factor = "2";
        };

        wayland.windowManager.sway.config.output."*".bg = "${config.home.homeDirectory}/pictures/wp fill";
        wayland.windowManager.sway.config.workspaceAutoBackAndForth = true;
        wayland.windowManager.sway.config.focus.followMouse = false;
        wayland.windowManager.sway.config.focus.mouseWarping = false;
        wayland.windowManager.sway.wrapperFeatures.base = true;
        wayland.windowManager.sway.wrapperFeatures.gtk = true;

        # Based on https://github.com/khamer/base16-i3/blob/78292138812a3f88c3fc4794f615f5b36b0b6d7c/templates/default.mustache#L41-L48
        wayland.windowManager.sway.config.colors.focused.border = "#${base05}";
        wayland.windowManager.sway.config.colors.focused.background = "#${base0D}";
        wayland.windowManager.sway.config.colors.focused.text = "#${base00}";
        wayland.windowManager.sway.config.colors.focused.indicator = "#${base0D}";
        wayland.windowManager.sway.config.colors.focused.childBorder = "#${base0C}";
        wayland.windowManager.sway.config.colors.focusedInactive.border = "#${base01}";
        wayland.windowManager.sway.config.colors.focusedInactive.background = "#${base01}";
        wayland.windowManager.sway.config.colors.focusedInactive.text = "#${base05}";
        wayland.windowManager.sway.config.colors.focusedInactive.indicator = "#${base03}";
        wayland.windowManager.sway.config.colors.focusedInactive.childBorder = "#${base01}";
        wayland.windowManager.sway.config.colors.unfocused.border = "#${base01}";
        wayland.windowManager.sway.config.colors.unfocused.background = "#${base00}";
        wayland.windowManager.sway.config.colors.unfocused.text = "#${base05}";
        wayland.windowManager.sway.config.colors.unfocused.indicator = "#${base01}";
        wayland.windowManager.sway.config.colors.unfocused.childBorder = "#${base01}";
        wayland.windowManager.sway.config.colors.urgent.border = "#${base08}";
        wayland.windowManager.sway.config.colors.urgent.background = "#${base08}";
        wayland.windowManager.sway.config.colors.urgent.text = "#${base00}";
        wayland.windowManager.sway.config.colors.urgent.indicator = "#${base08}";
        wayland.windowManager.sway.config.colors.urgent.childBorder = "#${base08}";
        wayland.windowManager.sway.config.colors.placeholder.border = "#${base00}";
        wayland.windowManager.sway.config.colors.placeholder.background = "#${base00}";
        wayland.windowManager.sway.config.colors.placeholder.text = "#${base05}";
        wayland.windowManager.sway.config.colors.placeholder.indicator = "#${base00}";
        wayland.windowManager.sway.config.colors.placeholder.childBorder = "#${base00}";
        wayland.windowManager.sway.config.colors.background = "#${base07}";

        wayland.windowManager.sway.config.bars = [
          {
            position = "top";
            statusCommand = null;
            command = "${waybar}/bin/waybar";

            # Based on https://github.com/khamer/base16-i3/blob/78292138812a3f88c3fc4794f615f5b36b0b6d7c/templates/default.mustache#L28-L38
            colors.background = "#${base00}";
            colors.separator = "#${base01}";
            colors.statusline = "#${base04}";
            colors.focusedWorkspace.border = "#${base05}";
            colors.focusedWorkspace.background = "#${base0D}";
            colors.focusedWorkspace.text = "#${base00}";
            colors.activeWorkspace.border = "#${base05}";
            colors.activeWorkspace.background = "#${base03}";
            colors.activeWorkspace.text = "#${base00}";
            colors.inactiveWorkspace.border = "#${base03}";
            colors.inactiveWorkspace.background = "#${base01}";
            colors.inactiveWorkspace.text = "#${base05}";
            colors.urgentWorkspace.border = "#${base08}";
            colors.urgentWorkspace.background = "#${base08}";
            colors.urgentWorkspace.text = "#${base00}";
            colors.bindingMode.border = "#${base00}";
            colors.bindingMode.background = "#${base0A}";
            colors.bindingMode.text = "#${base00}";
          }
        ];

        wayland.windowManager.sway.config.startup = [
          {
            command = "${kanshi}/bin/kanshi";
            always = true;
          }
          {
            command = "${browser.executable.path}";
          }
          {
            command = "${spotify}/bin/spotify";
          }
          {
            command = "${mailer.executable.path}";
          }
          {
            command = "${wl-clipboard}/bin/wl-paste -t text --watch ${clipman}/bin/clipman store";
          }
          {
            command = "${clipman}/bin/clipman restore";
          }
          {
            command = "unset LESS_TERMCAP_mb";
          }
          {
            command = "unset LESS_TERMCAP_md";
          }
          {
            command = "unset LESS_TERMCAP_me";
          }
          {
            command = "unset LESS_TERMCAP_se";
          }
          {
            command = "unset LESS_TERMCAP_so";
          }
          {
            command = "unset LESS_TERMCAP_ue";
          }
          {
            command = "unset LESS_TERMCAP_us";
          }
        ];


        wayland.windowManager.sway.config.assigns."5" = [
          {
            app_id = "^thunderbird$";
          }
        ];
        wayland.windowManager.sway.config.window.commands = [
          {
            command = "move to workspace 4";
            criteria.class = "^Spotify$";
          }
        ];
        wayland.windowManager.sway.config.floating.criteria = [
          {
            app_id = "^mpv$";
          }
          {
            app_id = "^pavucontrol$";
          }
          {
            app_id = "^firefox$";
            title="^Picture-in-Picture$";
          }
          {
            app_id = "^firefox$";
            title="^Firefox - Sharing Indicator$";
          }
        ];

        wayland.windowManager.sway.config.modifier = "Mod4";
        wayland.windowManager.sway.config.left = "h";
        wayland.windowManager.sway.config.down = "j";
        wayland.windowManager.sway.config.up = "k";
        wayland.windowManager.sway.config.right = "l";
        wayland.windowManager.sway.config.terminal = terminal.executable.path;
        wayland.windowManager.sway.config.menu = "${wofi}/bin/wofi --show drun,run";

        wayland.windowManager.sway.config.bindkeysToCode = true;

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+${cfg.config.left}" = "focus left";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+${cfg.config.down}" = "focus down";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+${cfg.config.up}" = "focus up";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+${cfg.config.right}" = "focus right";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Left" = "focus left";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Down" = "focus down";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Up" = "focus up";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Right" = "focus right";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+${cfg.config.left}" = "move left";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+${cfg.config.down}" = "move down";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+${cfg.config.up}" = "move up";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+${cfg.config.right}" = "move right";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+Left" = "move left";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+Down" = "move down";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+Up" = "move up";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+Right" = "move right";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+1" = "workspace number 1";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+2" = "workspace number 2";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+3" = "workspace number 3";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+4" = "workspace number 4";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+5" = "workspace number 5";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+6" = "workspace number 6";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+7" = "workspace number 7";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+8" = "workspace number 8";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+9" = "workspace number 9";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+0" = "workspace number 10";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+1" = "move container to workspace number 1";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+2" = "move container to workspace number 2";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+3" = "move container to workspace number 3";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+4" = "move container to workspace number 4";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+5" = "move container to workspace number 5";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+6" = "move container to workspace number 6";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+7" = "move container to workspace number 7";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+8" = "move container to workspace number 8";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+9" = "move container to workspace number 9";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+0" = "move container to workspace number 10";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+v" = "splith";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+s" = "splitv";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+f" = "fullscreen toggle";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+a" = "focus parent";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+z" = "focus child";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+e" = "layout toggle split";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+t" = "layout stacking";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+w" = "layout tabbed";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+g" = "floating toggle";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+r" = "mode resize";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+q" = "kill";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Escape" = exec "${swaylock}/bin/swaylock -t -f -i ${config.home.homeDirectory}/pictures/lock";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+s" = exec "${systemd}/bin/systemctl suspend";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+c" = "reload";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+Escape" = "exit";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Return" = exec "${cfg.config.terminal}";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+o" = exec "${browser.executable.path}";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+space" = exec "${cfg.config.menu}";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Ctrl+f" = exec ''${gopass}/bin/gopass otp -c "$(${choosePass} 2fa)"'';
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Ctrl+p" = exec ''${gopass}/bin/gopass show -c "$(${choosePass})"'';
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Ctrl+u" = exec ''${gopass}/bin/gopass show -c "$(${choosePass})" username'';
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+f" = exec ''${gopass}/bin/gopass otp -o "$(${choosePass} 2fa)" | ${busybox}/bin/cut -d " " -f 1 | ${typeStdin}'';
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+p" = exec ''${gopass}/bin/gopass show -o -f "$(${choosePass})" | ${busybox}/bin/head -n 1 | ${typeStdin}'';
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+u" = exec ''${gopass}/bin/gopass show -o -f "$(${choosePass})" username | ${typeStdin}'';

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+p" = exec "${clipman}/bin/clipman pick -t wofi";

        # TODO: Bind to XF86 button
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+w" = exec "/run/wrappers/bin/sudo ${ip-link-toggle}/bin/ip-link-toggle ${wirelessInterface}";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+b" = exec "${bluez}/bin/bluetoothctl connect ${headphones}";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+b" = exec "${bluez}/bin/bluetoothctl disconnect ${headphones}";
        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+n" = exec "${mako}/bin/makoctl dismiss";

        wayland.windowManager.sway.config.keybindings."${cfg.config.modifier}+Shift+d" = exec "${systemd}/bin/systemctl --user restart wlsunset.service";

        wayland.windowManager.sway.config.keybindings.XF86MonBrightnessDown = exec "${light}/bin/light -U 5%";
        wayland.windowManager.sway.config.keybindings.XF86MonBrightnessUp = exec "${light}/bin/light -A 5%";

        wayland.windowManager.sway.config.keybindings.XF86AudioMute = exec "${alsaUtils}/bin/amixer set Master toggle";
        wayland.windowManager.sway.config.keybindings.XF86AudioMicMute = exec "${alsaUtils}/bin/amixer set Capture toggle";
        wayland.windowManager.sway.config.keybindings.XF86AudioLowerVolume = exec "${alsaUtils}/bin/amixer set Master unmute && ${alsaUtils}/bin/amixer set Master 5%-";
        wayland.windowManager.sway.config.keybindings.XF86AudioRaiseVolume = exec "${alsaUtils}/bin/amixer set Master unmute && ${alsaUtils}/bin/amixer set Master 5%+";
        wayland.windowManager.sway.config.keybindings.XF86AudioNext = exec "${playerctl}/bin/playerctl next";
        wayland.windowManager.sway.config.keybindings.XF86AudioPlay = exec "${playerctl}/bin/playerctl play-pause";
        wayland.windowManager.sway.config.keybindings.XF86AudioPrev = exec "${playerctl}/bin/playerctl previous";

        wayland.windowManager.sway.config.keybindings.XF86HomePage = exec "${browser.executable.path}";
        wayland.windowManager.sway.config.keybindings.Print = exec ''${grim}/bin/grim -g "$(${slurp}/bin/slurp)" "$(${xdg-user-dirs}/bin/xdg-user-dir PICTURES)/scrot/$(${busybox}/bin/date +%F-%T)-screenshot.png"'';
        wayland.windowManager.sway.config.keybindings."Print+Ctrl" = exec ''${grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | ${wl-clipboard}/bin/wl-copy'';
      };
    }
