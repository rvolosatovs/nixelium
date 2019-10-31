{ pkgs, ... }:
{
  home.packages = with pkgs; let
    winePkg = wineWowPackages.staging;
  in [
    winePkg
    (winetricks.override { wine = winePkg; })
  ];
}
