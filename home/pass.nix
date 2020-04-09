{ pkgs, ... }:
{
  home.packages = with pkgs; [ 
    gopass
  ];
}
