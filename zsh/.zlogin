clear

if command -v fortune > /dev/null; then
	fortune
else
	echo Greetingz, comrad!
fi
printf "\n"

if [ ${HOST} = "atom" ]; then
    fix-keycodes
fi

if [ $(tty) = "/dev/tty1" ];then
    exec startx
fi
