{ pkgs, ... }:
{
  home.packages = with pkgs; [ 
    gopass
  ];

  programs.zsh.shellAliases.pass="${pkgs.gopass}/bin/gopass";
}
