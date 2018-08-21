{ config, pkgs, lib,... }:

{
  imports = [
    ./../modules/meta.nix
    ./../vendor/secrets
  ];

  config = {
    meta.email = "rvolosatovs@riseup.net";
    meta.username = "rvolosatovs";
    meta.fullName = "Roman Volosatovs";
    meta.ssh.publicKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSZ+ZWFCat0Fvog7XpS7mnNK9Mig+bi9LRqTHofBzIe" ];
    meta.gpg.publicKey.fingerprint = "57CF72B72BBA3C88A68CFE153AC661943D80C89E";

    meta.base16.theme = lib.mkDefault "tomorrow-night";

    meta.programs = let
      pkgToProg = pkg: exe: {
        package = pkg;
        executable.name = exe;
      };
    in {
      browser.package = pkgs.links;
      browser.executable.name = "links";

      editor.package = pkgs.neovim.override {
        viAlias = true;
        vimAlias = true;
        withPython = true;
        withPython3 = true;
        withRuby = true;
      };
      editor.executable.name ="nvim";

      mailer.package = pkgs.mutt;
      mailer.executable.name ="mutt";

      pager.package = pkgs.less;
      pager.executable.name ="less";

      shell.package = pkgs.zsh;
      shell.executable.name ="zsh";

    } // lib.optionalAttrs config.meta.graphics.enable {
      browser.package = pkgs.chromium;
      browser.executable.name ="chromium";

      mailer.package = pkgs.thunderbird;
      mailer.executable.name ="thunderbird";

      terminal.package = pkgs.kitty;
      terminal.executable.name ="kitty";
    };
  };
}
