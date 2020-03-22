{ config, pkgs, lib, ... }:
{
  config = with lib; mkMerge [
    (mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        light
      ];

      xdg.configFile."sxhkd/sxhkdrc".text = let
        # Necessary to limit the length of lines for sxhkd, see https://github.com/baskerville/sxhkd/issues/139.
        choosePass = pkgs.writeShellScript "choose-pass" ''
          ${pkgs.gopass}/bin/gopass list --flat ''${@} | ${pkgs.rofi}/bin/rofi -dmenu
        '';
      in 
      with config.resources.programs;
      with pkgs; ''
        super + Return
            ${terminal.executable.path}

        super + space
            ${rofi}/bin/rofi -modi "window,drun,run,ssh" -show run -sidebar-mode

        super + shift + u
            ${gopass}/bin/gopass show -f "$(${choosePass})" username | ${xdotool}/bin/xdotool type --clearmodifiers --file -

        super + shift + p
            ${gopass}/bin/gopass show -f "$(${choosePass})" | ${busybox}/bin/head -n 1 | ${xdotool}/bin/xdotool type --clearmodifiers --file -

        super + shift + f
            ${gopass}/bin/gopass otp "$(${choosePass} 2fa)" | ${busybox}/bin/cut -d ' ' -f 1 | ${xdotool}/bin/xdotool type --clearmodifiers --file -

        super + ctrl + u
            ${gopass}/bin/gopass -c "$(${choosePass})" username

        super + ctrl + p
            ${gopass}/bin/gopass -c "$(${choosePass})"

        super + ctrl + f
            ${gopass}/bin/gopass otp -c "$(${choosePass} 2fa)"

        super + shift + o
            ${browser.executable.path}

        super + shift + e
            ${terminal.executable.path} -e "${shell.executable.path} -i -c ${editor.executable.path}"

        super + shift + d
            ${systemd}/bin/systemctl --user restart redshift.service

        XF86AudioRaiseVolume
            ${alsaUtils}/bin/amixer set Master unmute && ${alsaUtils}/bin/amixer set Master 5%+

        XF86AudioLowerVolume
            ${alsaUtils}/bin/amixer set Master unmute && ${alsaUtils}/bin/amixer set Master 5%-

        XF86AudioMute
            ${alsaUtils}/bin/amixer set Master toggle

        XF86MonBrightnessUp
            ${light}/bin/light -A 5%

        XF86MonBrightnessDown
            ${light}/bin/light -U 5%

        XF86HomePage
            ${browser.executable.path}

        Print
            ${maim}/bin/maim -s $( ${xdg-user-dirs}/bin/xdg-user-dir PICTURES)/scrot/$( ${busybox}/bin/date +%F-%T )-screenshot.png

        #
        # bspwm hotkeys
        #

        # quit bspwm normally
        super + alt + Escape
            killall polybar; ${bspwm}/bin/bspc quit; /run/wrappers/bin/sudo ${systemd}/bin/systemctl restart display-manager

        # suspend
        super + alt + s
            /run/wrappers/bin/sudo ${systemd}/bin/systemctl suspend

        # reload bspwm
        super + alt + b
            /home/${config.resources.username}/.config/bspwm/bspwmrc

        # lock
        super + alt + l
            ${xautolock}/bin/xautolock -locknow


        # close and kill
        super + {_,shift + }q
            ${bspwm}/bin/bspc node -{c,k}

        # alternate between the tiled and monocle layout
        super + m
            ${bspwm}/bin/bspc desktop -l next

        # if the current node is automatic, send it to the last manual, otherwise pull the last leaf
        super + y
            ${bspwm}/bin/bspc query -N -n focused.automatic && bspc node -n last.!automatic || bspc node last.leaf -n focused

        # swap the current node and the biggest node
        super + g
            ${bspwm}/bin/bspc node -s biggest

        #
        # state/flags
        #

        # set the window state
        super + {t,shift + t,s,f}
            ${bspwm}/bin/bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

        # set the node flags
        super + ctrl + {x,y,z}
            ${bspwm}/bin/bspc node -g {locked,sticky,private}

        #
        # focus/swap
        #

        # focus the node in the given direction
        super + {_,shift + }{h,j,k,l}
            ${bspwm}/bin/bspc node -{f,s} {west,south,north,east}

        # focus the node for the given path jump
        super + {p,b,comma,period}
            ${bspwm}/bin/bspc node -f @{parent,brother,first,second}

        # focus the next/previous node
        super + {_,shift + }c
            ${bspwm}/bin/bspc node -f {next,prev}.local

        # focus the next/previous desktop
        super + bracket{left,right}
            ${bspwm}/bin/bspc desktop -f {prev,next}.local

        # focus the last node/desktop
        super + {Tab,grave}
            ${bspwm}/bin/bspc {node,desktop} -f last

        # focus the older or newer node in the focus history
        super + {o,i}
            ${bspwm}/bin/bspc wm -h off; \
            ${bspwm}/bin/bspc node {older,newer} -f; \
            ${bspwm}/bin/bspc wm -h on

        # focus or send to the given desktop
        super + {_,shift + }{1-9,0,F1,F2,F3,F4,F5}
            ${bspwm}/bin/bspc {desktop -f,node -d} '^{1-9,10,11,12,13,14,15}'

        #
        # preselect
        #

        # preselect the direction
        super + ctrl + {h,j,k,l}
            ${bspwm}/bin/bspc node -p {west,south,north,east}

        # preselect the ratio
        super + ctrl + {1-9}
            ${bspwm}/bin/bspc node -o 0.{1-9}

        # cancel the preselection for the focused node
        super + ctrl + space
            ${bspwm}/bin/bspc node -p cancel

        # cancel the preselection for the focused desktop
        super + ctrl + shift + space
            ${bspwm}/bin/bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

        #
        # resize tiled/floating
        #

        # expand the tiled space in the given direction
        super + alt + {h,j,k,l}
            ${bspwm}/bin/bspc node {@west -r -10,@south -r +10,@north -r -10,@east -r +10}

        # contract the tiled space in the given direction
        super + alt + shift + {h,j,k,l}
            ${bspwm}/bin/bspc node {@east -r -10,@north -r +10,@south -r -10,@west -r +10}

        # move a floating window
        super + {Left,Down,Up,Right}
            ${xdo}/bin/xdo move {-x -20,-y +20,-y -20,-x +20}
      '';
    })
  ];
}
