#!/bin/zsh
pushd $0:A:h > /dev/null

alias -g aliases="$0:A:h'/aliases/'"

# Persistent
for ali in aliases/const/*; do
    source $ali
done

# Shell
if [ uname=="Linux" ];then
    source aliases/linux
fi

# Systemd
if type systemctl > /dev/null;then
    source aliases/systemd
fi

# Vi
if type nvim > /dev/null;then
    source aliases/nvim
elif type vim > /dev/null;then
    source aliases/vim
fi

# Git
if type git > /dev/null;then
    source aliases/git
fi

# Cave
if type cave > /dev/null; then
    source aliases/cave
fi

# Eclectic
if type eclectic > /dev/null; then
    source aliases/eclectic
fi

# Xbps
if type xbps-install > /dev/null; then
    source aliases/xbps
fi

# Portage
if type emerge > /dev/null; then
    source aliases/portage
fi

# Pacman
if type pacman > /dev/null; then
    source aliases/pacman
fi

# Pacaur
if type pacaur > /dev/null; then
    source aliases/pacaur
fi

# Nix
if type nix-env > /dev/null; then
    source aliases/nix
fi

distro=$(awk /ID/ /etc/os-release | cut -d"=" -f2)
# Distro-specific
if   [[ $distro == "exherbo"   ]]; then
    source aliases/exherbo
elif [[ $distro == "voidlinux" ]]; then
    source aliases/void
elif [[ $distro == "gentoo"    ]]; then #TODO: check ID
    source aliases/gentoo
elif [[ $distro == "nix"       ]]; then #TODO: check ID
    source aliases/nixos
elif [[ $distro == "arch"      ]]; then
    source aliases/arch
fi

unalias \aliases

popd > /dev/null
