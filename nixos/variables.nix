{ pkgs, ... }:

{
  homeDir = "/home/rvolosatovs";
  username = "rvolosatovs";
  hostname = "neon";
  email = "rvolosatovs@riseup.net";
  editor = "${pkgs.neovim}/bin/nvim";
  browser = "${pkgs.chromium}/bin/chromium";
  pager = "${pkgs.less}/bin/less";
}
