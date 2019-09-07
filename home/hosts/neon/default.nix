{ pkgs, ... }:
{
  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;
}
