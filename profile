eval `keychain --eval --agents gpg`
eval `keychain --eval id_rsa ttn`

export PATH="${HOME}/.local/bin:${HOME}/.gem/ruby/2.4.0/bin/:${GOBIN}:/opt/android-ndk/:${PATH}"
