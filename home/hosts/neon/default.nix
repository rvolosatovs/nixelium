{ pkgs, ... }:
{
  home.packages = with pkgs; [
    copy-sha-git
  ];

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;
}
