{ lib, config, pkgs, vars, secrets, dotDir, goBinDir, ... }:

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
in

rec {
  imports = [
    ./gtk.nix
  ];

  home.file.".themes" = xdg.configFile."themes";

  home.packages = with pkgs; [
    chromium
    ffmpeg
    font-awesome-ttf
    gnome3.dconf
    gnome3.glib_networking
    i3lock
    imagemagick
    kitty
    libnotify
    lxappearance
    maim
    mpv
    networkmanagerapplet
    pavucontrol
    rofi-pass
    slop
    spotify
    sxhkd
    sxiv
    thunderbird
    wmname
    x11_ssh_askpass
    xautolock
    xclip
    xdo
    xdotool
    xsel
    xtitle
    youtube-dl
    zathura
  ];

  programs.browserpass.enable = true;
  programs.firefox.enable = true;
  programs.firefox.enableIcedTea = true;
  programs.feh.enable = true;
  programs.rofi.enable = true;
  programs.rofi.terminal = vars.terminal;
  programs.rofi.separator = "none";
  programs.rofi.lines = 10;
  programs.rofi.width = 20;
  programs.rofi.scrollbar = false;
  #programs.rofi.theme = ../../rofi/themes/base16-tomorrow-dark.rasi;

  services.dunst.enable = true;
  services.dunst.settings."urgency_critical".background = base00;
  services.dunst.settings."urgency_critical".foreground = base08;
  services.dunst.settings."urgency_low".background = base00;
  services.dunst.settings."urgency_low".foreground = base07;
  services.dunst.settings."urgency_normal".background = base00;
  services.dunst.settings."urgency_normal".foreground = base0d;
  services.gnome-keyring.enable = true;
  services.network-manager-applet.enable = true;
  services.redshift.enable = true;
  services.redshift.latitude = secrets.latitude;
  services.redshift.longitude = secrets.longitude;
  services.redshift.tray = true;
  services.polybar.config = "${dotDir}/polybar/config";
  services.polybar.enable = true;
  services.polybar.package = pkgs.polybar.override {
    alsaSupport = true;
    mpdSupport = true;
    githubSupport = true;
  };
  services.polybar.script = ''
    opt=$(${goBinDir}/randrctl) # TODO: package
    i=0
    for m in ''${opt}; do
        name="''${m%:*}"
        mode="''${m#*:}"

        size="-small"
        [[ ''${mode%x*} -gt 1920 ]] && size="-big"

        suf=""
        [[ $i == 0 ]] && suf="-tray"

        MONITOR="''${name}" polybar -r top''${size}''${suf}&

        let i++
    done
  '';
  services.screen-locker.enable = true;
  services.screen-locker.inactiveInterval = 20;
  services.screen-locker.lockCmd = "${pkgs.i3lock}/bin/i3lock -t -f -i ~/pictures/lock";

  xdg.configFile."bspwm/bspwmrc".source = ../../bspwm/bspwmrc;
  xdg.configFile."chromium/Default/User StyleSheets/devtools.css".source = ../../chromium/devtools.css;
  xdg.configFile."i3/config" = xdg.configFile."sway/config";
  xdg.configFile."i3/vars" = xdg.configFile."sway/vars";
  xdg.configFile."kitty/kitty.conf".source = ../../kitty/kitty.conf;
  xdg.configFile."mpv/config".source = ../../mpv/config;
  xdg.configFile."oomox/colors".source = ../../oomox/colors;
  xdg.configFile."stalonetray/stalonetrayrc".source = ../../stalonetray/stalonetrayrc;
  xdg.configFile."sway/config".source = ../../sway/config;
  xdg.configFile."sway/vars".text = ''
    include ${pkgs.sway}/etc/sway/config.d/*

    set $base00 ${base00}
    set $base01 ${base01}
    set $base02 ${base02}
    set $base03 ${base03}
    set $base04 ${base04}
    set $base05 ${base05}
    set $base06 ${base06}
    set $base07 ${base07}
    set $base08 ${base08}
    set $base09 ${base09}
    set $base0a ${base0a}
    set $base0b ${base0b}
    set $base0c ${base0c}
    set $base0d ${base0d}
    set $base0e ${base0e}
    set $base0f ${base0f}

    set $browser ${vars.browser}
    set $mailer ${vars.mailer}
    set $terminal ${vars.terminal}
    set $rofi ${pkgs.rofi}/bin/rofi
    set $spotify ${pkgs.spotify}/bin/spotify
    set $run_editor ${vars.terminal} -e "${vars.shell} -i -c 'exec ${vars.editor}'"
  '';
  xdg.configFile."sxhkd/sxhkdrc".source = ../../sxhkd/sxhkdrc;
  xdg.configFile."themes".source = ../../themes;
  xdg.configFile."zathura/zathurarc".source = ../../zathura/zathurarc;

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

  xsession.enable = true;
  xsession.windowManager.command = ''
    export _JAVA_AWT_WM_NONREPARENTING=1

    ''${HOME}/.local/bin/turbo disable

    ${pkgs.feh}/bin/feh --bg-fill "$HOME/pictures/wp"
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
    ${pkgs.xorg.xset}/bin/xset s off -dpms
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
    ${pkgs.wmname}/bin/wmname LG3D

    ${pkgs.sudo}/bin/sudo ''${HOME}/.local/bin/fix-keycodes

    ${pkgs.pulseaudioFull}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
    ${pkgs.pulseaudioFull}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

    ${pkgs.xbanish}/bin/xbanish &

    SXHKD_SHELL=${pkgs.bash}/bin/bash ${pkgs.sxhkd}/bin/sxhkd -m -1 &
    ${pkgs.bspwm}/bin/bspwm
  '';

  #xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config.focus.followMouse = false;
  xsession.windowManager.i3.config.fonts = [ "Unifont" "FiraCode Nerd Font" ];
}
