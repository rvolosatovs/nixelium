{ config, pkgs, lib, ... }:

{
  imports = [
    ./../..
    ./../../nginx.nix
  ];

  boot.initrd.network.enable = true;
  boot.initrd.network.postCommands = ''
      echo "cryptsetup-askpass; exit" > /root/.profile
  '';
  boot.initrd.network.ssh.authorizedKeys = config.users.users.${config.resources.username}.openssh.authorizedKeys.keys;
  boot.initrd.network.ssh.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  home-manager.users.${config.resources.username} = import ../../../home/profiles/server;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.useDHCP = false;
  networking.usePredictableInterfaceNames = false; # required for initrd ssh to work. See https://github.com/NixOS/nixpkgs/pull/68953.

  programs.ssh.askPassword = "${pkgs.pinentry_ncurses}/bin/pinentry";

  services.boinc.enable = true;

  services.foldingathome.enable = true;
  services.foldingathome.user = "rvolosatovs";
  services.foldingathome.team = 251175;

  services.logind.lidSwitch = "ignore";
}
