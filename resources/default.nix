{ config, pkgs, lib, ... }:
{
  imports = [
    ./../modules/resources.nix
  ];

  config.resources = with lib; mapAttrs (_: v: mkDefault v) {
    email = "rvolosatovs@riseup.net";
    username = "rvolosatovs";
    fullName = "Roman Volosatovs";

    ssh.publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX openpgp:0x8E53BF31"
    ];
    gpg.publicKey.fingerprint = "AD822706A27A30FBB4BA0DD72A70D807E47CF7EF";

    base16.theme = "tomorrow-night";

    programs =
      let
        pkgToProg = pkg: exe: {
          package = pkg;
          executable.name = exe;
        };
      in
      {
        editor.package = pkgs.neovim;
        editor.executable.name = "nvim";

        mailer.package = pkgs.mutt;
        mailer.executable.name = "mutt";

        pager.package = pkgs.less;
        pager.executable.name = "less";

        shell.package = pkgs.zsh;
        shell.executable.name = "zsh";

      } // optionalAttrs config.resources.graphics.enable {
        terminal.package = pkgs.kitty;
        terminal.executable.name = "kitty -1";

      } // optionalAttrs (config.resources.graphics.enable && pkgs.stdenv.isLinux) {
        browser.package = pkgs.firefox-wayland;
        browser.executable.name = "firefox";

        mailer.package = pkgs.thunderbird;
        mailer.executable.name = "thunderbird";
      };
  };
}
