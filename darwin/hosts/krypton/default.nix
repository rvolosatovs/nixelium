{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../resources/hosts/krypton
    ./../../hardware/macbook-pro/15-2
  ];

  config = {
    networking.hostName = "krypton";
  };
}
