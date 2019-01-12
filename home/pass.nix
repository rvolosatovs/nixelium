{ pkgs, ... }:
{
  home.packages = with pkgs; [ gopass ];
  home.sessionVariables.PASSWORD_STORE_DIR = ./../vendor/pass; # TODO: Make this a path that exists and is synced in all environments
}
