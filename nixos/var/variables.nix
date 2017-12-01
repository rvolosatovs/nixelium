{ pkgs, ... }:

{
  homeDir = "/home/rvolosatovs";
  username = "rvolosatovs";
  hostname = "neon";
  email = "rvolosatovs@riseup.net";
  editor = "${pkgs.neovim}/bin/nvim";
  browser = "${pkgs.firefox}/bin/firefox";
  mailer = "${pkgs.thunderbird}/bin/thunderbird";
  pager = "${pkgs.less}/bin/less";
  isSSD = true;

}
