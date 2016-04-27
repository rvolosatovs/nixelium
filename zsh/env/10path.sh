if [[ $distro == "exherbo" ]]; then
    path+=("/usr/local/bin/${CHOST}")
fi

path+=("/usr/local/heroku/bin")
path=("${HOME}/.local/bin" $path)

export PATH
