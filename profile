eval `keychain --eval id_rsa`
eval `keychain --eval --agents gpg $(key-id)`
export GITHUB_OAUTH_GO="`pass oauth/github-go`"
