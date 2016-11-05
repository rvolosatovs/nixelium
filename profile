eval `keychain --eval --agents gpg`
eval `keychain --eval id_rsa ttn`
export GITHUB_OAUTH_GO="`pass oauth/github-go`"
