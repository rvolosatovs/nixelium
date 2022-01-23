{ pkgs, ... }:
{
  imports = [
    ../../lan.nix
  ];

  home.packages = with pkgs; [
    engify
    mkvtoolnix
  ];

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;
}
