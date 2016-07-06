source ${ZPLUG_HOME}/zplug

_Z_OWNER="b1101"
_Z_DATA="${XDG_DATA_HOME:-$HOME}/z/z"
export ZPLUG_CLONE_DEPTH=1

zplug "b4b4r07/zplug"
#zplug "zsh-users/zsh-history-substring-search"
zplug "rupa/z", use:"z.sh"
zplug "zsh-users/zsh-syntax-highlighting", nice:10
zplug "zsh-users/zsh-completions"
#zplug "RanaExMachina/oh-my-zsh-candy-light"
#zplug "S1cK94/minimal", of:"minimal.zsh-theme", nice:19

# vim: ft=zsh