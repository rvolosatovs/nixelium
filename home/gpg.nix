{ config, pkgs, lib, ... }:

{
  home.file.".gnupg/gpg.conf".text = ''
    default-key 0x${config.resources.gpg.publicKey.fingerprint}
    use-agent

    # Avoid information leaked
    no-emit-version
    no-comments
    export-options export-minimal

    # Displays the long format of the ID of the keys and their fingerprints
    keyid-format 0xlong
    with-fingerprint

    # Displays the validity of the keys
    list-options show-uid-validity
    verify-options show-uid-validity

    # Limits the algorithms used
    personal-cipher-preferences AES256
    personal-digest-preferences SHA512
    default-preference-list SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed

    cipher-algo AES256
    digest-algo SHA512
    cert-digest-algo SHA512
    compress-algo ZLIB

    disable-cipher-algo 3DES
    weak-digest SHA1

    s2k-cipher-algo AES256
    s2k-digest-algo SHA512
    s2k-mode 3
    s2k-count 65011712
  '';
}
