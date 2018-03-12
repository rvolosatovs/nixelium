{ pkgs, ... }:

rec {
  username = "rvolosatovs";
  hostname = "neon";

  homeDir = "/home/${username}";
  email = "${username}@riseup.net";

  luksDevice = "/dev/sda2";
  luksName = "luksroot";

  netDeviceName = "eth0";

  browser = "${pkgs.links}/bin/links";
  editor = "${pkgs.neovim}/bin/nvim";
  mailer = "${pkgs.mutt}/bin/mutt";
  pager = "${pkgs.less}/bin/less";

  isSSD = true;

  histsize = 10000;
}
