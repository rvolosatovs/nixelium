{ config, pkgs, lib, ... }:

{
  home.file.".gnupg/gpg.conf".text = ''
    cert-digest-algo SHA512
    cipher-algo AES256
    compress-algo ZLIB
    default-key 0x${config.resources.gpg.publicKey.fingerprint}
    default-preference-list SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed
    default-recipient-self
    digest-algo SHA512
    disable-cipher-algo 3DES
    export-options export-minimal
    keyid-format 0xlong
    keyserver-options auto-key-retrieve
    list-options show-uid-validity
    no-comments
    no-emit-version
    no-greeting
    personal-cipher-preferences AES256
    personal-digest-preferences SHA512
    photo-viewer "${pkgs.sxiv}/bin/sxiv -N 'KeyID 0x%f' %i"
    s2k-cipher-algo AES256
    s2k-count 65011712
    s2k-digest-algo SHA512
    s2k-mode 3
    use-agent
    verify-options show-uid-validity
    weak-digest SHA1
    with-fingerprint
  '';
}
