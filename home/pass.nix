{ pkgs, ... }:
{
  home.packages = with pkgs; [ gopass ];
  home.sessionVariables.PASSWORD_STORE_DIR = ./../vendor/pass;
}
