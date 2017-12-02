{ lib, config, pkgs, ... }:
{
  imports = [
    ../lib/common.nix
    ../lib/graphical.nix
  ];

  home.packages = with pkgs; [
    arduino
    pandoc
  ];
}
