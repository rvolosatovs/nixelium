{ config, pkgs, lib,... }:

{
  config.meta = lib.mapAttrs (_: v: lib.mkDefault v) {
    email = "rvolosatovs@riseup.net";
    username = "rvolosatovs";
    fullName = "Roman Volosatovs";

    ssh.publicKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSZ+ZWFCat0Fvog7XpS7mnNK9Mig+bi9LRqTHofBzIe" ];
    gpg.publicKey.fingerprint = "57CF72B72BBA3C88A68CFE153AC661943D80C89E";

    base16.theme = "tomorrow-night";

    programs = let
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
