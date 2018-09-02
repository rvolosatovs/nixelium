{ pkgs, ... }:
{
  home.packages = with pkgs; [ pass ];
  home.sessionVariables.PASSWORD_STORE_DIR = ./../vendor/pass;
}
