{ pkgs, ... }:
{
  home.packages = with pkgs; [ 
    gopass
  ];

  programs.zsh.shellAliases.pass="gopass";
}
