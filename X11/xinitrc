export SSH_ASKPASS="ssh-askpass"
keychain --agent gpg `key-id`
keychain id_rsa
[ -f ~/.local/keychain/$HOSTNAME-sh ] && source ~/.local/keychain/$HOSTNAME-sh 2>/dev/null
[ -f ~/.local/keychain/$HOSTNAME-sh-gpg ] && source ~/.local/keychain/$HOSTNAME-sh-gpg 2>/dev/null

pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

#xrandr --output LVDS-1 --auto
#xrandr --output LVDS-1 --auto --output DP-2 --mode 1920x1080 --rate 60 --left-of LVDS-1 --primary
xrandr --output DP-1 --primary --mode 3840x2160 --rate 60 --rotate normal --output LVDS-1 --auto --right-of DP-1
xsetroot -cursor_name left_ptr & 

feh  --bg-max "$HOME/pictures/bg" 
stalonetray -c "$HOME/.config/stalonetray/stalonetrayrc"&

dunst &
nm-applet &
redshift &

session=${1:-bspwm}
case $session in
    wingo             ) exec wingo;;
    awesome           ) exec awesome;;
    bspwm             ) exec bspwm;;
    catwm             ) exec catwm;;
    cinnamon          ) exec cinnamon-session;;
    dwm               ) exec dwm;;
    enlightenment     ) exec enlightenment_start;;
    ede               ) exec startede;;
    fluxbox           ) exec startfluxbox;;
    gnome             ) exec gnome-session;;
    gnome-classic     ) exec gnome-session --session=gnome-classic;;
    i3|i3wm           ) exec i3;;
    icewm             ) exec icewm-session;;
    jwm               ) exec jwm;;
    kde               ) exec startkde;;
    mate              ) exec mate-session;;
    monster|monsterwm ) exec monsterwm;;
    notion            ) exec notion;;
    openbox           ) exec openbox-session;;
    unity             ) exec unity;;
    xfce|xfce4        ) exec startxfce4;;
    xmonad            ) exec xmonad;;
    # No known session, try to run it as command
    *) exec $1;;
esac
# vim: ft=sh
