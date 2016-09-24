clear

if command -v fortune > /dev/null; then
	fortune
else
	echo Greetingz, comrad!
fi
printf "\n"

$HOME/.local/bin/turbo disable

keychain --dir $HOME/.local/keychain --agents gpg,ssh

#keychain --dir $HOME/.local/keychain --agents gpg $(key-id)
source $HOME/.local/keychain/${HOST}-sh-gpg

#keychain --dir $HOME/.local/keychain id_rsa ttn
source $HOME/.local/keychain/${HOST}-sh

if [ ${HOST} = "atom" ]; then
    fix-keycodes
fi

if [ $(tty) = "/dev/tty1" ];then
    exec startx
fi
