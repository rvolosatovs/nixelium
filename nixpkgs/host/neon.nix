{ lib, config, pkgs, ... }:
{
  imports = [
    ../lib/common.nix
  ];

  home.packages = with pkgs; [
    arduino
    pandoc
  ];
}
