{ pkgs, graphical ? false, ... }:

rec {
  username = "rvolosatovs";

  homeDir = "/home/${username}";
  email = "${username}@riseup.net";

  luksDevice = "/dev/sda2";
  luksName = "luksroot";

  netDeviceName = "eth0";

  browser = if graphical
  then "${pkgs.chromium}/bin/chromium"
  else "${pkgs.links}/bin/links";

  mailer = if graphical
  then "${pkgs.mutt}/bin/mutt"
  else "${pkgs.thunderbird}/bin/thunderbird";

  editor = "${pkgs.neovim}/bin/nvim";

  terminal = if graphical
  then "${pkgs.kitty}/bin/kitty"
  else throw "terminal undefined for CLI environment";

  shell = "${pkgs.zsh}/bin/zsh";

  pager = "${pkgs.less}/bin/less";

  isSSD = true;

  histsize = 10000;
}
