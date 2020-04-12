{ config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ./../..
    ./../../../resources/hosts/mercury
    ./../../../vendor/secrets/nixos/hosts/mercury
    ./../../../vendor/secrets/resources/hosts/mercury
    ./../../graphical.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    borgbackup
    keybase
  ];

  home-manager.users.${config.resources.username} = import ./../../../home/hosts/mercury;

  networking.hostName = "mercury";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
}
