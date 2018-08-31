{ config, pkgs, ... }:

{
  imports = [
    ./../..
  ];

  boot.initrd.network.enable = true;
  boot.initrd.network.postCommands = ''
      echo "cryptsetup-askpass; exit" > /root/.profile
  '';
  boot.initrd.network.ssh.authorizedKeys = config.users.users.${config.meta.username}.openssh.authorizedKeys.keys;
  boot.initrd.network.ssh.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  home-manager.users.${config.meta.username} = import ../../../home/profiles/server;

  networking.useDHCP = false;
  networking.usePredictableInterfaceNames = false;
}
