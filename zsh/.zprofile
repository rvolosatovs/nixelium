export HISTFILE="${ZDOTDIR}/.zhistory"

# XDG base directory spec
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_RUNTIME_DIR="/run/user/${EUID}"

export GIMP2_DIRECTORY="$XDG_CONFIG_HOME"/gimp
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export ELINKS_CONFDIR="$XDG_CONFIG_HOME"/elinks

export WINEPREFIX="$XDG_DATA_HOME"/wine
export TERMINFO="$XDG_DATA_HOME"/terminfo # Precludes system path searching.
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo

export TMUX_TMPDIR="$XDG_RUNTIME_DIR"/tmux
export XAUTHORITY="$XDG_RUNTIME_DIR"/xauthority

export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME"/nv
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs

# Scripts
export PATH="$HOME/.local/bin:$PATH"

# Def
export EMAIL="rvolosatovs@riseup"

export PAGER="less"
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="chromium"
umask 066

# Go
export GOPATH="$HOME/workspace/go"
export GOBIN="$HOME/.local/bin.go"
export PATH="$GOBIN:$PATH"

# Java
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true'
export _JAVA_AWT_WM_NONREPARENTING=1

# Pass
export PASSWORD_STORE_DIR="${HOME}/.local/pass"
export GITHUB_OAUTH_GO=`pass oauth/github-go`

# Panel
PANEL_FIFO=/tmp/panel-fifo
PANEL_HEIGHT=24
PANEL_FONT="-*-Fira Sans-*-*-*-*-10-*-*-*-*-*-*-*"
PANEL_WM_NAME=bspwm_panel
export PANEL_FIFO PANEL_HEIGHT PANEL_FONT PANEL_WM_NAME

# Ruby
export PATH="$HOME/.gem/ruby/2.3.0/bin:$PATH"
source $HOME/.local/share/base16/vconsole/base16-marrakesh.dark.sh

# GCC
if [[ $distro == "exherbo" ]]; then
    export CHOST=$(readlink '/usr/host')
    export CROSS_COMPILE=${CHOST}-

    export CC=${CHOST}-gcc
    export HOSTCC=${CHOST}-gcc
    export CXX=${CHOST}-c++
    export CLANG=${CHOST}-clang
    export LD=${CHOST}-ld
    export AR=${CHOST}-ar
    export AS=${CHOST}-as
    export NM=${CHOST}-nm
    export STRIP=${CHOST}-strip
    export RANLIB=${CHOST}-ranlib
    export DLLTOOL=${CHOST}-dlltool
    export OBJDUMP=${CHOST}-objdump
    export RESCOMP=${CHOST}-windres
    export WINDRES=${CHOST}-windres
    export PKG_CONFIG=${CHOST}-pkg-config
fi 
# vim: ft=zsh
