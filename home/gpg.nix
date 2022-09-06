{
  config,
  pkgs,
  lib,
  ...
}: {
  config = with lib;
    mkMerge [
      {
        accounts.email.accounts."${config.resources.email}" = {
          gpg.encryptByDefault = true;
          gpg.key = config.resources.gpg.publicKey.fingerprint;
          gpg.signByDefault = true;
        };

        programs.gpg.enable = true;
        programs.gpg.settings.cert-digest-algo = "SHA512";
        programs.gpg.settings.cipher-algo = "AES256";
        programs.gpg.settings.compress-algo = "ZLIB";
        programs.gpg.settings.default-key = "0x${config.resources.gpg.publicKey.fingerprint}";
        programs.gpg.settings.default-preference-list = "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed";
        programs.gpg.settings.default-recipient-self = true;
        programs.gpg.settings.digest-algo = "SHA512";
        programs.gpg.settings.disable-cipher-algo = "3DES";
        programs.gpg.settings.export-options = "export-minimal";
        programs.gpg.settings.keyid-format = "0xlong";
        programs.gpg.settings.keyserver-options = "auto-key-retrieve";
        programs.gpg.settings.list-options = "show-uid-validity";
        programs.gpg.settings.no-comments = true;
        programs.gpg.settings.no-emit-version = true;
        programs.gpg.settings.no-greeting = true;
        programs.gpg.settings.personal-cipher-preferences = "AES256";
        programs.gpg.settings.personal-digest-preferences = "SHA512";
        programs.gpg.settings.s2k-cipher-algo = "AES256";
        programs.gpg.settings.s2k-count = "65011712";
        programs.gpg.settings.s2k-digest-algo = "SHA512";
        programs.gpg.settings.s2k-mode = "3";
        programs.gpg.settings.use-agent = true;
        programs.gpg.settings.verify-options = "show-uid-validity";
        programs.gpg.settings.weak-digest = "SHA1";
        programs.gpg.settings.with-fingerprint = true;
      }

      (mkIf pkgs.stdenv.isLinux {
        services.gpg-agent.defaultCacheTtl = 180000;
        services.gpg-agent.defaultCacheTtlSsh = 180000;
        services.gpg-agent.enable = true;
        services.gpg-agent.enableScDaemon = true;
        services.gpg-agent.enableSshSupport = true;
        services.gpg-agent.grabKeyboardAndMouse = false;
      })

      (mkIf (pkgs.stdenv.isLinux && !config.resources.graphics.enable) {
        services.gpg-agent.extraConfig = ''
          pinentry-program ${pkgs.pinentry-curses}/bin/pinentry
        '';
      })

      (mkIf (pkgs.stdenv.isLinux && config.resources.graphics.enable) {
        programs.gpg.settings.photo-viewer = "${pkgs.sxiv}/bin/sxiv -N 'KeyID 0x%f' %i";
      })
    ];
}
