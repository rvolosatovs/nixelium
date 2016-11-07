eval `keychain --eval --agents gpg`
eval `keychain --eval id_rsa ttn`

export PATH="${HOME}/.local/bin:${GOBIN}:${PATH}"
