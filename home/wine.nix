{ pkgs, ... }:
{
  home.packages = with pkgs; let
    winePkg = wineWowPackages.staging;
  in [
    lutris
    winePkg
    (winetricks.override { wine = winePkg; })
  ];
}
