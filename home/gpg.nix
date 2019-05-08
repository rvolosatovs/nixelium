{ config, pkgs, lib, ... }:

{
  config = with lib; mkMerge [
    ({
      accounts.email.accounts."${config.resources.email}" = {
        gpg.encryptByDefault = true;
        gpg.key = config.resources.gpg.publicKey.fingerprint;
        gpg.signByDefault = true;
      };

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
      '' + optionalString (pkgs.stdenv.isLinux && config.resources.graphics.enable) ''
        photo-viewer "${pkgs.sxiv}/bin/sxiv -N 'KeyID 0x%f' %i"
      '' + ''
        s2k-cipher-algo AES256
        s2k-count 65011712
        s2k-digest-algo SHA512
        s2k-mode 3
        use-agent
        verify-options show-uid-validity
        weak-digest SHA1
        with-fingerprint
      '';
    })

    (mkIf pkgs.stdenv.isDarwin {
      home.file.".gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      '';
    })

    (mkIf pkgs.stdenv.isLinux {
      services.gpg-agent.defaultCacheTtl = 180000;
      services.gpg-agent.defaultCacheTtlSsh = 180000;
      services.gpg-agent.enable = true;
      services.gpg-agent.enableScDaemon = false;
      services.gpg-agent.enableSshSupport = true;
      services.gpg-agent.grabKeyboardAndMouse = false;
    })
  ];
}
