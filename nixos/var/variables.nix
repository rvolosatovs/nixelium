{ pkgs, ... }:

rec {
  username = "rvolosatovs";
  hostname = "neon";

  homeDir = "/home/${username}";
  email = "${username}@riseup.net";

  editor = "${pkgs.neovim}/bin/nvim";
  browser = "${pkgs.firefox}/bin/firefox";
  mailer = "${pkgs.thunderbird}/bin/thunderbird";
  pager = "${pkgs.less}/bin/less";

  isSSD = true;
}
