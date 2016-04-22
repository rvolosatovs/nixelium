if [[ $distro == "exherbo" ]]; then
    path+=("/usr/local/bin/${CHOST}")
fi

path=("${HOME}/.local/bin" $path)

export PATH
