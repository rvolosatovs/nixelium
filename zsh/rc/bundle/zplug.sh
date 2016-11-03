source ${ZPLUG_HOME}/init.zsh

#_Z_OWNER="b1101"
#_Z_DATA="${XDG_DATA_HOME:-$HOME}/z/z"

#zplug "b4b4r07/zplug"
zplug "zsh-users/zsh-history-substring-search"
#zplug "rupa/z", use:"z.sh"
zplug "zplug/zplug"
zplug "zsh-users/zsh-syntax-highlighting", nice:10
zplug "zsh-users/zsh-completions"
#zplug "RanaExMachina/oh-my-zsh-candy-light"
#zplug "S1cK94/minimal", of:"minimal.zsh-theme", nice:19

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# vim: ft=zsh
