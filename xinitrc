[ -f ~/.profile ] && source ~/.profile

source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

export SSH_ASKPASS="qt4-ssh-askpass"

# Java
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true'
export _JAVA_AWT_WM_NONREPARENTING=1

xrdb -merge ~/.Xresources

pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

xrandr --output DP-1 --primary --mode 3840x2160 --rate 60 --rotate normal --output LVDS-1 --auto --right-of DP-1
xsetroot -cursor_name left_ptr & 

feh  --bg-max "$HOME/pictures/bg" 
stalonetray -c "$HOME/.config/stalonetray/stalonetrayrc"&

dunst &
nm-applet &
xbanish &

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
