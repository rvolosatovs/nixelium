# Setup fzf
# ---------
if [[ ! "$PATH" == */home/b1101/.local/fzf/bin* ]]; then
  export PATH="$PATH:/home/b1101/.local/fzf/bin"
fi

# Man path
# --------
if [[ ! "$MANPATH" == */home/b1101/.local/fzf/man* && -d "/home/b1101/.local/fzf/man" ]]; then
  export MANPATH="$MANPATH:/home/b1101/.local/fzf/man"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/b1101/.local/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/b1101/.local/fzf/shell/key-bindings.zsh"

