{ config, pkgs, ... }:

{
  imports = [
    ./../..
    ./../../nginx.nix
    ./../../dumpster.nix
  ];

  boot.initrd.network.enable = true;
  boot.initrd.network.postCommands = ''
      echo "cryptsetup-askpass; exit" > /root/.profile
  '';
  boot.initrd.network.ssh.authorizedKeys = config.users.users.${config.resources.username}.openssh.authorizedKeys.keys;
  boot.initrd.network.ssh.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  home-manager.users.${config.resources.username} = import ../../../home/profiles/server;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.useDHCP = false;
  networking.usePredictableInterfaceNames = false;
}
